# MCP servers

MCP servers live in `~/.claude.json`, not `settings.json`, so `install.sh` doesn't set them up.
Add them once per machine, at user scope so they work in every project.

| Server | What it gives Claude | Needs |
|---|---|---|
| context7 | Current, version-specific library docs | Node (`npx`) |
| serena | Symbol-level code navigation (find symbol, references) | `uv` (`brew install uv`) |

```sh
uv tool install -p 3.13 serena-agent   # installs `serena` into ~/.local/bin
serena init                            # creates ~/.serena/serena_config.yml
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest
claude mcp add --scope user serena -- serena start-mcp-server --context claude-code --project-from-cwd
```

Check with `claude mcp list`, also from a non-interactive login shell (`zsh -lc 'claude mcp list'`):
apps start MCP servers that way, so `npx` must be on PATH there too, not only in `.zshrc`.

Not used: the GitHub MCP server (`gh` does the same with its own login), Figma.
