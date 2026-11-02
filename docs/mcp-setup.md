# MCP servers

MCP servers live in `~/.claude.json`, not `settings.json`, so `install.sh` doesn't set them up.
Add them once per machine, at user scope so they work in every project.

| Server | What it gives Claude | Needs |
|---|---|---|
| context7 | Current, version-specific library docs | Node (`npx`) |
| serena | Symbol-level code navigation (find symbol, references) | `uv` (`brew install uv`) |

```sh
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest
claude mcp add --scope user serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context claude-code --project-from-cwd
```

Check with `claude mcp list`.

Not used: the GitHub MCP server (`gh` does the same with its own login), Figma.
