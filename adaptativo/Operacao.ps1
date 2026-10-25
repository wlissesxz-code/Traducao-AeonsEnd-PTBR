param([string]$GamePath,[ValidateSet('Instalar','Restaurar')][string]$Acao='Instalar')
$ErrorActionPreference='Stop'
function Hash($p){(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant()}
function Locate-Game {
 $roots=@('C:\Program Files (x86)\Steam','C:\Program Files\Steam')
 $steam=Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction SilentlyContinue
 if($steam.SteamPath){$roots+=$steam.SteamPath}
 foreach($r in @($roots)){$v=Join-Path $r 'steamapps\libraryfolders.vdf';if(Test-Path -LiteralPath $v){foreach($m in [regex]::Matches((Get-Content -LiteralPath $v -Raw),'"path"\s+"([^"]+)"')){$roots+=$m.Groups[1].Value.Replace('\\','\')}}}
 $found=@($roots | Select-Object -Unique | ForEach-Object {Join-Path $_ "steamapps\common\Aeon's End"} | Where-Object {Test-Path -LiteralPath (Join-Path $_ 'AeonsEnd.exe')})
 if($found.Count -eq 1){return $found[0]}
 return (Read-Host 'Cole a pasta do Aeon''s End (Steam, GOG ou outra biblioteca Windows)').Trim('"')
}
if(!$GamePath){$GamePath=Locate-Game}
$GamePath=[IO.Path]::GetFullPath($GamePath.Trim('"'))
if([IO.Path]::GetFileName($GamePath) -ieq 'AeonsEnd.exe'){$GamePath=Split-Path $GamePath}
$exe=Join-Path $GamePath 'AeonsEnd.exe';$managed=Join-Path $GamePath 'AeonsEnd_Data\Managed'
if(!(Test-Path -LiteralPath $exe) -or !(Test-Path -LiteralPath $managed)){throw 'Pasta do jogo inválida. Nenhum arquivo foi alterado.'}
foreach($p in @(Get-Process AeonsEnd -ErrorAction SilentlyContinue)){try{$processPath=$p.Path}catch{$processPath=$null};if($processPath -and [string]::Equals($processPath,$exe,[StringComparison]::OrdinalIgnoreCase)){throw "O jogo está ativo nesta pasta (PID $($p.Id)). Feche esse processo antes de instalar."}}
$paths=@('AeonsEnd_Data\Managed\Assembly-CSharp.dll','AeonsEnd_Data\Managed\AeonsEndEngine.dll','AeonsEnd_Data\Managed\Unity.TextMeshPro.dll','AeonsEnd_Data\Managed\PortugueseSupport.dll')
$dataPath='AeonsEnd_Data\data.unity3d';$helperPath=$paths[3]
$journal=Join-Path $GamePath 'AeonsEnd-PTBR-installed.json'
$oldStateBytes=$null;$state=$null
if(Test-Path -LiteralPath $journal){$oldStateBytes=[IO.File]::ReadAllBytes($journal);$state=Get-Content -LiteralPath $journal -Raw -Encoding UTF8 | ConvertFrom-Json
 if($state.format -ne 1 -or $state.files.Count -lt 4 -or $state.files.Count -gt 5){throw 'Registro da tradução incompatível.'}
 $seen=@{}
 foreach($f in $state.files){if($f.path -notin ($paths+@($dataPath)) -or $seen.ContainsKey($f.path)){throw 'Registro com caminho inválido.'};$seen[$f.path]=$true}
 foreach($path in $paths){if(!$seen.ContainsKey($path)){throw 'Registro incompleto.'}}
}
if($Acao -eq 'Restaurar' -and !$state){throw 'Não há registro da versão 0.4 nesta pasta. Para uma tradução anterior, use o restaurador daquela versão.'}
$legacy=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'dados\legacy.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$legacyMap=@{};foreach($f in $legacy){$legacyMap[$f.path]=$f}
$plans=@()
foreach($path in $paths){
 $dest=Join-Path $GamePath $path;$exists=Test-Path -LiteralPath $dest;$actual=if($exists){Hash $dest}else{$null}
 $original=$actual;$source=$dest
 if($state){
  $f=@($state.files | Where-Object path -ceq $path)[0]
  if($actual -ne $f.installed_sha256){throw "O arquivo mudou depois da instalação: $path. Restaure os originais e verifique o jogo na sua biblioteca antes de atualizar a tradução."}
  $original=$f.original_sha256;$source=if($original){"$dest.original-ptbr-04"}else{$null}
  if($original -and (!(Test-Path -LiteralPath $source) -or (Hash $source) -ne $original)){throw "Backup ausente ou incompatível: $path"}
 }else{
  if(Test-Path -LiteralPath "$dest.original-ptbr-04"){throw "Backup 0.4 sem registro de instalação: $path. Preserve os arquivos e solicite suporte."}
  if($path -eq $helperPath){
   if($exists -and $actual -notin (@($legacyMap[$path].translated_sha256)+@($legacyMap[$path].previous_sha256))){throw 'Já existe um componente PortugueseSupport desconhecido nesta instalação.'}
   $original=$null;$source=$null
  }else{
   if(!$exists){throw "Biblioteca ausente: $path. Versões IL2CPP/mobile não são suportadas."}
   $f=$legacyMap[$path]
   if($actual -in (@($f.translated_sha256)+@($f.previous_sha256))){
    $source="$dest.original-ptbr";$original=$f.original_sha256
    if(!(Test-Path -LiteralPath $source) -or (Hash $source) -ne $original){throw "A versão anterior da tradução precisa do backup original: $path"}
   }
  }
 }
 $plans+=[pscustomobject]@{Path=$path;Dest=$dest;Existed=$exists;OldHash=$actual;OriginalHash=$original;Source=$source;Backup="$dest.original-ptbr-04";CreatedBackup=$false;Touched=$false;TargetHash=$null}
}
# When migrating 0.3, undo its fixed-build asset replacement. The 0.4 UI is
# translated at display time, leaving the original bundle from this game intact.
$dest=Join-Path $GamePath $dataPath
$oldData=if($state){@($state.files | Where-Object path -ceq $dataPath)}else{@()}
if($oldData.Count -or (!$state -and (Test-Path -LiteralPath $dest) -and (Hash $dest) -in (@($legacyMap[$dataPath].translated_sha256)+@($legacyMap[$dataPath].previous_sha256)))){
 $f=if($oldData.Count){$oldData[0]}else{$legacyMap[$dataPath]}
 $original=$f.original_sha256;$source=if($oldData.Count){"$dest.original-ptbr-04"}else{"$dest.original-ptbr"}
 if(!(Test-Path -LiteralPath $source) -or (Hash $source) -ne $original){throw 'Falta o backup original do arquivo de recursos da tradução anterior.'}
 if($oldData.Count -and (Hash $dest) -ne $f.installed_sha256){throw 'O arquivo de recursos mudou depois da instalação.'}
 $plans+=[pscustomobject]@{Path=$dataPath;Dest=$dest;Existed=$true;OldHash=(Hash $dest);OriginalHash=$original;Source=$source;Backup="$dest.original-ptbr-04";CreatedBackup=$false;Touched=$false;TargetHash=$null}
}
foreach($p in $plans){if($p.Existed){try{$handle=[IO.File]::Open($p.Dest,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None);$handle.Dispose()}catch{throw "Arquivo bloqueado ou sem permissão de gravação: $($p.Path). Nenhum arquivo foi alterado."}}}
if($Acao -eq 'Instalar'){
 $integrity=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'integridade.json') -Raw -Encoding UTF8 | ConvertFrom-Json
 foreach($a in $integrity){if($a.path -match '(^[\\/]|:|\.\.)'){throw 'Caminho de pacote inválido.'};$p=Join-Path $PSScriptRoot $a.path;if(!(Test-Path -LiteralPath $p) -or (Hash $p) -ne $a.sha256){throw "Pacote incompleto ou alterado: $($a.path). Extraia novamente o ZIP."}}
}
$tempBase=Join-Path ([IO.Path]::GetTempPath()) 'AeonsEnd-PTBR-04'
$stage=Join-Path $tempBase ([guid]::NewGuid().ToString('N'));$keep=$false
New-Item -ItemType Directory -Path $stage -Force | Out-Null
try{
 $output=Join-Path $stage 'new';New-Item -ItemType Directory -Path $output | Out-Null
 if($Acao -eq 'Instalar'){
  $base=Join-Path $stage 'base';New-Item -ItemType Directory -Path $base | Out-Null
  Get-ChildItem -LiteralPath $managed -Filter '*.dll' | Where-Object Name -ne 'PortugueseSupport.dll' | Copy-Item -Destination $base -Force
  foreach($p in $plans){if($p.Source -and $p.Path -ne $dataPath){Copy-Item -LiteralPath $p.Source -Destination (Join-Path $base ([IO.Path]::GetFileName($p.Path))) -Force}}
  Write-Output 'Adaptando a tradução às bibliotecas desta instalação...'
  $report=& (Join-Path $PSScriptRoot 'Preparar.ps1') -Managed $base -Output $output
  Write-Output $report
 }
 $i=0
 foreach($p in $plans){
  $p | Add-Member NoteProperty Staged (Join-Path $output ([IO.Path]::GetFileName($p.Path)))
  $p | Add-Member NoteProperty Rollback (Join-Path $stage "old-$i")
  if($p.Existed){Copy-Item -LiteralPath $p.Dest -Destination $p.Rollback}
  if($Acao -eq 'Restaurar' -or $p.Path -eq $dataPath){if($p.Source){Copy-Item -LiteralPath $p.Source -Destination $p.Staged -Force};$p.TargetHash=$p.OriginalHash}
  else{$p.TargetHash=Hash $p.Staged}
  if($p.TargetHash -and (Hash $p.Staged) -ne $p.TargetHash){throw 'Resultado inválido na preparação.'}
  $i++
 }
 foreach($p in $plans){$now=if(Test-Path -LiteralPath $p.Dest){Hash $p.Dest}else{$null};if($now -ne $p.OldHash){throw 'Um arquivo mudou durante a preparação. Tente novamente.'}}
 try{
  foreach($p in $plans){
   if($Acao -eq 'Instalar' -and $p.OriginalHash -and !(Test-Path -LiteralPath $p.Backup)){Copy-Item -LiteralPath $p.Source -Destination $p.Backup;$p.CreatedBackup=$true;if((Hash $p.Backup) -ne $p.OriginalHash){throw 'Falha ao preservar original.'}}
   $p.Touched=$true
   if(!$p.TargetHash){if(Test-Path -LiteralPath $p.Dest){Remove-Item -LiteralPath $p.Dest}}
   else{Copy-Item -LiteralPath $p.Staged -Destination $p.Dest -Force;if((Hash $p.Dest) -ne $p.TargetHash){throw 'Falha ao conferir cópia final.'}}
  }
  if($Acao -eq 'Instalar'){
   $record=[ordered]@{format=1;version='0.4.1-beta';files=@($plans | ForEach-Object {[ordered]@{path=$_.Path;original_sha256=$_.OriginalHash;installed_sha256=$_.TargetHash}})} | ConvertTo-Json -Depth 6
   [IO.File]::WriteAllText($journal,$record,[Text.UTF8Encoding]::new($false))
  }else{
   # Keep a record of the restored state so reinstalling remains verifiable.
   $record=[ordered]@{format=1;version='0.4.1-beta';restored=$true;files=@($plans | ForEach-Object {[ordered]@{path=$_.Path;original_sha256=$_.OriginalHash;installed_sha256=$_.TargetHash}})} | ConvertTo-Json -Depth 6
   [IO.File]::WriteAllText($journal,$record,[Text.UTF8Encoding]::new($false))
  }
 }catch{
  $failure=$_
  foreach($p in $plans){try{if($p.Touched){if($p.Existed){Copy-Item -LiteralPath $p.Rollback -Destination $p.Dest -Force;if((Hash $p.Dest) -ne $p.OldHash){throw 'Rollback inválido'}}elseif(Test-Path -LiteralPath $p.Dest){Remove-Item -LiteralPath $p.Dest}};if($p.CreatedBackup){Remove-Item -LiteralPath $p.Backup}}catch{$keep=$true}}
  try{if($oldStateBytes){[IO.File]::WriteAllBytes($journal,$oldStateBytes)}elseif(Test-Path -LiteralPath $journal){Remove-Item -LiteralPath $journal}}catch{$keep=$true}
  if($keep){throw "A recuperação precisa de atenção. Cópias anteriores preservadas em $stage. Erro inicial: $failure"}
  throw "Operação cancelada; os arquivos anteriores foram recuperados. Detalhe: $failure"
 }
 if($Acao -eq 'Instalar'){Write-Output 'Beta 0.4.1 instalada. Guarde os backups e o registro na pasta do jogo.'}else{Write-Output 'Arquivos originais restaurados. Backups e registro foram mantidos.'}
}finally{
 if(!$keep -and (Test-Path -LiteralPath $stage)){
  $absolute=[IO.Path]::GetFullPath($stage);$parent=[IO.Path]::GetFullPath($tempBase).TrimEnd('\')+'\'
  if(!$absolute.StartsWith($parent,[StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetFileName($absolute) -notmatch '^[0-9a-f]{32}$'){throw 'Limpeza interrompida: pasta temporária inválida.'}
  Remove-Item -LiteralPath $absolute -Recurse -Force
 }
}
