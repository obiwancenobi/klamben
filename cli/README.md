# klamben CLI

Dart CLI for scanning Flutter projects for design anti-patterns.

## Install

From source during development:

    dart pub global activate --source path cli/

## Usage

    klamben detect lib/
    klamben detect --format=html lib/
    klamben detect --format=html --output=report.html lib/
    klamben detect --format=json lib/
    klamben report lib/
    klamben report --output=dashboard.html lib/
    klamben list-rules
    klamben explain visual/hardcoded-color

### Commands

| Command | Description |
|---------|-------------|
| `detect [path]` | Scan .dart files for anti-patterns (default: `lib/`) |
| `report [path]` | Generate a rich HTML health dashboard |
| `list-rules` | Print all rules with id, category, severity, title |
| `explain <rule-id>` | Show full description of a rule |

### detect options

| Option | Description |
|--------|-------------|
| `--format`, `-f` | Output format: `text` (default), `json`, `html` |
| `--severity`, `-s` | Minimum severity: `info` (default), `warning`, `error` |
| `--output`, `-o` | Output file path for HTML format (default: `klamben-report.html`) |
| `--no-color` | Disable ANSI colors in text output |

### report options

| Option | Description |
|--------|-------------|
| `--severity`, `-s` | Minimum severity: `info` (default), `warning`, `error` |
| `--output`, `-o` | Output file path (default: `klamben-report.html`) |

### HTML Reports

`--format=html` generates a self-contained HTML file with a Gradient Premium dark theme, CSS-only charts, severity/category breakdowns, and collapsible findings detail. No external dependencies — works fully offline.

`report` generates an extended health dashboard that includes everything from the detect report plus rule coverage, per-category health scores, and actionable recommendations with fix hints.

See the root [README](../README.md) for the full project overview.
