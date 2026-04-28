# 🚀 Python Project Bootstrap

A simple initialization toolkit to quickly start a new Python project with:

* Virtual environment creation
* Optional installation of PyTorch, NumPy, TensorFlow
* Automatic Jupyter kernel setup
* Ready-to-use `main.ipynb`
* VS Code integration

---

## 📦 What this repo does

This script helps you go from **empty folder → ready-to-run notebook** in a few minutes.

It will:

* Clone a target repository (optional)
* Create a virtual environment with your chosen Python version
* Install selected packages
* Register a Jupyter kernel
* Generate a starter notebook (`main.ipynb`)
* Open the project in VS Code

---

## 📁 Repository structure

```
project-init/
│
├── init.sh
├── templates/
│   └── main.ipynb   (optional template)
└── README.md
```

---

## ⚙️ Requirements

Make sure you have:

* Python (e.g. 3.10, 3.11)
* `pip`
* `git`
* VS Code (`code` command available in terminal)

Optional but recommended:

* `pyenv` (for managing Python versions)

---

## ▶️ Usage

Clone this repository:

```bash
git clone <your-bootstrap-repo>
cd project-init
```

Make the script executable:

```bash
chmod +x init.sh
```

Run the initializer:

```bash
./init.sh
```

---

## 🧩 What you’ll be asked

During execution, the script will prompt you for:

* A repository to clone (optional)
* Environment name
* Python version
* Whether to install:

  * NumPy
  * PyTorch
  * TensorFlow

---

## 🧠 After setup

The script will:

* Create your virtual environment

* Install selected dependencies

* Register a Jupyter kernel:

  ```
  Python (<your-env-name>)
  ```

* Generate:

  ```
  main.ipynb
  ```

* Open the project in VS Code

---

## 📓 Using the notebook

1. Open `main.ipynb`

2. Select kernel:

   ```
   Python (<your-env-name>)
   ```

3. Run the first cell to confirm:

```python
import sys
print(sys.executable)
```

---

## ⚠️ Notes

### Python version

The script expects something like:

```bash
python3.10
```

to be available in your system.

If not, install it or use `pyenv`.

---

### PyTorch / TensorFlow

* Installed via `pip`
* Default = CPU versions

If you need GPU support, installation commands must be adapted.

---

### VS Code

The script opens VS Code automatically:

```bash
code .
```

If this doesn’t work, make sure the `code` command is enabled in VS Code.

---

## 🔧 Customization

You can easily extend the script to:

* Add more libraries (e.g. `onnx`, `soundfile`, `matplotlib`)
* Generate custom notebooks
* Create project folder structures
* Add `requirements.txt`

---

## 🧪 Example workflow

```bash
git clone <this-repo>
cd project-init
./init.sh
```

Then:

* Open `main.ipynb`
* Select kernel
* Start coding

---

## 🚀 Future improvements (ideas)

* Automatic Python installation via `pyenv`
* CUDA-aware PyTorch install
* Prebuilt notebooks for ML/audio workflows
* Dataset folder templates
* ONNX / DSP toolchains

---

## 📄 License

MIT (or choose your preferred license)
