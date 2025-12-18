# ./llama4_terminal_client.py
import os
import sys
import base64
import subprocess
import argparse
from io import BytesIO
from PIL import Image
from rich.console import Console
from openai import OpenAI
from dotenv import load_dotenv
import shutil
from typing import Literal

console = Console()

# Configuration
def load_config():
    load_dotenv()
    script_dir = os.path.abspath(os.getcwd())
    prompt_dir = os.path.join(script_dir, "prompt")
    os.makedirs(prompt_dir, exist_ok=True)  # Ensure the prompt directory exists
    install_dir = os.getenv("INSTALL_DIR", "/usr/local/bin/llama4_terminal_client")
    config = {
        "LLAMA_API_KEY": os.getenv("LLAMA_API_KEY"),
        "LLAMA_API_BASE_URL": os.getenv('LLAMA_API_BASE_URL'),
        "PROPRIETARY_API_KEY": os.getenv("PROPRIETARY_API_KEY"),
        "PROPRIETARY_API_BASE_URL": os.getenv("PROPRIETARY_API_BASE_URL"),
        "MODEL_NAME": "Llama-4-Maverick-17B-128E-Instruct-FP8",
        "SRC_CONTEXT_FILE": os.path.join(prompt_dir, "__code_context__.md"),
        "IMAGE_CONTEXT_FILE": os.path.join(prompt_dir, "__images__.md"),
        "SYSTEM_CONTEXT_FILE": os.path.join(prompt_dir, "__system_context__.md"),
        "PROMPT_CONTEXT_FILE": os.path.join(prompt_dir, "__prompt__.md"),
        "RESPONSE_FILE_PATH": os.path.join(prompt_dir, "__response__.md"),
        "BUG_CONTEXT_FILE": os.path.join(prompt_dir, "__bug__.md"),
        "TREE_OUTPUT_FILE": os.path.join(prompt_dir, "__tree__.md"),
        "INSTALL_DIR_SYSTEM_CONTEXT_FILE": os.path.join(install_dir, "__system_context__.md"),
    }
    
    # Create missing files
    for file_path in [config["SRC_CONTEXT_FILE"], config["IMAGE_CONTEXT_FILE"], config["SYSTEM_CONTEXT_FILE"], config["PROMPT_CONTEXT_FILE"], config["RESPONSE_FILE_PATH"], config["TREE_OUTPUT_FILE"]]:
        if not os.path.exists(file_path):
            try:
                with open(file_path, 'w') as file:
                    pass  # Create an empty file
                console.print(f"Created missing file: {file_path}")
            except Exception as e:
                console.print(f"Failed to create file: {file_path}, Error: {e}")
    return config

# Image Handling
def get_clipboard_image() -> Image.Image | None:
    try:
        # Wayland
        proc = subprocess.run(["wl-paste", "--type", "image/png"], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        if proc.returncode == 0 and proc.stdout:
            return Image.open(BytesIO(proc.stdout))
    except Exception as e:
        console.print(f"Failed to get image from Wayland clipboard: {e}")
    
    try:
        # X11 fallback
        proc = subprocess.run(["xclip", "-selection", "clipboard", "-t", "image/png", "-o"], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        if proc.returncode == 0 and proc.stdout:
            return Image.open(BytesIO(proc.stdout))
    except Exception as e:
        console.print(f"Failed to get image from X11 clipboard: {e}")
    return None

def load_local_image(path: str) -> Image.Image | None:
    try:
        return Image.open(path)
    except Exception as e:
        console.print(f"Failed to load local image: {e}")
        return None

def image_to_data_url(img: Image.Image) -> str:
    buf = BytesIO()
    img.save(buf, format="PNG")
    encoded = base64.b64encode(buf.getvalue()).decode("utf-8")
    return f"data:image/png;base64,{encoded}"

# File Handling
def load_code_file_into_context(path: str) -> str | None:
    try:
        with open(path, 'r') as file:
            return file.read().strip()
    except Exception as e:
        console.print(f"Failed to load file: {e}")
        return None

def load_src_context(file_list_path: str) -> list:
    try:
        with open(file_list_path, 'r') as file:
            return file.read().strip().splitlines()
    except Exception as e:
        console.print(f"Failed to load src_context: {e}")
        return []

def load_image_context(file_list_path: str) -> list:
    try:
        with open(file_list_path, 'r') as file:
            return file.read().strip().splitlines()
    except Exception as e:
        console.print(f"Failed to load image_context: {e}")
        return []

def save_response_to_file(response: str, file_path: str):
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, 'w') as file:
        file.write(response)

def load_previous_response(file_path: str) -> str | None:
    return load_code_file_into_context(file_path)

# Main Logic
def create_client(model_name: str, config: dict) -> OpenAI:
    if 'llama' in model_name.lower():
        return OpenAI(base_url=config["LLAMA_API_BASE_URL"], api_key=config["LLAMA_API_KEY"])
    else:
        return OpenAI(base_url=config["PROPRIETARY_API_BASE_URL"], api_key=config["PROPRIETARY_API_KEY"])

def prepare_user_text(args, config: dict) -> str:
    user_text = ""
    if args.system_context:
        console.print(f"Using system context file: {config['SYSTEM_CONTEXT_FILE']}")
        system_context_content = load_code_file_into_context(config["SYSTEM_CONTEXT_FILE"])
        if system_context_content:
            user_text += f"<|begin_of_text|><|start_header_id|>system<|end_header_id|>{system_context_content}"
        else:
            install_dir_system_context_content = load_code_file_into_context(config["INSTALL_DIR_SYSTEM_CONTEXT_FILE"])
            if install_dir_system_context_content:
                console.print(f"Using system context from install directory: {config['INSTALL_DIR_SYSTEM_CONTEXT_FILE']}")
                user_text += f"<|begin_of_text|><|start_header_id|>system<|end_header_id|>{install_dir_system_context_content}"
            else:
                console.print("No system context found.")
    
    user_text += f"<|eot_id|><|start_header_id|>user<|end_header_id|>"

    if args.tree:
        try:
            tree_output_file = config["TREE_OUTPUT_FILE"]
            console.log(tree_output_file)
            subprocess.run(["tree", "."], stdout=open(tree_output_file, 'w+'), cwd=os.getcwd())
            tree_content = load_code_file_into_context(tree_output_file)
            if tree_content:
                user_text += f"### Directory Tree ###\n{tree_content}\n### End of Directory Tree ###\n\n"
        except Exception as e:
            console.print(f"Failed to generate directory tree: {e}")

    if args.code_context:
        code_files = load_src_context(config["SRC_CONTEXT_FILE"])
        for file in code_files:
            console.print(f"Using code file: {file}")
            file_content = load_code_file_into_context(file)
            if file_content:
                user_text += f"### Code File: {file} ###\n{file_content}\n### End of Code File: {file} ###\n\n"

    if args.file:
        for file in args.file:
            console.print(f"Using text file: {file}")
            file_content = load_code_file_into_context(file)
            if file_content:
                user_text += f"### File: {file} ###\n{file_content}\n### End of File: {file} ###\n\n"    


    if args.bug:
            console.print(f"Debugging: {args.bug}")
            console.print(f"Debugging using bug context file: {config['BUG_CONTEXT_FILE']}")
            bug_content = load_code_file_into_context(config["BUG_CONTEXT_FILE"])
            if bug_content:
                user_text += f"### Bug Report: {args.bug} ###\nThe following is a bug located in the code context. Please identify the root cause of the bug and edit the code so as to eliminate the bug. Please indicate the error and where the code was updated to resolve the error.\n\n{bug_content}\n### End of Bug Report: {args.bug} ###\n\n"

    if args.message:
        user_text += f"### TASK ###\n{args.message}\n### End of TASK ###\n\n"

    if args.prompt_context:
        console.print(f"Using prompt context file: {config['PROMPT_CONTEXT_FILE']}")
        prompt_context_content = load_code_file_into_context(config["PROMPT_CONTEXT_FILE"])
        if prompt_context_content:
            user_text += f"### TASK ###\n{prompt_context_content}\n### End of TASK ###\n\n"

    if not sys.stdin.isatty():
        user_text += f"### TASK ###\n{sys.stdin.read().strip()}\n### TASK ###\n\n"

    user_text += f"<|eot_id|><|start_header_id|>assistant<|end_header_id|>"

    return user_text.strip()


def load_image_context(file_list_path: str) -> list:
    """
    Load image context from the given file_list_path.
    If the path is a directory, load all images directly under it.
    Otherwise, assume it's a file containing image paths, one per line.
    """
    image_paths = []
    if os.path.isdir(file_list_path):
        console.print(f"Loading images from directory: {file_list_path}")
        for filename in os.listdir(file_list_path):
            filepath = os.path.join(file_list_path, filename)
            if os.path.isfile(filepath) and filepath.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff')):
                image_paths.append(filepath)
    else:
        try:
            with open(file_list_path, 'r') as file:
                for line in file.read().strip().splitlines():
                    line = line.strip()
                    if os.path.isdir(line):
                        console.print(f"Loading images from directory: {line}")
                        for filename in os.listdir(line):
                            filepath = os.path.join(line, filename)
                            if os.path.isfile(filepath) and filepath.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff')):
                                image_paths.append(filepath)
                    else:
                        if line.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff')):
                            image_paths.append(line)
        except Exception as e:
            console.print(f"Failed to load image context: {e}")
    return image_paths

Style = Literal["double", "single", "heavy", "minimal", "rounded"]

def terminal_width(default: int = 80) -> int:
    try:
        return shutil.get_terminal_size().columns
    except Exception:
        return default

def print_section(
    title: str,
    style: Style = "double",
    padding: int = 2
) -> None:
    width = terminal_width()
    title = f"{' ' * padding}{title.upper()}{' ' * padding}"

    if style == "double":
        top = "╔" + "═" * (width - 2) + "╗"
        mid = "║" + title.center(width - 2) + "║"
        bot = "╚" + "═" * (width - 2) + "╝"

    elif style == "single":
        top = "┌" + "─" * (width - 2) + "┐"
        mid = "│