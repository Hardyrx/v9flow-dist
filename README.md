# v9flow-dist

Distribuição do V9 Flow para membros. Repositório separado do `v9vision-dist`: publicar um app não mexe no outro.

Tudo aqui é **cifrado**: o pacote do app (`app.v9pkg`) só abre com um login de membro válido. O que é público é só a
lista de membros (`membros.json`), que guarda a chave de cada um trancada com a senha dele.

- `latest.json`: versão atual do app (vem do arquivo `VERSAO` do v9-flow) e a soma de conferência do pacote.
- `app.v9pkg`: o app, cifrado.
- `membros.json`: lista de membros (as senhas não ficam aqui).

Quem instala usa o `Instalar-V9Flow.bat` que recebeu do administrador. Depois disso o V9 Flow se atualiza sozinho
cada vez que é aberto, lendo o `latest.json` daqui.

Para publicar uma versão nova: aumente o número em `v9-flow/VERSAO` e rode `v9-flow/PUBLICAR-V9FLOW.bat`.
