# llama4-terminal
terminal integration with llama4 for optimized coding queries

## Table of Contents

- (#llama4-terminal)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Configuration](#configuration)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Arguments](#arguments)
  - [Examples](#examples)
  - [Troubleshooting](#troubleshooting)

## Overview

The LLAMA 4 Terminal Client is a command-line interface (CLI) tool that interacts with the LLAMA 4 
model. It allows users to send text and images to the model and receive responses. The tool is designed 
to facilitate coding queries, debugging, and other development-related tasks.

The client can process various types of input, including:

* Text messages
* Code files
* Images (local or from clipboard)
* Directory trees
* Bug reports

The client uses the LLAMA 4 model to generate responses based on the input provided.

## Prerequisites

* Python 3.x installed on your system
* `openai` and `rich` libraries installed (`pip install openai rich`)
* `PIL` library installed (`pip install pillow`)
* `dotenv` library installed (`pip install python-dotenv`)
* `wl-paste` and `xclip` commands available for clipboard functionality (optional)
* `tree` command available for generating directory trees (optional)

## Configuration

1. Create a `.env` file in the root directory with the following variables:
        * `LLAMA_API_KEY`: Your LLAMA API key
        * `LLAMA_API_BASE_URL`: The base URL for the LLAMA API
        * `PROPRIETARY_API_KEY`: Your proprietary API key (if using a different model)
        * `PROPRIETARY_API_BASE_URL`: The base URL for the proprietary API (if using a different model)
2. Create a `prompt` directory with the following files:
        * `__src_context__.md`: A list of code files to include in the context
        * `__system_context__.md`: System context to use as user text
        * `__prompt__.md`: Prompt context to include in the user text
        * `__images__.md`: A list of image files to include in the context
        * `__bug__.md`: Bug report to include in the context

## Usage

1. Run the script using `python llama4_terminal_client.py`
2. Use the available arguments to customize the input and behavior (see below)

## Installation

To install the LLAMA 4 Terminal Client, follow these steps:

1. Clone the repository to your local machine.
2. Navigate to the repository directory and run `./install.sh` to install the client.
3. Create a `.env` file in the `/usr/local/bin` directory with the required environment variables.
4. Create a `prompt` directory with the necessary files as described in the Configuration section.

After installation, you can use the client by running `python /usr/local/bin/llama4_terminal_client.py` 
followed by the desired arguments. You can also create an alias for ease of use.

## Arguments

* `-i`, `--image`: Path to a local image file
* `-I`, `--image-context`: Use image context from `./prompt/__images__.md`
* `-f`, `--file`: Path to a text file
* `-c`, `--code-context`: Use code context from `./prompt/__src_context__.md` (a list of filepaths to be
read and used as context)
* `-s`, `--system-context`: Use system context from `./prompt/__system_context__.md` as user text to 
provide instructions that are persistent
* `-p`, `--prompt-context`: Use prompt context from `./prompt/__prompt__.md`: this is the default prompt
* `-r`, `--response`: Use previous response as context
* `-m`, `--message`: Message to be sent for quick cli messaging rather than sending a prompt.md file
* `-v`, `--verbose`: Print input to console for verification of the prompt sent to the model
* `-M`, `--model`: Define the Model to be used (default: `Llama-4-Maverick-17B-128E-Instruct-FP8`); .env
must be updated with api key and api base path
* `-b`, `--bug`: Use bug report from `./prompt/__bug__.md` to debug code
* `-t`, `--tree`: Use directory tree as context

## Examples

* Send a simple message: `python llama4_terminal_client.py -m "Hello, world!"`
* Use code context: `python llama4_terminal_client.py -c -m "Explain this code"`
* Include a local image: `python llama4_terminal_client.py -i /path/to/image.png -m "Describe this 
image"`
* Use previous response as context: `python llama4_terminal_client.py -r -m "Follow up on previous 
response"`
* Debug code: `python llama4_terminal_client.py -c -b -m "Fix this bug"`

## Troubleshooting

* Check the `.env` file for correct configuration
* Verify that the required libraries are installed
* Ensure that the `wl-paste` and `xclip` commands are available for clipboard functionality (if using)
* Check the console output for error messages