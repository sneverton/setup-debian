# setup-debian

Automacao de setup para Debian 13 Trixie em maquinas headless de desenvolvimento.

## O que instala

- Pacotes base de terminal e build
- Python 3, pip, venv e pipx
- Zsh, Oh My Zsh e plugins
- Neovim, tmux e dotfiles versionados
- Node.js LTS via `n`
- pnpm, Codex CLI, Claude Code e GitHub Copilot CLI
- Docker Engine com Compose plugin
- GitHub CLI, DigitalOcean CLI e LazyGit

## Como usar

```bash
git clone <repo> setup-debian
cd setup-debian
./install.sh
```

## Variaveis uteis

- `SETUP_DEBIAN_DRY_RUN=1`: mostra as acoes sem executar instalacoes.
- `SETUP_DEBIAN_SKIP_AUTH=1`: pula o modulo interativo de autenticacao.
- `SETUP_DEBIAN_MODULES=base,dotfiles`: roda apenas os modulos informados.
- `SETUP_DEBIAN_ALLOW_NON_DEBIAN=1`: permite testes fora do Debian real.
- `SETUP_DEBIAN_FORCE_OS_ID`, `SETUP_DEBIAN_FORCE_OS_VERSION_ID`, `SETUP_DEBIAN_FORCE_ARCH`: fixam o ambiente para testes.

## Pos-instalacao

- Abra uma nova sessao para aplicar `chsh` e o grupo `docker`.
- Rode novamente `./install.sh` se quiser reaplicar dotfiles ou concluir autenticacoes.
- Use `SETUP_DEBIAN_SKIP_AUTH=1` em ambientes nao interativos.
