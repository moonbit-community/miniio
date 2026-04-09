///|
fn args_sizes_get_ffi(argc : Int, size : Int) -> UInt = "wasi_snapshot_preview1" "args_sizes_get"

///|
fn args_sizes_get() -> (Int, Int) raise Errno {
  let argc_ptr = @ffi.malloc(4)
  defer @ffi.free(argc_ptr)
  let size_ptr = @ffi.malloc(4)
  defer @ffi.free(size_ptr)
  check_errno(args_sizes_get_ffi(argc_ptr, size_ptr))
  (@ffi.load32(argc_ptr), @ffi.load32(size_ptr))
}

///|
fn args_get_ffi(argv : Int, argv_buf : Int) -> UInt = "wasi_snapshot_preview1" "args_get"

///|
fn args_get() -> Array[String] raise Errno {
  let (argc, size) = args_sizes_get()
  if argc == 0 {
    return []
  }
  let argv_ptr = @ffi.malloc(argc * 4)
  defer @ffi.free(argv_ptr)
  let argv_buf = Bytes::make(size, b'\x00')
  let argv_buf_ptr = @ffi.bytes2ptr(argv_buf)
  defer @ffi.free(argv_buf_ptr)
  check_errno(args_get_ffi(argv_ptr, argv_buf_ptr))
  let args = []
  for i in 0..<argc {
    let start = @ffi.load32(argv_ptr + i * 4) - argv_buf_ptr
    let end = if i == argc - 1 {
      size
    } else {
      @ffi.load32(argv_ptr + (i + 1) * 4) - argv_buf_ptr
    }
    let len = end - start - 1
    args.push(argv_buf[start:start + len] |> @encoding/utf8.decode_lossy())
  }
  args
}

///|
pub fn args() -> Array[String] raise Errno {
  args_get()
}

///|
fn environ_sizes_get_ffi(argc : Int, size : Int) -> UInt = "wasi_snapshot_preview1" "environ_sizes_get"

///|
fn environ_sizes_get() -> (Int, Int) raise Errno {
  let argc_ptr = @ffi.malloc(4)
  defer @ffi.free(argc_ptr)
  let size_ptr = @ffi.malloc(4)
  defer @ffi.free(size_ptr)
  check_errno(environ_sizes_get_ffi(argc_ptr, size_ptr))
  (@ffi.load32(argc_ptr), @ffi.load32(size_ptr))
}

///|
fn environ_get_ffi(environ : Int, environ_buf : Int) -> UInt = "wasi_snapshot_preview1" "environ_get"

///|
fn environ_get() -> Array[(String, String)] raise Errno {
  let (argc, size) = environ_sizes_get()
  if argc == 0 {
    return []
  }
  let environ_ptr = @ffi.malloc(argc * 4)
  defer @ffi.free(environ_ptr)
  let environ_buf = Bytes::make(size, b'\x00')
  let environ_buf_ptr = @ffi.bytes2ptr(environ_buf)
  defer @ffi.free(environ_buf_ptr)
  check_errno(environ_get_ffi(environ_ptr, environ_buf_ptr))
  let envs = []
  for i in 0..<argc {
    let start = @ffi.load32(environ_ptr + i * 4) - environ_buf_ptr
    let end = if i == argc - 1 {
      size
    } else {
      @ffi.load32(environ_ptr + (i + 1) * 4) - environ_buf_ptr
    }
    let len = end - start - 1
    let entry = environ_buf[start:start + len] |> @encoding/utf8.decode_lossy()
    guard entry.split("=").collect() is [key, .. value]
    envs.push(
      (key.to_string(), value.iter().map(StringView::to_string).join("=")),
    )
  }
  envs
}

///|
pub fn envs() -> Array[(String, String)] raise Errno {
  environ_get()
}
