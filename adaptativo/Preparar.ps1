param([Parameter(Mandatory=$true)][string]$Managed,[Parameter(Mandatory=$true)][string]$Output)
$ErrorActionPreference='Stop'
$Managed=[IO.Path]::GetFullPath($Managed);$Output=[IO.Path]::GetFullPath($Output)
if($Managed -eq $Output){throw 'A preparação deve ocorrer em uma pasta separada.'}
New-Item -ItemType Directory -Path $Output -Force | Out-Null
Add-Type -Path (Join-Path $PSScriptRoot 'Mono.Cecil.dll')
Add-Type -Path (Join-Path $PSScriptRoot 'AdaptiveJson.dll')
[AdaptiveJson]::Load((Join-Path $PSScriptRoot 'dados\dictionary.tsv'),(Join-Path $PSScriptRoot 'dados\display-keys.txt'))
$csc=Join-Path ([Environment]::GetFolderPath('Windows')) 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if(!(Test-Path -LiteralPath $csc)){$csc=Join-Path ([Environment]::GetFolderPath('Windows')) 'Microsoft.NET\Framework\v4.0.30319\csc.exe'}
if(!(Test-Path -LiteralPath $csc)){throw 'O compilador do .NET Framework 4.x não foi encontrado.'}
$names=@('UnityEngine.CoreModule.dll','UnityEngine.TextRenderingModule.dll','UnityEngine.UI.dll','UnityEngine.UIModule.dll','Unity.TextMeshPro.dll','netstandard.dll')
$names+=@(Get-ChildItem -LiteralPath $Managed -Filter 'UnityEngine.TextCore*Module.dll' | Select-Object -ExpandProperty Name)
$refs=@($names | Select-Object -Unique | ForEach-Object {$p=Join-Path $Managed $_;if(!(Test-Path -LiteralPath $p)){throw "API Unity ausente: $_. Versão ainda não suportada."}; '/reference:'+$p})
$helper=Join-Path $Output 'PortugueseSupport.dll'
$compilerOutput=& $csc /nologo /optimize+ /target:library "/out:$helper" $refs ('/resource:'+(Join-Path $PSScriptRoot 'dados\dictionary.tsv')+',AeonsEnd.PTBR.Dictionary') (Join-Path $PSScriptRoot 'src\PortugueseSupport.cs') (Join-Path $PSScriptRoot 'src\LabelTranslations.cs') (Join-Path $PSScriptRoot 'src\RuntimeDictionary.cs') 2>&1
if($LASTEXITCODE -ne 0){throw "Esta API de texto ainda não é suportada. Nenhum arquivo do jogo foi alterado. Detalhes: $compilerOutput"}
$rules=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'dados\rules.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$lookup=[Collections.Generic.Dictionary[string,string]]::new([StringComparer]::Ordinal)
foreach($r in $rules){
 if($r.type -eq 'Handelabra.AeonsEnd.View.HelpViewController' -and $r.method -eq 'ShowForGameState' -and $r.source -ceq 'Help'){throw 'Regra proibida para identificador de cena.'}
 $lookup[($r.assembly+'|'+$r.type+'|'+$r.method+'|'+$r.source)]=$r.translation
}
$resolver=[Mono.Cecil.DefaultAssemblyResolver]::new();$resolver.AddSearchDirectory($Managed);$resolver.AddSearchDirectory($Output)
$rp=[Mono.Cecil.ReaderParameters]::new();$rp.AssemblyResolver=$resolver;$rp.InMemory=$true
$script:ilCount=0
function Patch-Type($t,$name){
 foreach($m in $t.Methods){if(!$m.HasBody){continue};foreach($i in $m.Body.Instructions){
  if($i.OpCode.Code -eq 'Ldstr'){$key=$name+'|'+$t.FullName+'|'+$m.Name+'|'+[string]$i.Operand;if($lookup.ContainsKey($key)){$i.Operand=$lookup[$key];$script:ilCount++}}
 }}
 foreach($n in $t.NestedTypes){Patch-Type $n $name}
}
function Find-Type($a,$name){$result=@($a.MainModule.Types | Where-Object Name -ceq $name);if($result.Count -ne 1){throw "Tipo esperado ausente/ambíguo: $name"};return $result[0]}
function Find-Method($t,$name,$count,$returnType){$result=@($t.Methods | Where-Object {$_.Name -ceq $name -and $_.Parameters.Count -eq $count -and $_.ReturnType.FullName -ceq $returnType -and $_.HasBody});if($result.Count -ne 1){throw "API incompatível: $($t.Name).$name"};return $result[0]}
foreach($name in @('Assembly-CSharp.dll','AeonsEndEngine.dll')){
 $a=[Mono.Cecil.AssemblyDefinition]::ReadAssembly((Join-Path $Managed $name),$rp)
 try{
  if($a.Name.Name -cne [IO.Path]::GetFileNameWithoutExtension($name)){throw 'Identidade da biblioteca incompatível.'}
  if(@($a.MainModule.AssemblyReferences | Where-Object Name -eq PortugueseSupport).Count){throw 'A base já contém a tradução. Restaure os originais antes de atualizar.'}
  if($name -eq 'Assembly-CSharp.dll'){$null=Find-Type $a 'HelpViewController'}else{$null=Find-Type $a 'State'}
  foreach($t in $a.MainModule.Types){Patch-Type $t $name}
  if($name -eq 'AeonsEndEngine.dll'){
   for($j=0;$j -lt $a.MainModule.Resources.Count;$j++){
    $r=$a.MainModule.Resources[$j]
    if($r -is [Mono.Cecil.EmbeddedResource] -and $r.Name.EndsWith('.json',[StringComparison]::OrdinalIgnoreCase)){
     $raw=[Text.Encoding]::UTF8.GetString($r.GetResourceData());$patched=[AdaptiveJson]::Translate($raw)
     if($raw -cne $patched){$a.MainModule.Resources[$j]=[Mono.Cecil.EmbeddedResource]::new($r.Name,$r.Attributes,[Text.Encoding]::UTF8.GetBytes($patched))}
    }
   }
  }
  $a.Write((Join-Path $Output $name))
 }finally{$a.Dispose()}
}
if($script:ilCount -lt 20 -or [AdaptiveJson]::Changes -lt 20){throw 'Poucos textos reconhecidos. Versão precisa de revisão; nenhum arquivo do jogo foi alterado.'}
$tmp=[Mono.Cecil.AssemblyDefinition]::ReadAssembly((Join-Path $Managed 'Unity.TextMeshPro.dll'),$rp)
$h=[Mono.Cecil.AssemblyDefinition]::ReadAssembly($helper,$rp)
try{
 if(@($tmp.MainModule.AssemblyReferences | Where-Object Name -eq PortugueseSupport).Count){throw 'TextMeshPro da base já está modificado pela tradução.'}
 $ht=Find-Type $h 'PortugueseSupport'
 $configure=$tmp.MainModule.ImportReference((Find-Method $ht 'Configure' 1 'System.Void'))
 $label=$tmp.MainModule.ImportReference((Find-Method $ht 'TranslateLabel' 1 'System.String'))
 $face=$tmp.MainModule.ImportReference((Find-Method $ht 'LoadFace' 2 'UnityEngine.TextCore.LowLevel.FontEngineError'))
 $hooks=0;$faces=0
 foreach($name in @('TextMeshProUGUI','TextMeshPro')){
  $t=Find-Type $tmp $name
  foreach($hook in @('OnEnable',$(if($name -eq 'TextMeshProUGUI'){'OnPreRenderCanvas'}else{'OnPreRenderObject'}))){
   $m=Find-Method $t $hook 0 'System.Void';$first=$m.Body.Instructions[0];$il=$m.Body.GetILProcessor()
   $il.InsertBefore($first,$il.Create([Mono.Cecil.Cil.OpCodes]::Ldarg_0));$il.InsertBefore($first,$il.Create([Mono.Cecil.Cil.OpCodes]::Call,$configure));$hooks++
  }
 }
 $setter=Find-Method (Find-Type $tmp 'TMP_Text') 'set_text' 1 'System.Void'
 if($setter.Parameters[0].ParameterType.FullName -cne 'System.String'){throw 'Setter de texto incompatível.'}
 $il=$setter.Body.GetILProcessor();$first=$setter.Body.Instructions[0]
 $il.InsertBefore($first,$il.Create([Mono.Cecil.Cil.OpCodes]::Ldarg_1));$il.InsertBefore($first,$il.Create([Mono.Cecil.Cil.OpCodes]::Call,$label));$il.InsertBefore($first,$il.Create([Mono.Cecil.Cil.OpCodes]::Starg,$setter.Parameters[0]));$hooks++
 foreach($t in $tmp.MainModule.Types){foreach($m in $t.Methods){if(!$m.HasBody){continue};foreach($i in $m.Body.Instructions){if($i.Operand -is [Mono.Cecil.MethodReference] -and $i.Operand.FullName -ceq 'UnityEngine.TextCore.LowLevel.FontEngineError UnityEngine.TextCore.LowLevel.FontEngine::LoadFontFace(UnityEngine.Font,System.Int32)'){$i.Operand=$face;$faces++}}}}
 if(!$faces){throw 'API de fonte incompatível. Nenhum arquivo do jogo foi alterado.'}
 $tmp.Write((Join-Path $Output 'Unity.TextMeshPro.dll'))
}finally{$tmp.Dispose();$h.Dispose();$resolver.Dispose()}
[pscustomobject]@{il=$script:ilCount;resources=[AdaptiveJson]::Changes;hooks=$hooks;fontCalls=$faces} | ConvertTo-Json -Compress
