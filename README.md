# setup-linux

Automacao de setup para Debian 13 Trixie e Ubuntu em maquinas headless de desenvolvimento.

## O que instala

- Pacotes base de terminal e build
- Python 3, pip, venv e pipx
- Zsh, Oh My Zsh e plugins
- Neovim, tmux e dotfiles versionados
- Node.js e npm na ultima versao estavel via `n`
- pnpm, Codex CLI, Claude Code e GitHub Copilot CLI
- Docker Engine com Compose plugin
- GitHub CLI, DigitalOcean CLI e LazyGit

## Como usar

```bash
git clone <repo> setup-linux
cd setup-linux
./install.sh
```

O `install.sh` detecta Debian ou Ubuntu automaticamente.

## Variaveis uteis

- `SETUP_LINUX_DRY_RUN=1`: mostra as acoes sem executar instalacoes.
- `SETUP_LINUX_MODULES=base,dotfiles`: roda apenas os modulos informados.
- `SETUP_LINUX_INTERACTIVE=1`: força o menu interativo de selecao de modulos.
- `SETUP_LINUX_ALLOW_NON_DEBIAN=1`: permite testes fora do Debian real.
- `SETUP_LINUX_FORCE_OS_ID`, `SETUP_LINUX_FORCE_OS_VERSION_ID`, `SETUP_LINUX_FORCE_OS_VERSION_CODENAME`, `SETUP_LINUX_FORCE_ARCH`: fixam o ambiente para testes.

## Pos-instalacao

- Abra uma nova sessao para aplicar `chsh` e o grupo `docker`.
- Rode novamente `./install.sh` se quiser reaplicar dotfiles.
- Faca login manualmente apenas quando precisar usar cada ferramenta:
  - `gh auth login`
  - `copilot login`
  - `codex --login`
  - `claude`
  - `doctl auth init`
