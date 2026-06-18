# ⚡️ fx_cli — Custom Flutter/Dart Command Line Tool

---

## 📦 1. Installation & Setup

### **Clone and Setup**

```bash
git clone <your_repo_url>
cd fx_cli
```

Install dependencies:

```bash
dart pub get
```

---

### **Option 1 — Activate Globally**

This allows you to run `fx_cli` from **any folder**:

```bash
dart pub global activate --source path .
```

Run CLI:

```bash
fx_cli <command>
```

> ⚠️ Note: Each time you run via `global activate`, Dart may check dependencies and run `pub get` if needed.

---

### **Option 2 — Build Binary (Standalone)**

This creates a **self-contained executable** that **does not re-run `pub get`**:

```bash
dart compile exe bin/cli_runner.dart -o fx_cli
```

Run binary directly:

```bash
./fx_cli <command>
```

> ✅ Advantages:
>
> * Fast startup
> * No pub get
> * Works without Dart SDK version conflicts
>
> 💡 You can optionally move it to your PATH:
>
> ```bash
> sudo mv fx_cli /usr/local/bin/
> ```

---

## 🚀 2. Usage

### **General Help**

```bash
fx_cli --help
```

Displays available commands and global options.

---

## 🔧 3. Build Binary (Standalone)

To create a standalone executable manually:

```bash
dart compile exe bin/cli_runner.dart -o fx_cli
```

Run:

```bash
./fx_cli
```

This binary **runs independently**, without dependency checks.
