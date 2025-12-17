I want to use the following code with a keyboard shortcut and alias as in the following:

### Example Usage

To use the updated code, you can run the script with the following commands:

*   To send a markdown file:
    ```bash
python llama4_terminal_client.py -m path/to/your/file.md
```
*   To send a markdown file with a local image:
    ```bash
python llama4_terminal_client.py -m path/to/your/file.md -i path/to/your/image.png
```
*   To send text from stdin with a local image:
    ```bash
echo "Your text here" | python llama4_terminal_client.py -i path/to/your/image.png
```
*   To send text from stdin with an image from the clipboard:
    ```bash
echo "Your text here" | python llama4_terminal_client.py

### Desired Usage

*   To send a markdown file:
    ```bash
ai -m path/to/your/file.md
```
*   To send a markdown file with a local image:
    ```bash
ai -m path/to/your/file.md -i path/to/your/image.png
```
*   To send text from stdin with a local image:
    ```bash
echo "Your text here" | ai -i path/to/your/image.png
```
*   To send text from stdin with an image from the clipboard:
    ```bash
echo "Your text here" | ai

### Code:

# llama4_terminal_client.py

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

console = Console()

# --- Configuration ---------------------------------------------------------

load_dotenv()

API_KEY = os.getenv("LLAMA_API_KEY")
if not API_KEY:
    console.print("LLAMA_API_KEY not set")
    sys.exit(1)

client = OpenAI(
    base_url="https://api.llama.com/compat/v1/",
    api_key=API_KEY,
)

MODEL_NAME = "Llama-4-Maverick-17B-128E-Instruct-FP8"

# --- Image Handling -------------------------------------------------------

def get_clipboard_image():
    """
    Attempts to read an image from the clipboard (Wayland first, then X11).
    Returns a PIL Image or None.
    """
    # Wayland
    try:
        proc = subprocess.run(
            ["wl-paste", "--type", "image/png"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
        if proc.returncode == 0 and proc.stdout:
            return Image.open(BytesIO(proc.stdout))
    except Exception:
        pass

    # X11 fallback
    try:
        proc = subprocess.run(
            ["xclip", "-selection", "clipboard", "-t", "image/png", "-o"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
        if proc.returncode == 0 and proc.stdout:
            return Image.open(BytesIO(proc.stdout))
    except Exception:
        pass

    return None

def load_local_image(path: str) -> Image.Image:
    """
    Loads a local image from the given path.
    Returns a PIL Image or None if loading fails.
    """
    try:
        return Image.open(path)
    except Exception as e:
        console.print(f"Failed to load local image: {e}")
        return None

def image_to_data_url(img: Image.Image) -> str:
    """
    Converts a PIL image to a data URL suitable for image_url.
    """
    buf = BytesIO()
    img.save(buf, format="PNG")
    encoded = base64.b64encode(buf.getvalue()).decode("utf-8")
    return f"data:image/png;base64,{encoded}"

# --- File Handling -------------------------------------------------------

def load_markdown_file(path: str) -> str:
    """
    Loads a markdown file from the given path.
    Returns the file content as a string or None if loading fails.
    """
    try:
        with open(path, 'r') as file:
            return file.read().strip()
    except Exception as e:
        console.print(f"Failed to load markdown file: {e}")
        return None

# --- Main ------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="LLAMA 4 Terminal Client")
    parser.add_argument("-i", "--image", help="Path to local image file")
    parser.add_argument("-m", "--markdown", help="Path to markdown file")
    args = parser.parse_args()

    console.print("LLAMA 4 Terminal")
    console.print("Paste text, image optional (clipboard or local), Ctrl+D to send\n")

    if args.markdown:
        console.print(f"Using markdown file: {args.markdown}")
        user_text = load_markdown_file(args.markdown)
        if not user_text:
            return
    else:
        user_text = sys.stdin.read().strip()
        if not user_text:
            console.print("No input provided")
            return

    content = [
        {
            "type": "text",
            "text": user_text,
        }
    ]

    image = None
    if args.image:
        console.print(f"Using local image: {args.image}")
        image = load_local_image(args.image)
    else:
        image = get_clipboard_image()
        if image:
            console.print("Image detected from clipboard")

    if image:
        content.append(
            {
                "type": "image_url",
                "image_url": {
                    "url": image_to_data_url(image),
                },
            }
        )

    try:
        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {
                    "role": "user",
                    "content": content,
                }
            ],
            max_tokens=2500
        )
        reply = response.choices[0].message.content
        console.print("\nResponse:\n")
        console.print(reply)
    except Exception as e:
        console.print(f"Error: {e}")

if __name__ == "__main__":
    main()
