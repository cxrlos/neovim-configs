# neovim-configs

Neovim 0.12 config, rebuilt from defaults in 2026: `vim.pack` with a lockfile, built-in LSP and
completion, treesitter, fzf-lua, oil, gitsigns + Neogit + diffview, conform, Tokyo Night.
Made for reviewing code an agent writes in a neighbouring tmux window.

Install the tools with [term-configs](https://github.com/cxrlos/term-configs) `install.sh`, then
(macOS or Linux):

    ./install.sh          # links ~/.config/nvim, installs plugins (lockfile) and parsers
    ./install.sh --check  # report only

Keys: press `<Space>` and wait for the hint window, or `<Space>sk` to search every mapping.
Layout and rules: [AGENTS.md](AGENTS.md).
