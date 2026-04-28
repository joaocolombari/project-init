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

echo "Creating project README.md..."

cat <<EOF > README.md
# $(basename "$(pwd)")

## 📌 Project Overview
Short description of your project.

---

## ⚙️ Environment

This project uses a virtual environment:

\`\`\`bash
source $ENV_NAME/bin/activate
\`\`\`

Python version:
\`\`\`
python$PYTHON_VERSION
\`\`\`

---

## 📦 Installed Packages

Depending on your setup, this project may include:

EOF

# Append installed packages dynamically
[ "$INSTALL_NUMPY" = "y" ] && echo "- numpy" >> README.md
[ "$INSTALL_TORCH" = "y" ] && echo "- torch / torchaudio" >> README.md
[ "$INSTALL_TF" = "y" ] && echo "- tensorflow" >> README.md

cat <<EOF >> README.md

---

## ▶️ Usage

Activate the environment:

\`\`\`bash
source $ENV_NAME/bin/activate
\`\`\`

Run the notebook:

\`\`\`bash
jupyter notebook
\`\`\`

or open in VS Code and select the kernel:

\`\`\`
Python ($ENV_NAME)
\`\`\`

---

## 📁 Structure

\`\`\`
.
├── main.ipynb
├── $ENV_NAME/
└── README.md
\`\`\`

---

## 🧠 Notes

- The virtual environment is local to this project
- Do not commit the environment folder to git
- Add it to \`.gitignore\` if needed

---

## 📄 License

Add your license here.
EOF

# --- Move everything one level up and remove bootstrap folder ---

echo "Finalizing project structure..."

CURRENT_DIR="$(pwd)"
PARENT_DIR="$(dirname "$CURRENT_DIR")"
BOOTSTRAP_DIR="$(basename "$CURRENT_DIR")"

cd "$PARENT_DIR" || exit

echo "Moving project files out of $BOOTSTRAP_DIR..."

# Move everything including hidden files
shopt -s dotglob
mv "$BOOTSTRAP_DIR"/* .
shopt -u dotglob

# --- Remove bootstrap artifacts from final project ---
echo "Cleaning bootstrap files..."

rm -rf init.sh
rm -rf templates

# --- Remove the bootstrap folder itself ---
rm -rf "$BOOTSTRAP_DIR"

echo "Project moved to: $PARENT_DIR"

# Open VS Code from final location
echo "Opening VS Code..."
code .

echo "=== CLEAN SETUP COMPLETE ==="

echo "=== DONE ==="
echo "Activate env with: source $ENV_NAME/bin/activate"
echo "Then open main.ipynb and select kernel: Python ($ENV_NAME)"