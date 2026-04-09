# minimum

Minimal WASIp1 MoonBit module with a wrapped public API. The direct preview1-shaped
calls stay internal.

Public API:

- `args_get()`
- `environ_get()`
- `local/minimum/io::{Data, Reader, Writer}`
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
- `read_file`, `write_file`
- `Errno`, `Mode`, `SeekFrom`

After importing `local/minimum/io`, `File` also implements sync `Reader` and `Writer`,
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
- metadata/stat helpers such as `exists`, `kind`, `mtime`
- symlink, rename, link, walk
- generic `remove(path)` that needs file-type inspection

Check:

```sh
moon check
```

Run the demo package:

```sh
moon run demo --target wasm
```
