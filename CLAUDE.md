# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Bash-based automation tool for setting up and managing Ubuntu development environments on **WSL2** (Windows) and **Multipass** (macOS/Linux). It provides an interactive CLI (using `dialog`) for installing dev tools, databases, and services.

**Installation:**

```bash
chmod u+x init.sh
./init.sh        # Installs to ~/.script/ and adds 'system' alias to shell config
```

After installation, restart the environment:

- **WSL2**: `wsl -t <distro-name>` from PowerShell
- **Multipass**: `multipass stop <instance> && multipass start <instance>`

## Main Commands

All commands use the `system` alias (points to `~/.script/script.sh`):

```bash
system install           # Interactive install: Java 17/21, Maven, nvm, pnpm, GCC, Make, uv, TeX Live, shfmt
system install-services  # Interactive install: MySQL, PostgreSQL, SQLite, Cassandra, MongoDB, Redis, Neo4j, Syncthing, GitHub CLI, Firefox, Claude Code, Oh My Posh
system config            # Configure installed tools (nvm npm, MySQL/PostgreSQL/MariaDB, Syncthing auto-export)
system start             # Start all installed services
system stop              # Stop all installed services
system latex-deps        # Install LaTeX packages (base/extra/full)
system java-switcher     # Interactive Java version switcher (updates JAVA_HOME in .bashrc)
system clean-zone        # Remove Zone.Identifier files recursively in a given directory
system script-version    # Print current version and check GitHub for newer releases
```

## Architecture

### `init.sh`

One-time installer: copies `script.sh` to `~/.script/`, fixes line endings, adds `system` alias to bash/zsh/fish config.

### `script.sh` (the main engine)

Single-file Bash script (~620 lines) organized as:

- **Helper functions** at the top: `update()`, `success()`/`error()`/`warn()`/`info()` (colored output), `timer()`, `missing()` (checks if a package is installed), `run()` (runs install command only if package is missing)
- **Command handlers** as `case` branches on `$1`: each branch uses `dialog` for interactive checklists/menus, then calls `run()` for each selected package
- **Service management** (`start`/`stop`): iterates over installed services using `missing()` to skip uninstalled ones
- **Java switcher**: scans `/usr/lib/jvm/` for installed JDKs, skips `java-1.*` legacy dirs, updates JAVA_HOME via `sed` in `.bashrc`
- **Syncthing auto-export**: configured via `system config`, adds a startup hook in `.bashrc`

### `oh-my-posh/config.omp.json`

User-supplied Oh My Posh theme, copied to `~/.script/` by `init.sh` and offered during `system install-services` (option 11). The script resolves it via `$OMP_CONFIG_SRC` (based on `$SCRIPT_DIR`), copies it to `$OMP_CONFIG_DEST` (`~/.config/oh-my-posh/config.omp.json`), and writes a matching `oh-my-posh init --config` line into the shell rc. Absent file = default theme.

### `syncthing_backup/script.sh`

Standalone backup script run at shell startup. Creates timestamped tar.gz backups of Syncthing config in `~/syncthing-backups/`, retaining the 10 most recent. Deduplicates by checking if a backup already exists for today's date.

### `.github/workflows/release.yml`

Release automation. On a push to `main` that touches `script.sh` (or via manual `workflow_dispatch`), it reads `SCRIPT_VERSION` from the top of `script.sh`, validates it looks like `vMAJOR.MINOR.PATCH`, and creates a GitHub release tagged with exactly that value via `softprops/action-gh-release@v2`, with a body built from `git log` since the previous semver tag plus a compare link. If the tag or release already exists, the run is a no-op — so pushing unrelated `script.sh` changes is safe, and cutting a release means bumping `SCRIPT_VERSION` in a commit to `main`. The tag must match `SCRIPT_VERSION` verbatim because `system script-version` compares `tag_name` from `releases/latest` against it with a string equality test.

## Key Patterns

- `missing <package>` returns 0 if NOT installed (name is counterintuitive — it checks if the package is "missing")
- `run <description> <install-command>` skips the install if the package is already present
- All installs go through `apt-get` (non-interactive mode)
- `dialog --checklist` for multi-select, `dialog --radiolist` for single-select; result captured via stderr redirect
- Java 17/21 installs use `openjdk-17-jdk`/`openjdk-21-jdk` and `openjdk-17-source`/`openjdk-21-source`
- Services use `/etc/init.d/` or `service` rather than `systemctl` (compatible with both WSL2 and Multipass where systemd may not be the default)

## Important Notes

- Some installs (Maven, nvm/npm) require a session restart to take effect
- The `dialog` UI can appear corrupted in full-screen mode — resize the terminal window to fix
- `system config` MySQL setup walks through `mysql_secure_installation`; for local dev, VALIDATE PASSWORD is recommended **no**
- Releases are cut from `SCRIPT_VERSION` in `script.sh` — bump it (keeping the leading `v`) and merge to `main` to publish a new release
