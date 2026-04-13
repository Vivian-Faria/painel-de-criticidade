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

## Deploy

Se o deploy estiver no Netlify, use `deploy-netlify/` como pasta publicada.
