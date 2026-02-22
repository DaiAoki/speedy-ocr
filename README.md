# speedy-ocr

Fast PDF OCR CLI tool powered by macOS Vision Framework. Single binary, no external dependencies.

## Features

- **All Swift** — single universal binary, no Python or other runtimes needed
- **macOS Vision Framework** — high-quality OCR with Japanese and English support
- **Multiple output formats** — plain text, Markdown, JSON
- **Parallel processing** — automatically uses all CPU cores
- **Unix-friendly** — stdout by default, pipe to other tools

## Install

### Homebrew

```bash
brew install daiaoki/tap/speedy-ocr
```

### GitHub Releases

Download the universal binary from [Releases](https://github.com/daiaoki/speedy-ocr/releases).

### Mint

```bash
mint install daiaoki/speedy-ocr
```

### Build from source

```bash
git clone https://github.com/daiaoki/speedy-ocr.git
cd speedy-ocr
swift build -c release
# Binary at .build/release/speedy-ocr
```

## Usage

```bash
speedy-ocr [OPTIONS] <input-pdf>
```

### Options

| Option | Default | Description |
|---|---|---|
| `<input-pdf>` | (required) | Input PDF file path |
| `-o, --output` | stdout | Output file path |
| `-f, --format` | `txt` | Output format: `txt`, `md`, `json` |
| `--pages` | all | Page range: `1-10`, `5`, `1,3,5-7` |
| `--dpi` | `150` | Rendering DPI |
| `--language` | `ja,en` | Recognition languages (BCP 47, comma-separated) |
| `--no-language-correction` | off | Disable language correction |
| `--quiet` | off | Suppress progress output |

### Examples

```bash
# Basic: OCR a PDF and output text to stdout
speedy-ocr book.pdf

# Markdown output to file
speedy-ocr book.pdf -f md -o book.md

# Specific pages as JSON
speedy-ocr book.pdf -f json --pages 1-50 -o chapter1.json

# English-only document at high DPI
speedy-ocr document.pdf --language en --dpi 300

# Pipe to other tools
speedy-ocr book.pdf -f json | jq '.pages[].text'
```

## Output Formats

### Plain Text (`txt`)

Pages separated by blank lines. Empty pages are skipped.

### Markdown (`md`)

```markdown
# [filename]

## Page 1
[text]

## Page 2
[text]
```

### JSON (`json`)

```json
{
  "metadata": {
    "source": "book.pdf",
    "totalPages": 300,
    "processedPages": 50,
    "dpi": 150,
    "languages": ["ja", "en"],
    "elapsedSeconds": 45.2
  },
  "pages": [
    { "page": 1, "text": "..." }
  ]
}
```

## Requirements

- macOS 13 Ventura or later

## License

MIT
