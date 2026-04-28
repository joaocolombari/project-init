#!/bin/bash

echo "=== Python Project Bootstrap ==="

# --- Clone repo ---
read -p "Enter repository URL (or press Enter to skip): " REPO_URL

if [ -n "$REPO_URL" ]; then
    git clone "$REPO_URL"
    ORIGINAL_NAME=$(basename -s .git "$REPO_URL")
    cd "$ORIGINAL_NAME" || exit

    # --- Rename folder ---
    read -p "Rename project folder? (y/n): " RENAME
    if [ "$RENAME" = "y" ]; then
        read -p "New folder name: " NEW_NAME
        cd ..
        mv "$ORIGINAL_NAME" "$NEW_NAME"
        cd "$NEW_NAME" || exit
    fi

    # --- Remove .git ---
    read -p "Remove existing .git history? (y/n): " REMOVE_GIT
    if [ "$REMOVE_GIT" = "y" ]; then
        rm -rf .git
        git init
        echo "Initialized fresh git repository."
    fi
fi

# --- Env name ---
read -p "Environment name: " ENV_NAME

# --- Python version ---
read -p "Python version (e.g. 3.10): " PYTHON_VERSION

if ! command -v python$PYTHON_VERSION &> /dev/null
then
    echo "Python $PYTHON_VERSION not found."
    exit 1
fi

# --- Create venv ---
echo "Creating virtual environment..."
python$PYTHON_VERSION -m venv $ENV_NAME

# Activate
source $ENV_NAME/bin/activate

# --- Ensure EVERYTHING installs inside venv ---
which python
which pip

pip install --upgrade pip

# --- Package selection ---
read -p "Install NumPy? (y/n): " INSTALL_NUMPY
read -p "Install PyTorch? (y/n): " INSTALL_TORCH
read -p "Install TensorFlow? (y/n): " INSTALL_TF

# --- Install packages ---
if [ "$INSTALL_NUMPY" = "y" ]; then
    pip install numpy
fi

if [ "$INSTALL_TORCH" = "y" ]; then
    pip install torch torchaudio --index-url https://download.pytorch.org/whl/cpu
fi

if [ "$INSTALL_TF" = "y" ]; then
    pip install tensorflow
fi

# --- Always install core tools ---
pip install ipykernel notebook soundfile matplotlib onnx onnxruntime

# --- Register kernel ---
python -m ipykernel install --user --name=$ENV_NAME --display-name "Python ($ENV_NAME)"

# --- Create notebook via Python (robust way) ---
echo "Creating main.ipynb..."

python - <<EOF
import nbformat as nbf

nb = nbf.v4.new_notebook()

nb.cells = [
    nbf.v4.new_markdown_cell("# Main Notebook\n\nEnvironment ready."),
    nbf.v4.new_code_cell("import sys\nprint(sys.executable)")
]

with open("main.ipynb", "w") as f:
    nbf.write(nb, f)
EOF

# --- VS Code settings ---
mkdir -p .vscode

cat <<EOF > .vscode/settings.json
{
    "python.defaultInterpreterPath": "$(pwd)/$ENV_NAME/bin/python"
}
EOF

# --- Open VS Code ---
echo "Opening VS Code..."
code .

echo "=== DONE ==="
echo "Activate env with: source $ENV_NAME/bin/activate"
echo "Then open main.ipynb and select kernel: Python ($ENV_NAME)"