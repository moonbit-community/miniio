---
name: miniwasi-portable-wasm
description: Build portable MoonBit WASIp1 command-line executables using moonbit-community/miniwasi as a normal dependency installed with moon add, including stdio, args/env, preopen-safe file I/O, and wasm run commands.
---

# Miniwasi Portable WASM

Use this when creating or revising a MoonBit executable that should work outside
this repository after `moon add moonbit-community/miniwasi`.

## Start

- For a new tool, copy `assets/miniwasi-cli/` and rename the module/package.
- For an existing tool, add the dependency with `moon add moonbit-community/miniwasi`.
- Keep the package target to WASM and make the package main-only:

```moonbit
import {
  "moonbit-community/miniwasi",
}

supported_targets = "wasm"

options(
  is_main: true,
)
```

Do not add explicit export-memory linker config. Current MoonBit toolchains add
the needed memory export for `is_main: true` WASM executables.

## I/O Rules

- Read args with `@miniwasi.args_get()`. `args[0]` is the executable name, so
  command arguments start at `args[1]`.
- Use `@miniwasi.stdin`, `stdout`, and `stderr` for stdio.
- Use `@miniwasi.read_file`, `write_file`, `open`, `create`, `readdir`, and
  `rmdir` instead of raw WASIp1 calls.
- Treat every filesystem path as guest-visible. WASIp1 has no ambient cwd.
- Document required preopens. For example, a program reading `data/input.txt`
  needs a run command such as:

```sh
wasmtime run --dir ./data::data _build/wasm/debug/build/<module>/<package>.wasm data/input.txt
```

## Validate

Run these before handoff:

```sh
moon check --target wasm
moon test --target wasm
moon build --target wasm
```

Prefer `moon run <pkg> --target wasm <args>` for quick development tests.
