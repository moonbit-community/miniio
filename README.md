# minimum

Minimal WASIp1 MoonBit module with a wrapped public API. The direct preview1-shaped
calls stay internal.

Public API:

- `args_get()`
- `environ_get()`
- `get_env_var()`, `get_env_vars()`
- `moonbit-community/miniwasi/io::{Data, Reader, Writer}`
- `stdin`, `stdout`, `stderr`
- `open`, `create`
- `File::close`
- `File::read_all`
- `File::write_all`
- `File::write_text`
- `File::seek`
- `File::tell`
- `mkdir`, `remove`, `rmdir`
- `readdir`
- `exists`, `kind`, `is_dir`, `is_file`
- `read_file`, `write_file`
- `read_text_file`, `write_text_file`
- `Errno`, `CreateMode`, `FileKind`, `Mode`, `SeekFrom`

After importing `moonbit-community/miniwasi/io`, `File` also implements sync `Reader` and `Writer`,
so partial reads and streamed writes are available without exposing raw preview1 calls.

Internal only:

- `args_sizes_get`, `args_get`
- `environ_sizes_get`, `environ_get`
- `fd_read`, `fd_write`, `fd_close`, `fd_readdir`, `fd_prestat_*`, `fd_seek`, `fd_tell`
- `path_open`, `path_create_directory`, `path_unlink_file`, `path_remove_directory`
- preopen discovery and path resolution
- rights, flags, cookies, raw fd types

Still deliberately omitted:

- async runtime and async I/O
- detailed metadata/stat helpers such as `mtime`, sizes, permissions, and file descriptor rights
- symlink, rename, link, walk
- raw preview1-shaped public calls

Common file patterns:

```moonbit
let text = @miniwasi.read_text_file("data/input.txt")
@miniwasi.write_text_file("data/output.txt", text)
@miniwasi.write_file("data/raw.bin", b"bytes", create_mode=CreateOrTruncate)

let file = @miniwasi.open("data/log.txt", mode=WriteOnly, append=true)
file.write_text("line\n")
file.close()
```

WASIp1 paths are guest paths backed by explicit preopened directories. A program
that reads `data/input.txt` should be run with a matching preopen, for example:

```sh
wasmtime run --dir ./data::data _build/wasm/debug/build/<module>/<package>.wasm data/input.txt
```

The repository root is a Moon workspace. It includes the module itself and
separate example projects that use versioned dependencies, not local path
dependencies:

- `example/cli_tools`: small `cat`, `ls`, and `tree` commands.
- `example/lottie_manifest`: reads Lottie JSON with `cg-zhou/moon_lottie@0.3.0`
  and writes a text manifest. The renderer package is not used because it is
  `wasm-gc`-oriented.
- `example/morm_query`: writes SQL text using the synchronous query-builder
  surface of `oboard/morm@0.3.12`. It does not use Morm's async database engine
  APIs.

Check:

```sh
moon check --target wasm
moon test --target wasm
deno task test
```

The external package examples were validated with a recent Moon toolchain. The
Deno tasks prepend `$HOME/.moon/bin` to `PATH` so they use that toolchain when
it is installed.

Portable executable skill:

- `skills/miniwasi-portable-wasm`: agent guidance and a small template for
  building WASIp1 executables with `moonbit-community/miniwasi` installed through
  `moon add`.

Run the demo package:

```sh
moon run demo --target wasm
```
