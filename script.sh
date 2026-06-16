#!/bin/bash

: '
	@Author: Gonçalo Condeço - https://github.com/GoncaloAC
	@Author: José Costa      - https://github.com/zepedrocosta

	Credits - As I wrote this file, some installers were taken from tutorials.

	MySQL - https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-database#install-mysql
	PostgresSQL - https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-database#install-postgresql
	SQLite - https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-database#install-sqlite
	Apache Cassandra - https://www.varunsrivatsa.dev/blog/cassandra-installation/how-to-install-cassandra-4-on-windows/
	MongoDB - https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-database#install-mongodb
	Redis - https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-database#install-redis
	Neo4j - https://github.com/lqst/neo4j-wsl2

    https://www.vultr.com/docs/install-apache-cassandra-on-ubuntu-20-04/
    https://github.com/redhat-developer/vscode-java/issues/689
    https://gist.github.com/Nathan-Nesbitt/97e2c466cfdb74f4322c2678551eb93e
    https://stackoverflow.com/questions/36433835/getting-cassandra-to-use-an-alternate-java-install
'

SCRIPT_VERSION="v2.0.0"
GITHUB_REPO="zepedrocosta/WSL-Orbstack-Config"

RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
ORANGE="\033[0;33m"
NONE="\033[0m"

CONT="Continuing installation in"
INST="Installing now"
WARN="This needs further configuration. Check the tutorial README."
RUN=" is now running."
STOP=" is now stopped."
NOP=" is not installed."

me=$USER
ARCH=$(dpkg --print-architecture)

update() {
	info "Updating Ubuntu..."
	sudo -i apt-get update
	sudo apt-get upgrade -y
	success "Ubuntu Updated Successfully!" &
	sleep 2
}

success() {
	echo -e "${GREEN}$1${NONE}"
}

error() {
	echo -e "${RED}$1${NONE}"
}

warn() {
	echo -e "${YELLOW}$1${NONE}"
}

info() {
	echo -e "${CYAN}$1${NONE}"
}

help() {
	echo -e "${CYAN}Usage:${NONE} system <command>\n"
	echo -e "${GREEN}Available commands:${NONE}"
	echo -e "  ${YELLOW}install${NONE}           Install dev tools (Java, Maven, nvm, pnpm, GCC, uv, TeX Live, shfmt, wget)"
	echo -e "  ${YELLOW}install-services${NONE}  Install services (MySQL, PostgreSQL, MongoDB, Redis, Cassandra, Neo4j, Syncthing, GitHub CLI, Firefox, Claude Code)"
	echo -e "  ${YELLOW}config${NONE}            Configure installed tools (npm, MySQL/PostgreSQL/MariaDB, Syncthing auto-export)"
	echo -e "  ${YELLOW}start${NONE}             Start all installed services"
	echo -e "  ${YELLOW}stop${NONE}              Stop all installed services"
	echo -e "  ${YELLOW}latex-deps${NONE}        Install LaTeX packages (base / extra / full)"
	echo -e "  ${YELLOW}java-switcher${NONE}     Interactively switch Java version and update JAVA_HOME"
	echo -e "  ${YELLOW}clean-zone${NONE}        Remove Zone.Identifier files recursively in a given directory (WSL command)"
	echo -e "  ${YELLOW}connect-docker${NONE}    Connect to the docker socket on host. This uses the Docker Desktop default socket."
	echo -e "  ${YELLOW}script-version${NONE}    Print current version and check GitHub for newer releases"
	echo -e "  ${YELLOW}help${NONE}              Show this help message"
}

timer() {
	secs=4
	while [ $secs -gt 0 ]; do
		echo -ne "${CYAN}$1 ${ORANGE}$secs\033[O\r${NONE}" && sleep 1
		((secs--))
	done
	echo -e "${CYAN}$1 ${ORANGE}0\033[0K\r${NONE}" && echo -e "${GREEN}$2${NONE}"
}

missing() {
	dpkg -s $1 &>/dev/null
	if [ $? -eq 0 ]; then
		return 1
	else
		return 0
	fi
}

run() {
	if missing "$1"; then
		error "$2$3"
	else
		$5 >/dev/null 2>&1 && info "$2$4"
	fi
}

case $1 in
install)
	update
	if missing "dialog"; then
		info "Installing Dialog" && sudo -i apt install dialog
	fi
	cmd=(dialog --separate-output --checklist "Please Select Software you want to install:" 22 76 16)
	options=(
		1 "Java 17" off
		2 "Java 17 Sources" off
		3 "Java 21" off
		4 "Java 21 Sources" off
		5 "Maven" off
		6 "Node Version Manager (nvm)" off
		7 "pnpm" off
		8 "GCC & GDB" off
		9 "Makefile" off
		10 "uv - Python package and project manager" off
		11 "TeX Live" off
		12 "wget" off
		13 "shfmt - Shell script formatter (wget is necessary)" off
	)
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	clear
	for choice in $choices; do
		case "${choice}" in
		1)
			update && timer "$CONT" "$INST Java 17"
			sudo apt-get install openjdk-17-jdk -y
			echo >>~/.bashrc
			echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-${ARCH}" >>~/.bashrc
			success "Java 17 installed successfully!"
			;;
		2)
			update && timer "$CONT" "$INST Java 17 sources"
			sudo apt-get install openjdk-17-source -y
			success "Java 17 sources installed successfully!"
			;;
		3)
			update && timer "$CONT" "$INST Java 21"
			sudo apt-get install openjdk-21-jdk -y
			echo >>~/.bashrc
			echo "export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-${ARCH}" >>~/.bashrc
			success "Java 21 installed successfully!"
			;;
		4)
			update && timer "$CONT" "$INST Java 21 sources"
			sudo apt-get install openjdk-21-source -y
			success "Java 21 sources installed successfully!"
			;;
		5)
			update && timer "$CONT" "$INST Maven"
			sudo apt install maven
			success "Maven installed successfully!"
			;;
		6)
			update && timer "$CONT" "$INST Node Version Manager (nvm)"
			sudo apt-get install curl
			curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
			warn "$WARN" && success "NVM installed successfully!"
			;;
		# pnpm
		7)
			update && timer "$CONT" "$INST pnpm"
			curl -fsSL https://get.pnpm.io/install.sh | sh -
			success "pnpm installed successfully!"
			info "You may need to restart your terminal or source your shell config to use pnpm"
			;;
		# GCC & GDB
		8)
			update && timer "$CONT" "$INST GCC & GDB"
			sudo apt install gcc gdb -y
			success "GCC & GDB installed successfully!"
			;;
		# Make
		9)
			update && timer "$CONT" "$INST Make"
			sudo apt install make
			success "Make installed successfully!"
			;;
		# uv https://github.com/astral-sh/uv
		10)
			update && timer "$CONT" "$INST uv"
			if ! curl -LsSf https://astral.sh/uv/install.sh | sh; then
				echo "uv installation failed!"
				exit 1
			fi
			uv self update
			success "uv installed successfully!"
			cmd=(dialog --radiolist "Do you want to add the aliases? (Check uv_cheat_sheet.md)" 22 76 16)
			options=(
				1 "Yes" off
				2 "No" off
			)
			choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
			for choice in $choices; do
				case "${choice}" in
				1)
					SHELL_RC="$HOME/.bashrc"
					[ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"

					# Only add aliases if not already present
					if ! grep -q "alias uvp=" "$SHELL_RC"; then
						{
							echo 'alias uvp="uv run python"   # run Python directly'
							echo 'alias uvr="uv run"         # run a command in venv'
							echo 'alias uva="uv add"         # add dependency'
							echo 'alias uvrm="uv remove"     # remove dependency'
							echo 'alias uvs="uv sync"        # install/update deps'
							echo 'alias uvpl="uv pip list"   # list packages'
							echo 'alias uvl="uv lock"        # generate lockfile'
							echo 'alias uvpy="uv python list"'
						} >>"$SHELL_RC"

						echo "Aliases added to $SHELL_RC"
						echo "Run 'source $SHELL_RC' or restart your shell to use them."
					else
						echo "Aliases already exist in $SHELL_RC, skipping."
					fi
					;;
				2) ;;
				esac
			done
			cmd=(dialog --radiolist "Do you want to install black (Python formatter)?" 22 76 16)
			options=(
				1 "Yes" off
				2 "No" off
			)
			choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
			for choice in $choices; do
				case "${choice}" in
				1)
					uv tool install black
					uv tool update-shell
					success "Black installed successfully!"
					;;
				2) ;;
				esac
			done

			;;
		# TeX Live
		11)
			update && timer "$CONT" "$INST TeX Live"
			sudo apt install texlive
			success "TeX Live installed successfully!"
			info "Run 'system latex-deps' to install LaTeX dependencies"
			;;
		# wget
		12)
			update && timer "$CONT" "$INST wget"
			sudo apt-get install wget -y
			success "wget installed successfully!"
			;;
		# shfmt https://github.com/mvdan/sh
		13)
			update && timer "$CONT" "$INST shfmt"
			SHFMT_VERSION=$(curl -s https://api.github.com/repos/mvdan/sh/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
			ARCH=$(dpkg --print-architecture)
			if [ "$ARCH" = "amd64" ]; then
				wget https://github.com/mvdan/sh/releases/download/${SHFMT_VERSION}/shfmt_${SHFMT_VERSION}_linux_amd64 -O /tmp/shfmt
			elif [ "$ARCH" = "arm64" ]; then
				wget https://github.com/mvdan/sh/releases/download/${SHFMT_VERSION}/shfmt_${SHFMT_VERSION}_linux_arm64 -O /tmp/shfmt
			else
				error "Unsupported architecture: $ARCH"
				exit 1
			fi
			sudo mv /tmp/shfmt /usr/local/bin/shfmt
			sudo chmod +x /usr/local/bin/shfmt
			success "shfmt installed successfully!"
			;;

		esac
	done
	success "Installation finished successfully!"
	;;
install-services)
	update
	if missing "dialog"; then
		info "Installing Dialog" && sudo -i apt install dialog
	fi
	cmd=(dialog --separate-output --checklist "Please Select Services you want to install:" 22 76 16)
	options=(
		1 "MySQL" off
		2 "PostgresSQL" off
		3 "SQLite" off
		4 "Apache Cassandra" off
		5 "MongoDB" off
		6 "Redis" off
		7 "Neo4j" off
		8 "Syncthing" off
		9 "GitHub CLI" off
		10 "Claude Code" off
	)
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	clear
	for choice in $choices; do
		case "${choice}" in
		1)
			update && timer "$CONT" "$INST MySQL"
			sudo apt install mysql-server -y
			warn "$WARN" && success "MySQL installed successfully!"
			;;
		2)
			update && timer "$CONT" "$INST PostgresSQL"
			sudo apt install postgresql postgresql-contrib -y
			warn "$WARN" && success "PostgresSQL installed successfully!"
			;;
		3)
			update && timer "$CONT" "$INST SQLite"
			sudo apt install sqlite3
			success "SQLite installed successfully!"
			;;
		4)
			update && timer "$CONT" "$INST Apache Cassandra"
			sudo apt install apt-transport-https gnupg2 -y
			wget -q -O - https://downloads.apache.org/cassandra/KEYS | sudo gpg --dearmor -o /usr/share/keyrings/cassandra-archive-keyring.gpg
			echo "deb [signed-by=/usr/share/keyrings/cassandra-archive-keyring.gpg] https://debian.cassandra.apache.org 40x main" | sudo tee /etc/apt/sources.list.d/cassandra.list
			sudo apt-get update
			sudo apt-get install cassandra -y
			success "Apache Cassandra installed successfully!"
			;;
		5)
			update && timer "$CONT" "$INST MongoDB"
			UBUNTU_CODENAME=$(lsb_release -cs)
			curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
			echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu ${UBUNTU_CODENAME}/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
			sudo apt-get update && sudo apt-get install mongodb-org -y && mkdir -p ~/data/db
			curl https://raw.githubusercontent.com/mongodb/mongo/master/debian/init.d | sudo tee /etc/init.d/mongodb >/dev/null
			sudo chmod +x /etc/init.d/mongodb
			success "MongoDB installed successfully!"
			;;
		6)
			update && timer "$CONT" "$INST Redis"
			sudo apt install redis-server -y
			success "Redis installed successfully!"
			;;
		7)
			update && timer "$CONT" "$INST Neo4j"
			wget -O - https://debian.neo4j.com/neotechnology.gpg.key | sudo apt-key add -
			echo 'deb https://debian.neo4j.com stable latest' | sudo tee -a /etc/apt/sources.list.d/neo4j.list
			sudo apt-get update
			sudo apt-get install neo4j-enterprise -y
			success "Neo4j installed successfully!"
			;;
		8)
			update && timer "$CONT" "$INST Syncthing"
			sudo apt install syncthing -y
			success "Syncthing installed successfully!"
			cmd=(dialog --radiolist "Do you want to enable Syncthing to start automatically?" 22 76 16)
			options=(
				1 "Yes" off
				2 "No" off
			)
			choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
			for choice in $choices; do
				case "${choice}" in
				1)
					syncthing -generate
					systemctl --user enable syncthing
					systemctl --user start syncthing
					success "Syncthing enabled and started!"
					;;
				2)
					info "Syncthing not enabled. Run 'systemctl --user enable syncthing' to enable it later."
					;;
				esac
			done
			info "Access GUI at http://localhost:8384"
			warn "Check syncthing_setup.md for configuration details"
			;;
		# GitHub CLI
		9)
			update && timer "$CONT" "$INST GitHub CLI"
			sudo apt install gh -y
			success "GitHub CLI installed successfully!"
			;;
		# Claude Code
		10)
			update && timer "$CONT" "$INST Claude Code"
			sudo apt-get install curl
			curl -fsSL https://claude.ai/install.sh | bash
			success "Claude Code installed successfully!"
			;;
		esac
	done
	success "Services installation finished successfully!"
	;;
config)
	update
	if missing "dialog"; then
		info "Installing Dialog" && sudo -i apt install dialog
	fi
	cmd=(dialog --separate-output --checklist "Please Select Software you want to configure:" 22 76 16)
	options=(
		1 "Install latest stable npm with nvm" off
		2 "Configure MySQL" off
		3 "Configure PostgresSQL" off
		4 "Configure MariaDB" off
		5 "Setup Syncthing Auto-Export on Startup" off
	)
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	for choice in $choices; do
		case "${choice}" in
		1)
			clear && timer "$CONT" "$INST NPM"
			source ~/.nvm/nvm.sh && nvm install --lts
			success "NPM configured successfully!"
			;;
		2)
			clear && timer "$CONT" "$INST MySQL"
			sudo /etc/init.d/mysql start
			sudo mysql_secure_installation && sudo mysql
			success "MySQL configured successfully!"
			;;
		3)
			clear && timer "$CONT" "$INST PostgresSQL"
			sudo passwd postgres
			success "PostgresSQL configured successfully!"
			;;
		4)
			clear && timer "$CONT" "$INST MariaDB"
			sudo /etc/init.d/mysql start
			sudo mysql_secure_installation && sudo mariadb
			success "MariaDB configured successfully!"
			;;
		5)
			clear
			info "Setting up Syncthing Auto-Export..."

			# Check if syncthing is installed
			if ! command -v syncthing >/dev/null 2>&1; then
				error "Syncthing is not installed. Please install it first."
				exit 1
			fi

			# Get the directory where this script is located
			SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
			EXPORT_SCRIPT="$SCRIPT_DIR/syncthing_backup/script.sh"

			# Check if source script exists
			if [ ! -f "$EXPORT_SCRIPT" ]; then
				error "Syncthing backup script not found at: $EXPORT_SCRIPT"
				exit 1
			fi

			# Make it executable
			chmod +x "$EXPORT_SCRIPT"

			# Add to .bashrc if not already present
			BASHRC_LINE="$EXPORT_SCRIPT >/dev/null 2>&1 & disown"
			if ! grep -q "syncthing_backup/script.sh" "$HOME/.bashrc"; then
				echo "" >>"$HOME/.bashrc"
				echo "# Syncthing auto-export on startup" >>"$HOME/.bashrc"
				echo "$BASHRC_LINE" >>"$HOME/.bashrc"
				success "Syncthing auto-export setup completed!"
				info "Backup script: $EXPORT_SCRIPT"
				info "Backups location: $HOME/syncthing-backups"
				info "The script will run automatically on shell startup"
				warn "Run 'source ~/.bashrc' or restart your session to activate"
			else
				warn "Syncthing auto-export already configured in .bashrc"
				info "Using script at: $EXPORT_SCRIPT"
			fi
			;;
		esac
	done
	success "Configuration finished successfully!"
	;;
# Start services
start)
	run "mysql-server" "MySQL" "${NOP}" "${RUN}" "sudo /etc/init.d/mysql start"
	run "postgresql" "PostgresSQL" "${NOP}" "${RUN}" "sudo service postgresql start"
	run "mongodb-org" "MongoDB" "${NOP}" "${RUN}" "sudo service mongodb start"
	run "cassandra" "Apache Cassandra" "${NOP}" "${RUN}" "sudo service cassandra start"
	run "redis-server" "Redis" "${NOP}" "${RUN}" "sudo service redis-server start"
	run "neo4j-enterprise" "Neo4j" "${NOP}" "${RUN}" "sudo service neo4j start"
	run "syncthing" "Syncthing" "${NOP}" "${RUN}" "systemctl --user start syncthing"
	;;
# Stop services
stop)
	run "mysql-server" "MySQL" "${NOP}" "${STOP}" "sudo /etc/init.d/mysql stop"
	run "postgresql" "PostgresSQL" "${NOP}" "${STOP}" "sudo service postgresql stop"
	run "mongodb-org" "MongoDB" "${NOP}" "${STOP}" "sudo service mongodb stop"
	run "cassandra" "Apache Cassandra" "${NOP}" "${STOP}" "sudo service cassandra stop"
	run "redis-server" "Redis" "${NOP}" "${STOP}" "sudo service redis-server stop"
	run "neo4j-enterprise" "Neo4j" "${NOP}" "${STOP}" "sudo service neo4j stop"
	run "syncthing" "Syncthing" "${NOP}" "${STOP}" "systemctl --user stop syncthing"
	;;
# LaTeX dependencies
# https://tex.stackexchange.com/questions/245982/differences-between-texlive-packages-in-linux
latex-deps)
	update
	if missing "texlive-base"; then
		error "TeX Live is not installed. Please install TeX Live first."
		exit 1
	fi
	if missing "dialog"; then
		info "Installing Dialog" && sudo -i apt install dialog
	fi
	cmd=(dialog --radiolist "Please select which LaTeX package you want to install" 22 76 16)
	options=(
		1 "Base version (~216MB)" OFF
		2 "Extra version (~452MB)" OFF
		3 "Full version (~5358MB)" OFF
	)
	choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	case "$choice" in
	1)
		clear && timer "$CONT" "$INST Base version"
		sudo apt-get install texlive-base
		;;
	2)
		clear && timer "$CONT" "$INST Extra version"
		sudo apt-get install texlive-latex-extra
		;;
	3)
		clear && timer "$CONT" "$INST Full version"
		sudo apt-get install texlive-full
		;;
	esac
	success "LaTeX dependencies installed successfully!"
	;;
java-switcher)
	if missing "dialog"; then
		info "Installing Dialog" && sudo -i apt install dialog >/dev/null 2>&1
	fi

	info "Detecting installed Java versions..."

	# Find all Java installations
	java_installations=()
	index=1

	# Search common Java installation directories
	for java_home in /usr/lib/jvm/java-*-openjdk-* /usr/lib/jvm/jdk-* /usr/lib/jvm/adoptopenjdk-* /opt/java/*; do
		# Skip java-1.x.y style paths (legacy naming like java-1.17.0-openjdk-*)
		[[ "$(basename "$java_home")" =~ ^java-1\. ]] && continue
		if [ -d "$java_home" ] && [ -f "$java_home/bin/java" ]; then
			# Get Java version
			version_output=$("$java_home/bin/java" -version 2>&1 | head -n 1)

			# Extract version number more reliably
			if [[ $version_output =~ \"([0-9]+\.[0-9]+\.[0-9]+[^\"]*)\" ]] || [[ $version_output =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
				version="${BASH_REMATCH[1]}"
			else
				version="unknown"
			fi

			java_installations+=("$index" "$java_home (v$version)" "off")
			((index++))
		fi
	done

	# Check if any Java installations were found
	if [ ${#java_installations[@]} -eq 0 ]; then
		error "No Java installations found in common directories."
		error "Searched in: /usr/lib/jvm/java-*, /usr/lib/jvm/jdk-*, /usr/lib/jvm/adoptopenjdk-*, /opt/java/*"
		exit 1
	fi

	# Create dialog
	cmd=(dialog --radiolist "Select Java version to set as JAVA_HOME:" 22 76 16)
	choice=$("${cmd[@]}" "${java_installations[@]}" 2>&1 >/dev/tty)
	clear

	if [ -z "$choice" ]; then
		warn "No selection made. JAVA_HOME unchanged."
		exit 0
	fi

	# Get the selected Java home path
	selected_index=$((choice * 3 - 2))
	selected_java_home=$(echo "${java_installations[$selected_index]}" | cut -d' ' -f1)

	# Verify the selection
	if [ ! -d "$selected_java_home" ]; then
		error "Selected Java home directory does not exist: $selected_java_home"
		exit 1
	fi

	info "Selected: $selected_java_home"

	# Remove old JAVA_HOME from .bashrc
	if grep -q "export JAVA_HOME=" ~/.bashrc; then
		info "Removing old JAVA_HOME from .bashrc..."
		sed -i '/export JAVA_HOME=/d' ~/.bashrc
	fi

	# Add new JAVA_HOME to .bashrc
	echo "" >>~/.bashrc
	echo "# Java Home - Set on $(date '+%Y-%m-%d %H:%M:%S')" >>~/.bashrc
	echo "export JAVA_HOME=$selected_java_home" >>~/.bashrc
	echo 'export PATH=$JAVA_HOME/bin:$PATH' >>~/.bashrc

	# Also export for current session
	export JAVA_HOME="$selected_java_home"
	export PATH="$JAVA_HOME/bin:$PATH"

	success "JAVA_HOME set to: $selected_java_home"
	info "Current session updated. Run 'source ~/.bashrc' in other terminals or restart them."

	# Display current Java version
	info "Current Java version:"
	java -version
	;;
clean-zone)
	target_dir="${2:-.}"
	if [ ! -d "$target_dir" ]; then
		error "Directory not found: $target_dir"
		exit 1
	fi
	info "Searching for Zone.Identifier files in '$target_dir'..."
	count=$(find "$target_dir" -type f -name "*Zone.Identifier*" | wc -l)
	if [ "$count" -eq 0 ]; then
		info "No Zone.Identifier files found."
	else
		find "$target_dir" -type f -name "*Zone.Identifier*" -print -delete
		success "Deleted $count Zone.Identifier file(s)."
	fi
	;;
connect-docker)
	exec 3>&1
	choice=$(dialog --radiolist "This is an operation only recommended for OrbStack. This will install docker.io and docker-compose-v2, and configure DOCKER_HOST in ~/.bashrc. Proceed?" 22 76 16 \
		1 "Yes" off \
		2 "No" off \
		2>&1 1>&3)
	exec 3>&-
	clear

	case "$choice" in
	1)
		sudo apt install -y docker.io docker-compose-v2
		sudo usermod -aG docker $USER
		grep -qxF 'alias docker-compose="docker compose"' ~/.bashrc ||
			echo 'alias docker-compose="docker compose"' >>~/.bashrc
		success "Docker installed. Alias docker-compose added to ~/.bashrc."
		success "Reboot the VM."
		;;
	2)
		info "Operation cancelled. Docker not configured."
		;;
	*)
		info "Operation cancelled."
		;;
	esac
	;;
script-version)
	info "Ubuntu Setup Script - Version: ${SCRIPT_VERSION}"
	info "Checking for updates..."
	latest=$(curl -sf "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
	if [ -z "$latest" ]; then
		warn "Could not retrieve latest release info. Check your internet connection or visit: https://github.com/${GITHUB_REPO}/releases"
	elif [ "$latest" = "$SCRIPT_VERSION" ]; then
		success "You are running the latest version (${SCRIPT_VERSION})."
	else
		warn "A newer version is available: ${latest} (you have ${SCRIPT_VERSION})"
		info "To update, run the following commands from the WslConfig directory:"
		echo -e "  git fetch && git pull"
		echo -e "  ./init.sh"
	fi
	;;
help)
	help
	;;
*)
	error "Unknown command: $1"
	echo ""
	help
	;;
esac
