# miniwasi

Portable WASIp1 SDK for MoonBit command-line tools and agent skills. It exposes
a small, wrapped API over WASIp1 while keeping direct preview1-shaped calls
internal.

## Public API

- `args_get()`
- `environ_get()`
- `get_env_var()`, `get_env_vars()`
- `moonbit-community/miniwasi/io::{Data, Reader, Writer}`
- `stdin`, `stdout`, `stderr`
- `open`, `create`
- `File::close`
- `File::write_all`
- `File::write_text`
- `File::seek`
- `File::tell`
- `Reader::{read, read_exactly, read_some, read_all, read_until}`
- `Writer::{write, write_reader}`
- `mkdir`, `remove_file`, `remove`, `rmdir`
- `readdir`
- `exists`, `kind`, `is_dir`, `is_file`
- `read_file`, `write_file`, `copy_file`
- `read_text_file`, `write_text_file`
- `read_json_file`, `write_json_file`
- `Errno`, `CreateMode`, `FileKind`, `Mode`, `SeekFrom`

After importing `moonbit-community/miniwasi/io`, `File` also implements
`Reader` and `Writer`, so partial reads and streamed writes are available
without exposing raw preview1 calls.

## Scope

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

Use `remove_file(path)` when the path must be a file, `rmdir(path)` when it must
be a directory, and `remove(path)` only when accepting either is intentional.

## Common File Patterns

```moonbit check
///|
test "copy text between files" {
  let dir = "readme_copy_text"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  @miniwasi.write_text_file(dir + "/input.txt", "hello\n")
  @miniwasi.copy_file(dir + "/input.txt", dir + "/output.txt")
  inspect(@miniwasi.read_text_file(dir + "/output.txt"), content="hello\n")
}
```

```moonbit check
///|
test "append log file" {
  let dir = "readme_append_log"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  let path = dir + "/tool.log"
  @miniwasi.write_text_file(path, "start\n")
  @miniwasi.write_text_file(path, "done\n", append=true)
  inspect(@miniwasi.read_text_file(path), content="start\ndone\n")
}
```

```moonbit check
///|
test "read and write json" {
  let dir = "readme_json"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  let path = dir + "/manifest.json"
  @miniwasi.write_json_file(path, { "name": "miniwasi", "portable": true })
  inspect(
    @miniwasi.read_json_file(path).stringify(),
    content="{\"name\":\"miniwasi\",\"portable\":true}",
  )
}
```

```moonbit check
///|
test "list and remove directories" {
  let dir = "readme_list_remove"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)

  @miniwasi.write_text_file(dir + "/b.txt", "b")
  @miniwasi.write_text_file(dir + "/a.txt", "a")
  inspect(@miniwasi.readdir(dir, sort=true), content="[\"a.txt\", \"b.txt\"]")

  @miniwasi.rmdir(dir, recursive=true)
  inspect(@miniwasi.exists(dir), content="false")
}
```

## WASIp1 Guest Paths

WASIp1 paths are guest paths backed by explicit preopened directories. A program
that reads `data/input.txt` should be run with a matching preopen, for example:

```sh
wasmtime run --dir ./data::data _build/wasm/debug/build/<module>/<package>.wasm data/input.txt
```

## Quick Eval

For quick experiments, `moon run -c` accepts MoonBit's single-file import
header, so you can try the API without creating a package:

```sh
printf '{"name":"miniwasi","ok":true}' | moon run -c 'import {
  "moonbit-community/miniwasi" @wasi,
  "moonbit-community/miniwasi/io",
  "moonbitlang/core/json" @json,
}

fn main {
  try {
    let input = @wasi.stdin.read_all().text()
    let value = @json.parse(input)
    @wasi.stdout.write_text(value.stringify(indent=2) + "\n")
  } catch {
    e => {
      @wasi.stderr.write_text("jq failed: \{e}\n") catch { _ => () }
      @wasi.exit(1)
    }
  }
}'
```

## Examples

The repository root is a Moon workspace. It includes the module itself and
separate example projects that use versioned dependencies, not local path
dependencies:

- `example/cli_tools`: small `cat`, `cp`, `ls`, and `tree` commands.
- `example/lottie_manifest`: reads Lottie JSON with `cg-zhou/moon_lottie@0.3.0`
  and writes a text manifest. The renderer package is not used because it is
  `wasm-gc`-oriented.
- `example/morm_query`: writes SQL text using the synchronous query-builder
  surface of `oboard/morm@0.3.12`. It does not use Morm's async database engine
  APIs.

Check:

```sh
moon check
moon test
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
moon run demo
```
