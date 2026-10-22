<div align="center">

# 🖼️ image-to-webp

**Convert images to WebP from the right-click menu — macOS *and* Windows, with parallel multi-core speed.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-11%2B-000000?logo=apple)](mac/)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?logo=windows)](windows/)
[![GitHub release](https://img.shields.io/github/v/release/RafieRosliputra/image-to-webp)](https://github.com/RafieRosliputra/image-to-webp/releases)

</div>

A right-click converter that turns images into **WebP** with selectable quality (40/50/65%) and multi-core parallel encoding (2/4/8 cores).

| Platform | Menu | Folder |
|----------|------|--------|
| 🍎 **macOS** | Finder → Quick Actions | [`mac/`](mac/) |
| 🪟 **Windows** | Explorer → Send to | [`windows/`](windows/) |

---

## ✨ Features (both platforms)

- 🎚️ **Quality presets** — 40% · 50% · 65% lossy WebP via `cwebp`
- ⚡ **Parallel encoding** — one file per core: Low (2) · Mid (4) · High (8)
- 🖥️ **Single dialog** — quality + mode combined
- ⌨️ **Keyboard-friendly** — `Enter` = default · `Esc` = cancel
- 🛡️ **Filename-safe** — spaces in filenames are fine
- 🔔 **Completion notification**
- 📦 **One-line install** on both platforms

---

## 🍎 macOS

### Install (one-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/RafieRosliputra/image-to-webp/main/mac/install.sh | bash
```

Then: right-click an image in Finder → **Quick Actions → Convert to WebP**.

> Full macOS docs, screenshot, and benchmark → [`mac/README.md`](mac/README.md)

## 🪟 Windows

### Install (one-liner, in PowerShell)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/RafieRosliputra/image-to-webp/main/windows/install.ps1 | iex"
```

Then: right-click an image in Explorer → **Send to → Convert to WebP**.

> Full Windows docs → [`windows/README.md`](windows/README.md)

---

## 📖 Quality × mode matrix

| | Low (2 core) | Mid (4 core) | High (8 core) |
|---|---|---|---|
| **40%** | ✅ | ✅ | ✅ |
| **50%** | ✅ | ✅ | ✅ *(default)* |
| **65%** | ✅ | ✅ | ✅ |

## ⚙️ How it works

1. The context-menu item receives the selected files.
2. A native dialog offers 9 quality×mode combinations.
3. The choice maps to `cwebp -q <quality>` + concurrency `N`.
4. Files are encoded in parallel — one `cwebp` process per file, up to `N` at a time.

**Why not GPU?** WebP (`libwebp`) is **CPU-only** — no Metal (macOS) or CUDA (Windows) encoder exists. Parallel CPU is the fastest available path.

## 📊 Benchmark (Apple M1 Pro, 10×6000×4000)

| Mode | Time | Speedup |
|------|------|---------|
| Sequential (1 core) | 35.98 s | 1.0× |
| Parallel (8 cores) | **7.68 s** | **4.7×** |

## 📄 License

[MIT](LICENSE) © [Rafie Rosliputra](https://github.com/RafieRosliputra)
