# AI

## Keybindings

> Populated in Phase 11 (codecompanion + Claude)

| Key          | Action                             |
| ------------ | ---------------------------------- |
| `<leader>a*` | AI operations (coming in Phase 11) |

## About

AI integration uses codecompanion.nvim with Claude (Anthropic API). Key design decisions:

- **No autocomplete** — Claude is a thinking tool, not a ghost-text engine
- **On-demand only** — AI only activates when explicitly invoked
- **Project context** — codecompanion can attach multiple open buffers and project files to a chat session, giving Claude full awareness of the codebase
- **API key** — stored outside the repo, never committed. Set via environment variable or a local config file excluded from git.
