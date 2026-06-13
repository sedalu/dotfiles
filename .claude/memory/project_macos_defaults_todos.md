---
name: macOS defaults automation TODOs
description: Future work items for automating macos-defaults catalog sync and update tracking
type: project
---

Future automation work for the macOS defaults system:

- **Parse macos-defaults repo**: Automate extracting defaults from the markdown files at github.com/yannbertrand/macos-defaults to generate/update settings.sh
- **Diff/update task**: Create a mise task that fetches the repo and reports new/changed defaults not in our catalog
- **Structured data**: Consider contributing a JSON/YAML export format to the macos-defaults project

**Why:** The current catalog in settings.sh was manually curated from macos-defaults.com. As the upstream repo adds new entries or macOS versions change defaults, we need a way to stay in sync.

**How to apply:** When revisiting the macos defaults system or adding new defaults, check if automation would reduce effort.
