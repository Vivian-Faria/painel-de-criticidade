# Painel de Criticidade Orion

Painel estatico com atualizacao automatica do arquivo `dados_orion.json` a partir do Orion.

## Estrutura

- `index.html`: interface publicada
- `dados_orion.json`: dados consumidos pelo painel
- `orion_scraper_1.py`: coleta os dados no Orion e atualiza os arquivos
- `deploy-netlify/`: copia dos arquivos usados no deploy estatico
- `iniciar_painel.bat`: inicializacao local do scraper + servidor HTTP

## Execucao local

1. Crie um arquivo `.env` com base em `.env.example`
2. Instale dependencias:

```bash
pip install -r requirements.txt
python -m playwright install chromium
```

3. Inicie o painel localmente:

```bat
iniciar_painel.bat
```

## Publicacao no GitHub

Crie o repositorio como **privado** e envie estes arquivos.

Depois, configure estes Secrets no repositorio:

- `ORION_EMAIL`
- `ORION_SENHA`

O workflow em `.github/workflows/atualizar-painel.yml` executa o scraper em horario agendado, atualiza:

- `dados_orion.json`
- `deploy-netlify/dados_orion.json`

Se o HTML precisar ser regenerado, ele tambem sincroniza:

- `index.html`
- `deploy-netlify/index.html`

Protecao importante:

- se a coleta remota retornar `0` pedidos por falha de login, seletor ou bloqueio do ambiente do GitHub Actions, o scraper interrompe a execucao e preserva o ultimo JSON valido, evitando publicar um painel zerado por engano.

## Automacao local definitiva

O fluxo recomendado e local:

1. o Windows roda `publicar_painel.bat` por agendamento
2. o script coleta dados novos via `orion_scraper_1.py`
3. valida se o JSON nao veio vazio
4. faz `git pull --rebase`
5. publica no GitHub so quando houver mudanca
6. o Netlify redeploya automaticamente a branch `main`

Arquivos da automacao:

- `publicar_painel.bat`: ponto de entrada para execucao manual ou agendada
- `scripts/publicar_painel.ps1`: coleta, valida, commit e push
- `scripts/instalar_tarefa_publicacao.ps1`: cria/atualiza a tarefa agendada do Windows

Para instalar a tarefa agendada:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\instalar_tarefa_publicacao.ps1
```

Logs locais ficam em `logs/publicacao-painel.log`.

## Deploy

Se o deploy estiver no Netlify, use `deploy-netlify/` como pasta publicada.
