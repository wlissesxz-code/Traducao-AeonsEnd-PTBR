# Fontes da beta 0.4.0

Para instalar, use o ZIP completo em Releases. Esta pasta contém os fontes para inspeção. O ZIP inclui os dicionários/regras em `dados/`, o componente compilado AdaptiveJson.dll e Mono.Cecil 0.11.6 (MIT), necessários para executar o instalador. Os scripts antigos da raiz correspondem à revisão 0.3.1.

AdaptiveJson.dll é compilado a partir de `src/AdaptiveJson.cs` com o compilador C# do .NET Framework 4.x (`csc.exe /target:library /out:AdaptiveJson.dll src\AdaptiveJson.cs`). `Preparar.ps1` compila PortugueseSupport.dll contra as bibliotecas da instalação encontrada e incorpora o dicionário na biblioteca de suporte. Bibliotecas originais do jogo não são redistribuídas.

Os recursos de definição conhecidos são traduzidos apenas nos campos de apresentação aprovados. Recursos de esquema desconhecido permanecem intactos. A tradução na interface reconhece textos conhecidos e variações de formatação sem fazer correspondências por semelhança.
