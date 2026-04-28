#!/bin/bash

echo "=== Python Project Bootstrap ==="

# --- Track bootstrap root ---
BOOTSTRAP_ROOT="$(pwd)"

# --- Clone repo (optional) ---
read -p "Enter repository URL (or press Enter to skip): " REPO_URL

if [ -n "$REPO_URL" ]; then
    git clone "$REPO_URL"
    ORIGINAL_NAME=$(basename -s .git "$REPO_URL")
    cd "$ORIGINAL_NAME" || exit

    # Rename project
    read -p "Rename project folder? (y/n): " RENAME
    if [ "$RENAME" = "y" ]; then
        read -p "New folder name: " NEW_NAME
        cd ..
        mv "$ORIGINAL_NAME" "$NEW_NAME"
        cd "$NEW_NAME" || exit
    fi

    # Remove git history
    read -p "Remove existing .git history? (y/n): " REMOVE_GIT
    if [ "$REMOVE_GIT" = "y" ]; then
        rm -rf .git
        git init
        echo "Initialized fresh git repository."
    fi
fi

# --- Define project directory ---
PROJECT_DIR="$(pwd)"

# --- Environment ---
read -p "Environment name: " ENV_NAME
read -p "Python version (e.g. 3.10): " PYTHON_VERSION

if ! command -v python$PYTHON_VERSION &> /dev/null
then
    echo "Python $PYTHON_VERSION not found."
    exit 1
fi

echo "Creating virtual environment..."
python$PYTHON_VERSION -m venv "$ENV_NAME"
source "$ENV_NAME/bin/activate"

pip install --upgrade pip

# --- Packages ---
read -p "Install NumPy? (y/n): " INSTALL_NUMPY
read -p "Install PyTorch? (y/n): " INSTALL_TORCH
read -p "Install TensorFlow? (y/n): " INSTALL_TF

[ "$INSTALL_NUMPY" = "y" ] && pip install numpy
[ "$INSTALL_TORCH" = "y" ] && pip install torch torchaudio --index-url https://download.pytorch.org/whl/cpu
[ "$INSTALL_TF" = "y" ] && pip install tensorflow

# Core tools
pip install ipykernel notebook soundfile matplotlib onnx onnxruntime

# --- Kernel ---
python -m ipykernel install --user --name=$ENV_NAME --display-name "Python ($ENV_NAME)"

# --- Create notebook ---
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

# --- Create README ---
echo "Creating README.md..."

cat <<EOF > README.md
# $(basename "$PROJECT_DIR")

## 📌 Project Overview
Short description of your project.

---

## ⚙️ Environment

\`\`\`bash
source $ENV_NAME/bin/activate
\`\`\`

Python version:
\`\`\`
python$PYTHON_VERSION
\`\`\`

---

## 📦 Installed Packages
EOF

[ "$INSTALL_NUMPY" = "y" ] && echo "- numpy" >> README.md
[ "$INSTALL_TORCH" = "y" ] && echo "- torch / torchaudio" >> README.md
[ "$INSTALL_TF" = "y" ] && echo "- tensorflow" >> README.md

cat <<EOF >> README.md

---

## ▶️ Usage

\`\`\`bash
source $ENV_NAME/bin/activate
jupyter notebook
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

## 📄 License

Add your license here.
EOF

# --- Create .gitignore ---
echo "Creating .gitignore..."

cat <<EOF > .gitignore
# Virtual environment
$ENV_NAME/

# Python
__pycache__/
*.pyc

# Jupyter
.ipynb_checkpoints/

# VS Code
.vscode/

# macOS
.DS_Store
EOF

# --- VS Code settings ---
mkdir -p .vscode

cat <<EOF > .vscode/settings.json
{
    "python.defaultInterpreterPath": "$(pwd)/$ENV_NAME/bin/python"
}
EOF

# --- FINAL CLEANUP + MOVE ---
echo "Finalizing project structure..."

cd "$BOOTSTRAP_ROOT/.." || exit
TARGET_PARENT="$(pwd)"

echo "Moving project to: $TARGET_PARENT"

shopt -s dotglob
mv "$PROJECT_DIR"/* "$TARGET_PARENT"/
shopt -u dotglob

echo "Removing bootstrap folder..."
rm -rf "$BOOTSTRAP_ROOT"

# --- Open VS Code ---
echo "Opening VS Code..."
cd "$TARGET_PARENT" || exit
code .

echo "=== CLEAN SETUP COMPLETE ==="
echo "Activate env with: source $ENV_NAME/bin/activate"
echo "Select kernel: Python ($ENV_NAME)"