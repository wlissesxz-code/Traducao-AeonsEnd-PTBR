# Aeon's End PT-BR — beta 0.4.0 adaptativa

Esta revisão amplia a compatibilidade entre versões **Windows com Unity/Mono**. A tradução é preparada a partir das bibliotecas da própria instalação, em vez de substituir arquivos inteiros de uma build específica.

Não significa suporte garantido a todas as versões existentes. Duas bases Windows diferentes foram verificadas: a base Steam da beta 0.3.1 (build 21251852) e uma instalação mais antiga com AeonsEndEngine 1.0.8285.20787. APIs incompatíveis são recusadas na preparação, antes de copiar os resultados. Versões de outros sistemas e versões IL2CPP não são suportadas.

## Instalação e atualização

1. Feche o jogo e extraia todo o ZIP.
2. Execute `Instalar.cmd`. Se a pasta não for encontrada, cole a pasta que contém `AeonsEnd.exe`. Bibliotecas fora do Steam podem ser informadas manualmente.
3. Aguarde a mensagem **Beta 0.4.0 instalada**. Abra o jogo normalmente.

O instalador compila o suporte de fonte contra as bibliotecas encontradas e altera somente trechos de texto aprovados. Textos de interface são traduzidos quando aparecem. Não é preciso instalar Python ou baixar componentes adicionais: o processo usa o .NET Framework 4.x do Windows. Reserve cerca de 500 MB livres para preparação e backup.

Os originais ficam ao lado dos arquivos alterados, com o sufixo `.original-ptbr-04`. O arquivo `AeonsEnd-PTBR-installed.json` registra os hashes dos originais e dos resultados. **Guarde os backups e o registro.** Saves não são alterados pelo instalador.

Ao atualizar uma beta antiga deste projeto, os backups `.original-ptbr` são necessários. O instalador reconhece os arquivos dessas versões e usa os originais para preparar a nova tradução. O antigo arquivo de recursos fixo é restaurado; a revisão 0.4 traduz a interface na exibição.

## Restaurar ou atualizar o jogo

Feche o jogo e execute `Restaurar.cmd`. Os arquivos originais são recuperados; backups e registro permanecem para permitir uma reinstalação verificável.

Antes de atualizar o próprio jogo, restaure a tradução. Depois da atualização, use uma cópia limpa do jogo para instalar novamente. Se os arquivos mudaram depois da tradução, o instalador pede restauração/verificação na sua biblioteca em vez de misturar versões. Não apague nem renomeie backups para contornar um erro.

## Compatibilidade e limites

- A mudança remove a dependência de hashes de uma única build, mantendo verificações da estrutura e dos arquivos da instalação.
- A API do Unity/TextMeshPro precisa ser compatível com o suporte de fonte. Se não for, a instalação é interrompida durante a preparação.
- Textos desconhecidos de futuras versões permanecem no idioma original; eles não são substituídos por semelhança. O dicionário usa correspondências exatas, variações explicitamente revisadas e equivalência do mesmo texto com mudanças apenas em espaços ou recuos. Correspondências ambíguas são ignoradas.
- Identificadores, números, regras e campos de dados não destinados à exibição são preservados. O nome interno da cena `Help` continua intacto.
- Tradução ainda em revisão linguística. Não foram testadas todas as cartas, personagens, nêmeses, expansões, resoluções e combinações de versão. Imagens com texto e conteúdo externo podem continuar em inglês.

Para relatar um problema, informe a versão do jogo, a mensagem de erro ou os passos para reproduzir, e uma captura do texto se possível. Não publique saves ou informações pessoais.

## Créditos e dependências

Tradução comunitária não oficial, sem vínculo com os titulares do jogo. Jogo, arte, regras e marcas pertencem aos respectivos titulares; desenvolvimento digital pela Handelabra Games. Base textual com tradução automática do Google Translate e ajustes/implementação com auxílio do OpenAI Codex; revisão humana em andamento.

Inclui Mono.Cecil 0.11.6, de Jb Evain e contribuidores, sob licença MIT. Consulte `Mono.Cecil-LICENSE.txt` e https://github.com/jbevain/cecil. Os fontes do componente de suporte e do leitor de campos de texto estão em `src/`.

O pacote não contém o jogo nem cópias completas das bibliotecas do jogo.
