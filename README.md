# Ubuntu Dev Environment Setup Tool

A comprehensive automation script for setting up Ubuntu with development tools, databases, and services. Works on both **WSL2** (Windows) and **OrbStack** (macOS). This tool provides an interactive interface to install and configure your development environment with minimal effort.

## Table of Contents

- [Ubuntu Dev Environment Setup Tool](#ubuntu-dev-environment-setup-tool)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Quick Start](#quick-start)
  - [Environment Configuration](#environment-configuration)
    - [WSL2 (Windows)](#wsl2-windows)
    - [OrbStack (macOS)](#orbstack-macos)
  - [Initial Ubuntu Setup](#initial-ubuntu-setup)
  - [Installation](#installation)
    - [Automated Installation (Recommended)](#automated-installation-recommended)
    - [Manual Installation (Alternative)](#manual-installation-alternative)
    - [Reboot the Environment](#reboot-the-environment)
  - [Available Commands](#available-commands)
    - [Installing Software](#installing-software)
    - [Installing Services](#installing-services)
    - [Configuring Software](#configuring-software)
    - [Managing Services](#managing-services)
    - [LaTeX Dependencies](#latex-dependencies)
    - [Script Version](#script-version)
  - [Available Aliases](#available-aliases)
    - [System Alias](#system-alias)
    - [uv Aliases (Optional)](#uv-aliases-optional)
  - [Additional Documentation](#additional-documentation)
  - [Important Notes](#important-notes)
    - [Reboot Procedure](#reboot-procedure)
    - [Dialog UI Issues](#dialog-ui-issues)
    - [Software Requiring Reboot](#software-requiring-reboot)
    - [Service Configuration](#service-configuration)

## Overview

This repository provides automation scripts to:

- Install development tools (Java, Node.js, Python, C/C++, etc.)
- Set up database systems (MySQL, PostgreSQL, MongoDB, Redis, etc.)
- Configure services (Syncthing, GitHub CLI)
- Manage database services (start/stop)
- Configure development environments

## Quick Start

The simplest way to get started:

```bash
# 1. Clone this repository
git clone https://github.com/zepedrocosta/WslConfig.git
cd WslConfig

# 2. Make the installation script executable and run it
chmod u+x init.sh
./init.sh

# 3. Reboot your environment (see platform-specific instructions below)

# 4. Start using the script with the 'system' alias
system install
```

## Environment Configuration

### WSL2 (Windows)

For optimal performance, configure WSL resource limits. Create or edit `%UserProfile%\.wslconfig` in Windows:

```ini
[wsl2]
memory=20GB
processors=12
swap=50GB
swapfile=C:\\Users\\{YourUsername}\\wsl-swap.vhdx
```

**Note:** Adjust values based on your system resources.

### OrbStack (macOS)

OrbStack creates Ubuntu machines with minimal footprint. Before cloning this repository, install `git` since it is not included in the default Ubuntu image:

```bash
sudo apt-get update && sudo apt-get install -y git
```

Then clone and run the script as usual.

When creating a new OrbStack Linux machine, allocate resources from the OrbStack app (Settings → Resources) or via the CLI:

```bash
orb create ubuntu:noble dev
```

To reconfigure CPU/memory limits for an existing machine, adjust them in **OrbStack → Machines → [machine name] → Settings**.

## Initial Ubuntu Setup

Before installing the script, set proper permissions for your user directory:

```bash
cd /home
sudo chown -R {username} ./{username}
```

Replace `{username}` with your actual username.

## Installation

### Automated Installation (Recommended)

The `init.sh` script handles installation automatically:

```bash
chmod u+x init.sh
./init.sh
```

This script will:

- Copy scripts to `~/.script/`
- Make them executable
- Fix line endings
- Create the `system` alias in your shell configuration
- Support bash, zsh, and fish shells

### Manual Installation (Alternative)

If you prefer manual installation:

1. Copy the script files to a permanent location (e.g., `~/.script/`):

   ```bash
   mkdir -p ~/.script
   cp script.sh ~/.script/
   ```

2. Make the script executable:

   ```bash
   chmod u+x ~/.script/script.sh
   ```

3. Fix line endings (if needed):

   ```bash
   sed -i 's/\r$//' ~/.script/script.sh
   ```

4. Add alias to your shell configuration (`~/.bashrc`, `~/.zshrc`, etc.):

   ```bash
   echo "alias system='$HOME/.script/script.sh'" >> ~/.bashrc
   ```

5. Reload your shell configuration:

   ```bash
   source ~/.bashrc
   ```

### Reboot the Environment

Some installations (Maven, nvm) require a full session restart. How to reboot depends on your platform.

**WSL2** — run from Windows PowerShell or Command Prompt:

```powershell
# List distros to find your distro name
wsl -l -v

# Terminate your distro (reboot)
wsl -t <distro-name>
```

Close all WSL-related applications (terminal, VSCode, File Explorer) before rebooting.

**OrbStack** — run from your Mac terminal or the OrbStack app:

```bash
orb stop dev
orb start dev
```

Alternatively, use the OrbStack menu bar icon to restart the machine.

## Available Commands

All commands use the `system` alias. The general syntax is:

```bash
system <command>
```

### Installing Software

Install development tools and programming languages:

```bash
system install
```

**Available Software:**

- Java 17 (JDK)
- Java 17 Sources
- Maven
- Node Version Manager (nvm)
- pnpm
- GCC & GDB (C/C++ development)
- Make
- uv (Python package manager - see [uv Cheat Sheet](uv_cheat_sheet.md))
- TeX Live
- shfmt (shell script formatter)

**Note:** Some software (Maven, nvm/npm) requires a session restart after installation.

### Installing Services

Install databases and services:

```bash
system install-services
```

**Available Services:**

- **Databases:** MySQL, PostgreSQL, SQLite, Apache Cassandra, MongoDB, Redis, Neo4j
- **Tools:** Syncthing (file synchronization), GitHub CLI, Claude Code, Oh My Posh (prompt theme engine)

#### Oh My Posh Config

Put your own theme in [`oh-my-posh/config.omp.json`](oh-my-posh/config.omp.json) **before** running `./init.sh` — `init.sh` copies it to `~/.script/`, and the installer then offers to:

1. Copy it to `~/.config/oh-my-posh/config.omp.json` (any existing config is backed up to `.bak`)
2. Add `eval "$(oh-my-posh init bash --config "$HOME/.config/oh-my-posh/config.omp.json")"` to your `.bashrc`/`.zshrc`
3. Install a Nerd Font (`oh-my-posh font install`) — required for the prompt icons

If the file is missing, Oh My Posh is installed with its default theme.

**Related Documentation:**

- [Syncthing Setup Guide](syncthing_setup.md) - Setup guide for Syncthing synchronization (WSL-specific; Multipass users should adapt accordingly)
- [Syncthing Backup](syncthing_backup/README.md) - Automatic backup configuration

### Configuring Software

Configure installed software:

```bash
system config
```

**Configuration Options:**

1. **NVM** - Install the latest stable npm version
2. **MySQL** - Run secure installation and set up root password
3. **PostgreSQL** - Set up postgres user password
4. **MariaDB** - Configure database access
5. **Syncthing Auto-Export** - Set up automatic backups on shell startup

**MySQL Configuration Guide:**
After selecting MySQL configuration, you'll be guided through:

- VALIDATE PASSWORD setup (recommended: **no** for local development)
- Root password creation
- Remove Anonymous Users (recommended: **yes**)
- Disallow remote login (recommended: **no** for local development)
- Remove test database (optional)
- Reload privilege tables (recommended: **yes**)
- Set root authentication string

### Managing Services

**Start all installed services:**

```bash
system start
```

**Stop all running services:**

```bash
system stop
```

These commands will start/stop all installed database services:

- MySQL
- PostgreSQL
- MongoDB
- Apache Cassandra
- Redis
- Neo4j
- Syncthing

### LaTeX Dependencies

If you installed TeX Live, install additional LaTeX packages:

```bash
system latex-deps
```

**Available Options:**

- Base version (~216MB)
- Extra version (~452MB)
- Full version (~5358MB)

### Script Version

Check the current version and whether an update is available:

```bash
system script-version
```

This command prints the installed version and queries the GitHub API to compare it against the latest release. If a newer version exists, a warning with the update URL is displayed.

## Available Aliases

### System Alias

The main alias created by the installation script:

```bash
system    # Main script alias (points to ~/.script/script.sh)
```

### uv Aliases (Optional)

If you installed `uv` and chose to add aliases, these are available:

```bash
uvp       # uv run python - Run Python directly
uvr       # uv run - Run a command in venv
uva       # uv add - Add dependency
uvrm      # uv remove - Remove dependency
uvs       # uv sync - Install/update dependencies
uvpl      # uv pip list - List packages
uvl       # uv lock - Generate lockfile
uvpy      # uv python list - List Python versions
```

For detailed uv usage, see the [uv Cheat Sheet](uv_cheat_sheet.md).

## Additional Documentation

This repository includes several guides for specific topics:

- **[uv Cheat Sheet](uv_cheat_sheet.md)** - Quick reference guide for using the `uv` Python package manager, including installation, project management, virtual environments, and useful aliases.

- **[Syncthing Setup](syncthing_setup.md)** - Guide for setting up Syncthing synchronization (written for WSL→Windows; OrbStack users should adapt the host-side steps). Includes configuration for optimal performance with many small files.

- **[Syncthing Backup](syncthing_backup/README.md)** - Automatic backup system for Syncthing configuration on startup. Ensures your Syncthing setup can be easily restored or migrated.

## Important Notes

### Reboot Procedure

Some installations require a full session restart. See the [Reboot the Environment](#reboot-the-environment) section for platform-specific instructions.

### Dialog UI Issues

The interactive selection dialogs may have display issues in full-screen mode. If the UI appears corrupted, **resize the window** to fix it.

### Software Requiring Reboot

These packages require a session restart after installation:

- Maven
- Node Version Manager (nvm/npm)

### Service Configuration

Some services need additional configuration after installation. The script will warn you with:
> "This needs further configuration. Check the tutorial README."

Refer to the [Configuring Software](#configuring-software) section for details.
