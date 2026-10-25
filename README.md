# Aeon’s End PT-BR — beta 0.4.1

A nova beta amplia a compatibilidade entre versões **Windows/Unity/Mono**: prepara a tradução usando os arquivos da própria instalação. Foi testada na base Steam 21251852 e em uma instalação mais antiga com AeonsEndEngine 1.0.8285.20787. Isso não garante suporte a toda versão existente; APIs incompatíveis são recusadas durante a preparação.

[Baixar a beta 0.4.1 e consultar as instruções](https://github.com/wlissesxz-code/Traducao-AeonsEnd-PTBR/releases/tag/v0.4.1-beta).

Extraia todo o ZIP e execute **Instalar.cmd** com o jogo fechado. Para bibliotecas fora do Steam, informe a pasta que contém AeonsEnd.exe. Inclui backup, restauração e atualização das betas anteriores, desde que os originais estejam preservados. Restaure a tradução antes de atualizar o jogo.

[Instruções completas e limitações](adaptativo/LEIA-ME.md). Fontes dos componentes em `adaptativo/`; o ZIP da release inclui os dicionários, regras e dependências necessários. Baixar apenas o código-fonte do GitHub não substitui o pacote de instalação. Os scripts da revisão anterior permanecem na raiz para referência histórica.


**Correção 0.4.1:** resolve o erro `0x80131515` ao carregar as bibliotecas baixadas no Windows. Confere os hashes das duas dependências antes de remover seus bloqueios por download. Baixe e extraia o ZIP completo em uma nova pasta.

## Documentação da beta 0.3.1 (histórico)

# Aeon’s End em português brasileiro — beta 0.3.1

Tradução comunitária não oficial para a edição Windows do jogo Aeon’s End, da Handelabra Games. Requer uma cópia legítima instalada. Este pacote contém alterações e um componente de suporte; o instalador reconstrói os arquivos usando a instalação original.

## Instalar ou atualizar

1. Feche o jogo. Extraia **todo** o ZIP para uma pasta comum; não execute dentro do ZIP.
2. Baixe o ZIP em Releases, extraia-o e abra `Instalar.cmd`. A pasta do Steam é procurada automaticamente. Se solicitado, cole a pasta que contém `AeonsEnd.exe` (Steam → Gerenciar → Explorar arquivos locais).
3. Aguarde a mensagem “Beta 0.3.1 instalada” e abra o jogo normalmente pelo Steam.

Os originais ficam ao lado dos arquivos do jogo, com o sufixo `.original-ptbr`. Não os apague. É possível atualizar as versões anteriores distribuídas neste projeto se os backups originais estiverem presentes. Saves não são alterados pelo instalador. Reserve cerca de 500 MB livres para preparação e backups. O arquivo principal instalado ocupa cerca de 100 MB por usar um contêiner sem compressão.

## Desinstalar

Feche o jogo e execute `Restaurar.cmd`. Os arquivos originais são recuperados e o componente da tradução é removido. Os backups permanecem disponíveis. A verificação de integridade no Steam também pode restaurar os arquivos oficiais, mas não remove necessariamente o componente adicional `PortugueseSupport.dll`; prefira este restaurador.

## Compatibilidade e problemas

- Base verificada: Steam Windows, build **21251852**. A compatibilidade é confirmada pelos hashes dos arquivos, não apenas pelo número da build. Versões diferentes são recusadas antes da instalação.
- “Jogo ainda ativo”: a mensagem informa o PID do processo dessa instalação. Confira a guia Detalhes do Gerenciador de Tarefas. O instalador também verifica se os arquivos estão bloqueados.
- “Backup incompatível”, “Falta o backup” ou “Arquivo desconhecido”: não renomeie arquivos para contornar a verificação. Restaure a instalação pelo Steam e tente novamente; guarde seus backups se precisar de suporte.
- “Pacote incompleto ou alterado”: baixe e extraia novamente o ZIP completo.
- Se o Windows impedir a gravação na biblioteca Steam, confira as permissões da pasta. Atualizações do jogo podem exigir uma nova versão da tradução.

## Estado da beta

Inclui tradução dos recursos textuais, botões de efeitos e rótulos dinâmicos; ajuste automático de texto e correção da abertura de “Como jogar” pelo menu durante a batalha. O título de uma cena interna permanece em inglês para o jogo conseguir abri-la.

A tradução ainda precisa de revisão linguística e de partidas com todas as cartas, personagens, nêmeses e expansões. Não é uma versão final integralmente validada. Notícias e conteúdos carregados de serviços externos podem continuar em inglês. Envie relatos com o texto ou uma captura, resolução da tela, carta/personagem/nêmese e passos para reproduzir.

## Créditos

Jogo, arte, regras, marcas e conteúdo original pertencem aos respectivos titulares; desenvolvimento digital pela Handelabra Games. Projeto comunitário sem vínculo oficial. A base textual utilizou tradução automática do Google Translate; houve ajustes e implementação com auxílio do OpenAI Codex. A revisão humana continua aberta.

O pacote não inclui uma cópia completa do jogo, saves ou credenciais. O código do instalador e do suporte é fornecido para inspeção; nenhuma licença sobre os arquivos do jogo é concedida por este projeto.
