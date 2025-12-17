#!/bin/bash

# Define the installation directory
INSTALL_DIR="/usr/local/bin"

# Create the installation directory if it doesn't exist
sudo mkdir -p "$INSTALL_DIR"

# Copy the Python script to the installation directory
sudo cp llama4_terminal_client.py "$INSTALL_DIR/llama4_terminal_client.py"
sudo cp .env "$INSTALL_DIR/.env"
echo "llama4_terminal_client successfully installed!"
echo "Use python /usr/local/bin/llama4_terminal_client.py -h for usage instructions or create an alias for ease of use!"
