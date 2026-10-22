# mac-finder-webp-convert

A macOS **Finder Quick Action** that converts images to **WebP** with selectable quality and parallel processing (multi-core).

Right-click any image in Finder → **Quick Actions → Convert to WebP**, pick quality + core mode, done.

## Features

- **Quality presets** — 40%, 50%, 65% (lossy WebP via `cwebp`).
- **Parallel processing** — converts many files at once, one file per CPU core.
  - **Low** = 2 cores · **Mid** = 4 cores · **High** = 8 cores
  - Only *performance* cores are used (max 8), efficiency cores stay idle.
  - ~4.7× faster than sequential conversion (benchmarked on Apple M1 Pro).
- **Single dialog** — quality + mode combined in one dropdown.
  - `Return` = use highlighted default (`50% - High (8 core)`)
  - `Escape` = cancel
- **Filename-safe** — null-delimited `xargs`, so spaces in filenames are fine.
- **Completion notification** — macOS banner when done.

## Requirements

- **macOS** (tested on Apple Silicon; works on Intel too — adjust core counts if needed)
- **`cwebp`** (from Google's `webp` package) installed via Homebrew:

```bash
brew install webp
```

- **Automator** (built into macOS) — used to install the workflow.

## Install

### One-liner (fastest)

Paste this single line into **Terminal** and press Enter:

```bash
curl -fsSL https://raw.githubusercontent.com/RafieRosliputra/mac-finder-webp-convert/main/install.sh | bash
```

It auto-installs `cwebp` (via Homebrew if missing), downloads the workflow, and registers it — nothing else needed.


### Option A — Quick (double-click)

1. Download / clone this repo.
2. In Finder, double-click **`Convert to WebP.workflow`**.
3. macOS asks *"You are opening an Automator workflow for the first time"* → click **Install** (or **Open**, then in Automator go to **File → Save As…** and save it as a Quick Action).
4. Done. The action appears under **Finder → right-click → Quick Actions**.

> If "Install" isn't offered, in Automator click **File → Convert To… → Quick Action**, then save.

### Option B — Manual (copy into Services folder)

Copy the workflow bundle into the user's Services directory:

```bash
cp -R "Convert to WebP.workflow" ~/Library/Services/
```

Then register it so macOS picks it up immediately:

```bash
/System/Library/CoreServices/pbs -flush
```

> The `~/Library/Services/` folder is where macOS stores all Automator Quick Actions. You can open it in Finder with `⌘⇧G` and pasting `~/Library/Services/`.

### Verify

1. Right-click any `.jpg` / `.png` / `.tiff` / `.bmp` in Finder.
2. Hover **Quick Actions** → **Convert to WebP** should be listed.
3. Click it → dialog appears → press **Return** for default (50%, 8 cores).

## Usage

| Input | Output |
|-------|--------|
| `photo.jpg` | `photo.webp` (same name, same folder) |
| `image 01.png` | `image 01.webp` |

Supported input formats: `jpg`, `jpeg`, `png`, `tiff`, `bmp`. Other file types are ignored.

## How it works

The Quick Action is an **Automator "Run Shell Script"** workflow. The core logic:

1. Shows a native `choose from list` dialog (AppleScript) with 9 quality×mode combinations.
2. Maps the choice to `cwebp -q <quality>` and a concurrency count `NPROC`.
3. Feeds selected files (null-delimited) into `xargs -P $NPROC`, running `NPROC` parallel `cwebp` processes — one per file, one per core.
4. Shows a completion notification.

See [`convert_to_webp.sh`](convert_to_webp.sh) for the full script.

### Why not GPU?

WebP (libwebp) encoding is **CPU-only**. There is no Metal GPU encoder for WebP on Apple Silicon (the only GPU WebP encoder, NVIDIA's `nvImageCodec`, is CUDA/NVIDIA-only). Parallel CPU processing is the fastest available approach — see benchmark below.

## Benchmark

10 images (6000×4000), Apple M1 Pro (8 P-cores + 2 E-cores):

| Mode | Time |
|------|------|
| Sequential (1 core) | 35.98 s |
| Parallel (8 cores) | **7.68 s** |

~4.7× speedup.

## Customizing

Edit the workflow in **Automator** (double-click the `.workflow`), or edit `convert_to_webp.sh` directly:

- **Change quality presets** — edit the list in the `choose from list` line and the `case` mapping.
- **Change core counts** — edit the `NPROC=` values in the `case` block. Set max ≤ your number of performance cores to avoid using efficiency cores.
- **Change default selection** — edit `default items {"50% - High (8 core)"}`.

## License

MIT
