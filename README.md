# claude-power-dev.app

Runs [Claude Code](https://claude.com/product/claude-code) against the
[`claude-power-dev`](https://github.com/M4jor-Tom/claude-power-dev) profile, and
supplies every CLI that profile's skills shell out to.

```bash
nix run github:M4jor-Tom/claude-power-dev.app
```

On first run it clones the profile to `~/.claude-power-dev`. On later runs it
fast-forwards that clone, but only when the tree is clean — local edits are
never clobbered — and only when `origin` still points at this profile's own
repo, so pointing `CLAUDE_POWER_DEV_DIR` at a fork or an unrelated checkout
gets no pulls. Override the location with `CLAUDE_POWER_DEV_DIR`.

This app is a convenience, not a requirement. The profile works on its own:

```bash
CLAUDE_CONFIG_DIR=~/.claude-power-dev claude
```

## What it ships

`claude-code git gh glab nodejs bun pnpm ripgrep fd jq yq-go uv python3 sqlite
curl imagemagick rtk graphify markitdown pandoc poppler-utils yt-dlp`, plus
`chromium` on Linux — nixpkgs doesn't build it for Darwin.

`nixpkgs#claude-code` already sets `DISABLE_AUTOUPDATER=1`,
`DISABLE_INSTALLATION_CHECKS=1` and `USE_BUILTIN_RIPGREP=0`, defaults
`FORCE_AUTOUPDATE_PLUGINS=1`, and always puts `ripgrep` and `procps` on Claude
Code's own PATH, plus `bubblewrap` and `socat` there too on Linux. The flake
allows unfree packages for its own nixpkgs, because `claude-code` is unfree —
without that, `nix run` would fail before building anything.

## Plugins on a fresh clone

The profile declares its marketplaces in `settings.json`
(`extraKnownMarketplaces`) and its plugins in `enabledPlugins`. Claude Code
clones a declared-but-missing marketplace and downloads its enabled plugins in
the background *after* the session starts, so on a brand-new machine log in
first and the plugins follow. There is no flag that forces this sooner —
starting the session is what triggers it.

## Deliberately absent

`playwright-driver` is not shipped: the `playwright-cli` skill installs
`@playwright/cli` through npm and manages its own browsers. `chromium` *is*
shipped on Linux, because the playwright MCP server, claude-mem's
`wowerpoint` and ui-ux-pro-max's image export all need a browser, and
Playwright's own download segfaults on NixOS. nixpkgs has no `chromium` for
Darwin, so those skills need a browser from somewhere else there.

One thing this wrapper cannot fix: `claude-mem`'s hooks prepend `~/.nvm/…`,
`~/.local/bin`, `/usr/local/bin` and `/opt/homebrew/bin` to PATH, so a stray
`node` or `bun` in one of those outranks the Nix one.
