#!/bin/bash
# install_llama4_terminal.sh
# Installs llama4_terminal_client with decorative ASCII success messages

set -euo pipefail

INSTALL_DIR="/usr/local/bin/llama4_terminal_client"

# Create directories
sudo mkdir -p "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR/prompt"

# Copy files
sudo cp llama4_terminal_client.py "$INSTALL_DIR/llama4_terminal_client.py"
sudo cp .env "$INSTALL_DIR/.env"
sudo cp ./prompt/__system_context__.md "$INSTALL_DIR/prompt/__system_context__.md"

# Decorative success messages
cat << 'EOF'

╔════════════════════════════════════════════════════════════╗
║                                                            ║
║   ███████╗██╗   ██╗ ██████╗ ██████╗███████╗███████╗███████╗║
║   ██╔════╝██║   ██║██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝║
║   ███████╗██║   ██║██║     ██║     █████╗  ███████╗███████╗║
║   ╚════██║██║   ██║██║     ██║     ██╔══╝  ╚════██║╚════██║║
║   ███████║╚██████╔╝╚██████╗╚██████╗███████╗███████╗███████║║
║   ╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝╚══════╝╚══════╝╚══════╝║
║                                                            ║
║          llama4_terminal_client successfully installed!    ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

EOF

cat << 'EOF'

╔════════════════════════════════════════════════════════════╗
║                        USAGE TIP                           ║
║                                                            ║

    Run: 

python /usr/local/bin/llama4_terminal_client/llama4_terminal_client.py -h

    For convenience, add an alias to your ~/.bashrc:             

alias llama4='python /usr/local/bin/llama4_terminal_client/llama4_terminal_client.py'

║                                                            ║
╚════════════════════════════════════════════════════════════╝

EOF