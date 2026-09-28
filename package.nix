{ lib
, writeShellApplication
, claude-code
, git
, gh
, glab
, nodejs
, bun
, pnpm
, ripgrep
, fd
, jq
, yq-go
, uv
, python3
, sqlite
, curl
, chromium
, imagemagick
, rtk
, graphify
, markitdown
, pandoc
, poppler-utils
, yt-dlp
  # Which profile this wrapper runs. claude-game-dev.app reuses this file with
  # the game-dev values.
, profileName ? "claude-power-dev"
, configRepo ? "https://github.com/M4jor-Tom/claude-power-dev.git"
, dirEnvVar ? "CLAUDE_POWER_DEV_DIR"
}:

writeShellApplication {
  name = profileName;

  runtimeInputs = [
    claude-code
    git
    gh
    glab
    nodejs
    bun
    pnpm
    ripgrep
    fd
    jq
    yq-go
    uv
    python3
    sqlite
    curl
    chromium
    imagemagick
    rtk
    graphify
    markitdown
    pandoc
    poppler-utils
    yt-dlp
  ];

  # The config repo is a git working tree, never a store symlink: Claude Code
  # writes settings.local.json, sessions and the plugin cache next to the
  # tracked config, so that directory has to stay writable.
  text = ''
    DIR="''${${dirEnvVar}:-$HOME/.${profileName}}"

    if [ ! -e "$DIR" ]; then
      echo "${profileName}: cloning ${configRepo} -> $DIR" >&2
      # --recursive: claude-game-dev's skills/ are symlinks into vendor/
      # submodules, and a flat clone leaves 69 of them dangling.
      git clone --recursive "${configRepo}" "$DIR"
    elif [ -d "$DIR/.git" ] \
      && [ "$(git -C "$DIR" remote get-url origin 2>/dev/null)" = "${configRepo}" ] \
      && [ -z "$(git -C "$DIR" status --porcelain)" ]; then
      # Clean tree, and only a checkout of this profile's own repo. A dirty
      # tree keeps its local edits, always; an unrelated checkout is never
      # touched.
      if git -C "$DIR" pull --ff-only --quiet; then
        git -C "$DIR" submodule update --init --recursive --quiet \
          || echo "${profileName}: submodule update failed" >&2
      else
        echo "${profileName}: pull failed, using the local checkout" >&2
      fi
    fi

    export CLAUDE_CONFIG_DIR="$DIR"
    exec claude "$@"
  '';

  meta = {
    description = "Claude Code running the ${profileName} profile";
    homepage = "https://github.com/M4jor-Tom/${profileName}.app";
    mainProgram = profileName;
    platforms = lib.platforms.unix;
  };
}
