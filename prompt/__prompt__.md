Please add an environment variable for the install directory that is set to /usr/local/bin/llama4_terminal_client
please update the system context function to the following:
if the system context is specified, 
if the local __system_context__.md is not empty, use this as the system context.
if the local __system_context__.md is empty, then check system context at the install directory (/usr/local/bin/llama4_terminal_client/prompt/__system_context__.md)
if the system context at the install directory is empty, continue without using the system context (indicate to the console, no system context was found...)
otherwise, use the system context at the install directory.