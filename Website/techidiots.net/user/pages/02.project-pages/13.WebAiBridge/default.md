---
title: WebAiBridge
metadata:
    description: 'VS Code extension and Chrome extension that bridges workspace context to AI chat interfaces.'
    keywords: 'VS Code, AI, ChatGPT, Claude, Gemini, code context, developer tools, extension'
    author: 'TechIdiots LLC'
    robots: 'index, follow'
slug: webaibridge
template: default
---

# WebAiBridge

A VS Code extension + Chrome extension that lets you send code context from your editor directly to AI chat sites (ChatGPT, Claude, Gemini, etc.).

[GitHub Repository](https://github.com/TechIdiots-LLC/WebAiBridge)

---

## What It Does

- Right-click files or selections in VS Code → sends them to your AI chat
- Type `@` in AI chat inputs to pull context from VS Code
- Token counting with per-model limits
- Chunking for large content

---

## Architecture

```
┌─────────────┐     WebSocket      ┌─────────────────┐
│   VS Code   │◄──────────────────►│ Chrome Extension│
│  Extension  │    localhost:64923 │  (content.js)   │
└─────────────┘                    └────────┬────────┘
       │                                    │
       │ Reads files, selections,           │ Injects into
       │ problems, git diff, etc.           │ AI chat input
       │                                    │
       ▼                                    ▼
┌─────────────┐                    ┌─────────────────┐
│  Your Code  │                    │   AI Chat Site  │
│  Workspace  │                    │ (ChatGPT, etc.) │
└─────────────┘                    └─────────────────┘
```

The VS Code extension runs a local WebSocket server. The Chrome extension connects to it and injects content scripts into supported AI chat sites.

---

## Supported Sites

- ChatGPT / OpenAI
- Claude / Anthropic
- Gemini / Google AI Studio
- Microsoft Copilot (M365)

---

## Installation

### VS Code Extension

```bash
# From VSIX file
code --install-extension webaibridge-vscode-0.4.0.vsix

# Or build from source
cd vscode-extension
npm install
npm run package
```

### Chrome Extension

1. Go to `chrome://extensions`
2. Enable "Developer mode"
3. Click "Load unpacked"
4. Select the `web-extension` folder

---

## Usage

### Right-Click Menu
- **Add Selection to Context** — adds selected code
- **Add File to Context** — adds entire file

### @ Mentions
Type `@` in any supported AI chat input:

| Trigger | Description |
|---------|-------------|
| `@focused-file` | Currently open file |
| `@selection` | Selected text |
| `@visible-editors` | All visible editors |
| `@open-tabs` | All open files |
| `@problems` | Errors/warnings |
| `@file-tree` | Workspace structure |
| `@git-diff` | Uncommitted changes |
| `@terminal` | Terminal output |

### Per-Message Limits
Set a token limit in the popup. Choose what happens when exceeded:
- **Warn** — confirmation dialog
- **Chunk** — splits into parts
- **Truncate** — cuts to fit

### Multi-Instance
If you have multiple VS Code windows open, use the instance picker in the popup to switch between them.

---

## Token Counting

Uses a BPE-style approximation calibrated against GPT-4/Claude tokenizers. ~95% accuracy for English text and code.

Supported models:
- GPT-4, GPT-4o, GPT-4 Turbo (8K-128K)
- GPT-3.5 Turbo (4K-16K)
- Claude 3 Opus/Sonnet/Haiku (200K)
- Gemini Pro, 1.5 Pro/Flash (32K-1M)

---

## Roadmap

- [x] VS Code ↔ Browser bridge
- [x] Token counting
- [x] Context chips
- [x] @ mention system
- [x] Multi-instance support
- [x] Per-message limits and chunking
- [ ] Settings sync
- [ ] PDF/DOCX/Image extraction
- [ ] VS Code chat panel

---

## License

BSD-2-Clause

© 2025-2026 TechIdiots LLC
