#!/usr/bin/env bash
################################################################################
# Configure Code OSS + Continue for a small local Ollama coding model.
#
# Goals:
# - no remote API key required;
# - no background autocomplete by default;
# - one loaded Ollama model max;
# - small Qwen Coder model first, larger local model only as fallback.
################################################################################

set -euo pipefail

CONTINUE_DIR="${CONTINUE_DIR:-$HOME/.continue}"
CODE_OSS_USER_DIR="${CODE_OSS_USER_DIR:-$HOME/.config/Code - OSS/User}"
SYSTEMD_USER_DIR="${SYSTEMD_USER_DIR:-$HOME/.config/systemd/user}"
OLLAMA_BIN="${OLLAMA_BIN:-/usr/local/bin/ollama}"

mkdir -p "$CONTINUE_DIR" "$CODE_OSS_USER_DIR" "$SYSTEMD_USER_DIR"

cat > "$CONTINUE_DIR/config.yaml" <<'YAML'
name: Code OSS Local Light
version: 0.0.1
schema: v1

requestOptions:
  timeout: 120000

models:
  - name: Qwen Code Tiny
    provider: ollama
    model: qwen-code-tiny
    roles: [chat, edit, apply]
    contextLength: 2048
    defaultCompletionOptions:
      contextLength: 2048
      maxTokens: 384
      temperature: 0.2
      topP: 0.9
      keepAlive: 120
    autocompleteOptions:
      disable: true
      maxPromptTokens: 1024
      debounceDelay: 500
      modelTimeout: 5000
      onlyMyCode: true
      useCache: true
      useImports: false
      useRecentlyEdited: true
      useRecentlyOpened: false

  - name: Qwen Code Light
    provider: ollama
    model: qwen-code-light
    roles: [chat, edit, apply]
    contextLength: 4096
    defaultCompletionOptions:
      contextLength: 4096
      maxTokens: 768
      temperature: 0.2
      topP: 0.9
      keepAlive: 120

context:
  - provider: currentFile
  - provider: open
  - provider: diff
  - provider: terminal

rules:
  - name: local-light-mode
    rule: "Prefer small, focused edits. Do not run long commands or install packages unless explicitly requested. Avoid loading large project context unless the user asks."
    alwaysApply: true
YAML

cat > "$CONTINUE_DIR/.continuerc.json" <<'JSON'
{
  "disableIndexing": true
}
JSON

cat > "$CONTINUE_DIR/.continueignore" <<'IGNORE'
**/.git/**
**/node_modules/**
**/.venv/**
**/venv/**
**/__pycache__/**
**/.cache/**
**/target/**
**/dist/**
**/build/**
**/.next/**
**/.cursor/**
**/.vscode/**
**/*.zip
**/*.rar
**/*.7z
**/*.tar
**/*.tar.gz
**/*.tar.xz
**/*.iso
**/*.pak
**/*.ucas
**/*.utoc
**/*.mp4
**/*.mkv
**/*.webm
**/*.qcow2
**/*.img
/data/**
/home/pactivisme/.ollama/**
/home/pactivisme/.lmstudio/**
/home/pactivisme/.cache/**
/home/pactivisme/.local/share/Trash/**
IGNORE

cat > "$CONTINUE_DIR/qwen-code-tiny.Modelfile" <<'MODEL'
FROM qwen2.5-coder:0.5b
PARAMETER num_ctx 2048
PARAMETER num_predict 384
PARAMETER temperature 0.2
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.05
SYSTEM """
You are a tiny local coding assistant running in Code OSS through Continue.
Answer briefly, avoid broad context, and prefer small focused suggestions.
"""
MODEL

cat > "$CONTINUE_DIR/qwen-code-light.Modelfile" <<'MODEL'
FROM qwen2.5-coder:latest
PARAMETER num_ctx 4096
PARAMETER num_predict 768
PARAMETER temperature 0.2
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.05
SYSTEM """
You are a local coding assistant running in Code OSS through Continue.
Be concise, prefer small edits, avoid loading unnecessary context, and do not
start long-running or memory-heavy commands unless the user explicitly asks.
"""
MODEL

cat > "$SYSTEMD_USER_DIR/ollama-light.service" <<SERVICE
[Unit]
Description=Ollama local light service for Code OSS Continue
After=network.target

[Service]
Type=simple
ExecStart=$OLLAMA_BIN serve
Restart=on-failure
RestartSec=5
Environment=OLLAMA_HOST=127.0.0.1:11434
Environment=OLLAMA_MAX_LOADED_MODELS=1
Environment=OLLAMA_NUM_PARALLEL=1
Environment=OLLAMA_KEEP_ALIVE=2m
Environment=OLLAMA_LOAD_TIMEOUT=5m
Nice=10
IOSchedulingClass=idle
MemoryHigh=10G
MemoryMax=14G
TasksMax=256

[Install]
WantedBy=default.target
SERVICE

python3 - <<'PY'
import json
from pathlib import Path

settings_path = Path.home() / ".config/Code - OSS/User/settings.json"
settings = {}
if settings_path.exists() and settings_path.read_text(encoding="utf-8").strip():
    settings = json.loads(settings_path.read_text(encoding="utf-8"))

settings.update({
    "redhat.telemetry.enabled": False,
    "telemetry.telemetryLevel": "off",
    "files.confirmDelete": True,
    "files.confirmDragAndDrop": True,
    "search.followSymlinks": False,
    "search.useIgnoreFiles": True,
    "search.useGlobalIgnoreFiles": True,
    "extensions.autoCheckUpdates": False,
    "extensions.autoUpdate": False,
    "workbench.enableExperiments": False,
})

settings_path.parent.mkdir(parents=True, exist_ok=True)
settings_path.write_text(json.dumps(settings, indent=4, ensure_ascii=False) + "\n", encoding="utf-8")
PY

if command -v code-oss >/dev/null 2>&1; then
    code-oss --install-extension continue.continue >/dev/null 2>&1 || true
fi

if [ -x "$OLLAMA_BIN" ]; then
    systemctl --user daemon-reload
    systemctl --user enable --now ollama-light.service
    "$OLLAMA_BIN" pull qwen2.5-coder:0.5b
    "$OLLAMA_BIN" create qwen-code-tiny -f "$CONTINUE_DIR/qwen-code-tiny.Modelfile"
    if "$OLLAMA_BIN" list | awk '{print $1}' | grep -qx 'qwen2.5-coder:latest'; then
        "$OLLAMA_BIN" create qwen-code-light -f "$CONTINUE_DIR/qwen-code-light.Modelfile"
    fi
fi

echo "Code OSS + Continue local light configured."
