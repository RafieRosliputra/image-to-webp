<div align="center">

# 🪟 image-to-webp (Windows)

**Convert images to WebP from the right-click "Send to" menu — with parallel multi-core speed.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?logo=windows)](https://www.microsoft.com/windows/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell)](convert-to-webp.ps1)
[![GitHub release](https://img.shields.io/github/v/release/RafieRosliputra/image-to-webp)](https://github.com/RafieRosliputra/image-to-webp/releases)

A **Send to** entry that turns any image into **WebP** with selectable quality and multi-core parallel encoding.

</div>

---

## ✨ Features

| | |
|---|---|
| 🎚️ **Quality presets** | 40% · 50% · 65% lossy WebP via `cwebp` |
| ⚡ **Parallel encoding** | One file per core — Low (2) · Mid (4) · High (8) |
| 🖥️ **Single dialog** | Quality + mode combined in one list |
| ⌨️ **Keyboard-friendly** | `Enter` = default · `Esc` = cancel |
| 🛡️ **Filename-safe** | Handles spaces in filenames |
| 🔔 **Completion toast** | Native Windows notification when done |
| 📦 **One-line install** | PowerShell `irm ... | iex` |

## 🚀 Install

### One-liner (fastest)

Open **PowerShell** and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/RafieRosliputra/image-to-webp/main/windows/install.ps1 | iex"
```

This:
1. Downloads `cwebp.exe` (official Google libwebp binary) into `%LOCALAPPDATA%\image-to-webp\`.
2. Downloads `convert-to-webp.ps1` into the same folder.
3. Registers a **`Convert to WebP.cmd`** in `%APPDATA%\Microsoft\Windows\SendTo\`.

> **Prefer to review first?**
> ```powershell
> irm https://raw.githubusercontent.com/RafieRosliputra/image-to-webp/main/windows/install.ps1 -OutFile install.ps1
> notepad install.ps1
> powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1
> ```

### Verify

1. Right-click any `.jpg` / `.png` / `.tiff` / `.bmp` in Explorer.
2. Hover **Send to** → **Convert to WebP**.
3. Click it → press **Enter** for default (50%, 8 cores).

> **Tip:** On Windows 11, the full "Send to" list is hidden behind **"Show more options"** (or `Shift` + right-click) in the new context menu.

## 🧰 Requirements

- **Windows 10 / 11** (x64)
- **Windows PowerShell 5.1+** (built in — no install needed)
- **`cwebp.exe`** — downloaded automatically by the installer (no manual step)

## 📖 Usage

| Input | Output |
|-------|--------|
| `photo.jpg` | `photo.webp` |
| `image 01.png` | `image 01.webp` |

Supported input formats: `jpg`, `jpeg`, `png`, `tiff`, `bmp`. Others are ignored.

**Quality × mode matrix:**

| | Low (2 core) | Mid (4 core) | High (8 core) |
|---|---|---|---|
| **40%** | ✅ | ✅ | ✅ |
| **50%** | ✅ | ✅ | ✅ *(default)* |
| **65%** | ✅ | ✅ | ✅ |

## ⚙️ How it works

1. The **`Convert to WebP.cmd`** in `SendTo` receives the selected file paths (`%*`).
2. It invokes [`convert-to-webp.ps1`](convert-to-webp.ps1) with those paths.
3. A Windows Forms dialog lists 9 quality×mode combinations.
4. The choice maps to `cwebp -q <quality>` + concurrency `N`.
5. Files are encoded in parallel using `Start-Process` — one `cwebp` per file, up to `N` at a time.
6. A toast notification reports the result.

> **Note on cores:** unlike macOS, Windows does not expose a simple "performance vs efficiency core" API. On Intel 12th-gen+ / hybrid CPUs the OS scheduler handles core assignment automatically. The `N` value simply limits concurrent processes.

## 🔧 Customizing

Edit `convert-to-webp.ps1`:

- **Quality presets & core counts** — edit the `$Choices` array (each entry has `Q` and `N`).
- **Default selection** — change `$DefaultIndex`.
- **Input formats** — edit `$ValidExt`.

## ❓ FAQ

**Does it overwrite my original files?**
No. It creates a new `.webp` next to the original.

**What if a `.webp` with the same name already exists?**
It is overwritten.

**Where is it installed?**
Scripts go to `%LOCALAPPDATA%\image-to-webp\`; the SendTo shortcut goes to `%APPDATA%\Microsoft\Windows\SendTo\`.

**How do I uninstall?**
Delete the two folders above:
```powershell
Remove-Item "$env:APPDATA\Microsoft\Windows\SendTo\Convert to WebP.cmd"
Remove-Item -Recurse "$env:LOCALAPPDATA\image-to-webp"
```

## 📄 License

[MIT](../LICENSE) © [Rafie Rosliputra](https://github.com/RafieRosliputra)
