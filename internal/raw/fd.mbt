///|
fn fd_close_ffi(fd : Int) -> UInt = "wasi_snapshot_preview1" "fd_close"

///|
fn Fd::fd_close(self : Fd) -> Unit raise Errno {
  check_errno(fd_close_ffi(self.0))
}

///|
fn fd_prestat_get_ffi(fd : Int, buf : Int) -> UInt = "wasi_snapshot_preview1" "fd_prestat_get"

///|
fn Fd::fd_prestat_get(self : Fd) -> PreStat raise Errno {
  let buf_ptr = @ffi.malloc(8)
  defer @ffi.free(buf_ptr)
  check_errno(fd_prestat_get_ffi(self.0, buf_ptr))
  guard @ffi.load8_u(buf_ptr) is 0
  let size : Size = @ffi.load32_u(buf_ptr + 4)
  PreStat::Dir({ pr_name_len: size })
}

///|
fn fd_prestat_dir_name_ffi(fd : Int, path : Int, path_len : Int) -> UInt = "wasi_snapshot_preview1" "fd_prestat_dir_name"

///|
fn Fd::fd_prestat_dir_name(self : Fd) -> String raise Errno {
  guard self.fd_prestat_get() is Dir({ pr_name_len: Size(size) })
  let buffer = Bytes::make(size.reinterpret_as_int(), b'\x00')
  let buffer_ptr = @ffi.bytes2ptr(buffer)
  defer @ffi.free(buffer_ptr)
  check_errno(
    fd_prestat_dir_name_ffi(self.0, buffer_ptr, size.reinterpret_as_int()),
  )
  if buffer is [.. rest, b'\x00'] {
    @encoding/utf8.decode_lossy(rest)
  } else {
    @encoding/utf8.decode_lossy(buffer)
  }
}

///|
fn fd_read_ffi(fd : Int, iovs : Int, iovs_len : Int, nread : Int) -> UInt = "wasi_snapshot_preview1" "fd_read"

///|
fn Fd::fd_read(self : Fd, iovs : Array[FixedArray[Byte]]) -> Size raise Errno {
  let iovs_ptr = @ffi.malloc(iovs.length() * 8)
  defer @ffi.free(iovs_ptr)
  let ptrs = []
  for i, buf in iovs {
    let ptr = @ffi.byte_array2ptr(buf)
    ptrs.push(ptr)
    @ffi.store32(iovs_ptr + i * 8, ptr)
    @ffi.store32(iovs_ptr + i * 8 + 4, buf.length())
  }
  defer (for ptr in ptrs {
    @ffi.free(ptr)
  })
  let nread_ptr = @ffi.malloc(4)
  defer @ffi.free(nread_ptr)
  check_errno(fd_read_ffi(self.0, iovs_ptr, iovs.length(), nread_ptr))
  @ffi.load32_u(nread_ptr)
}

///|
fn fd_write_ffi(fd : Int, iovs : Int, iovs_len : Int, nwritten : Int) -> UInt = "wasi_snapshot_preview1" "fd_write"

///|
fn Fd::fd_write(self : Fd, contents : Array[BytesView]) -> Size raise Errno {
  let iovs_ptr = @ffi.malloc(contents.length() * 8)
  defer @ffi.free(iovs_ptr)
  let ptrs = []
  for i, content in contents {
    let ptr = @ffi.bytes2ptr(content.data())
    ptrs.push(ptr)
    @ffi.store32(iovs_ptr + i * 8, ptr + content.start_offset())
    @ffi.store32(iovs_ptr + i * 8 + 4, content.length())
  }
  defer (for ptr in ptrs {
    @ffi.free(ptr)
  })
  let nwritten_ptr = @ffi.malloc(4)
  defer @ffi.free(nwritten_ptr)
  check_errno(fd_write_ffi(self.0, iovs_ptr, contents.length(), nwritten_ptr))
  @ffi.load32_u(nwritten_ptr)
}

///|
fn fd_readdir_ffi(
  fd : Int,
  buf : Int,
  buf_len : Int,
  cookie : UInt64,
  buf_used : Int,
) -> UInt = "wasi_snapshot_preview1" "fd_readdir"

///|
fn Fd::fd_readdir(
  self : Fd,
  cookie? : DirCookie = DirCookie(0),
  buffer? : Bytes = Bytes::make(4096, 0),
) -> (Array[(String, DirEnt)], Bool) raise Errno {
  let buffer_ptr = @ffi.bytes2ptr(buffer)
  defer @ffi.free(buffer_ptr)
  let used_ptr = @ffi.malloc(4)
  defer @ffi.free(used_ptr)
  check_errno(
    fd_readdir_ffi(self.0, buffer_ptr, buffer.length(), cookie.0, used_ptr),
  )
  let used = @ffi.load32(used_ptr)
  let entries = []
  for i = 0; i < used; {
    if i + 24 > used {
      break (entries, true)
    }
    let next : DirCookie = @ffi.load64_u(buffer_ptr + i)
    let ino : Inode = @ffi.load64_u(buffer_ptr + i + 8)
    let namlen = @ffi.load32(buffer_ptr + i + 16)
    let type_ = FileType::from_value(@ffi.load8_u(buffer_ptr + i + 20)).unwrap()
    if i + 24 + namlen > used {
      break (entries, true)
    }
    entries.push(
      (
        buffer[i + 24:i + 24 + namlen] |> @encoding/utf8.decode_lossy(),
        {
          d_next: next,
          d_ino: ino,
          d_namlen: namlen.reinterpret_as_uint(),
          d_type: type_,
        },
      ),
    )
    continue i + 24 + namlen
  } nobreak {
    (entries, used == buffer.length())
  }
}

///|
fn fd_seek_ffi(
  fd : Int,
  offset : Int64,
  whence : UInt,
  newoffset : Int,
) -> UInt = "wasi_snapshot_preview1" "fd_seek"

///|
fn Fd::fd_seek(
  self : Fd,
  offset : FileDelta,
  whence : Whence,
) -> FileSize raise Errno {
  let newoffset_ptr = @ffi.malloc(8)
  defer @ffi.free(newoffset_ptr)
  check_errno(fd_seek_ffi(self.0, offset.0, whence.value(), newoffset_ptr))
  @ffi.load64_u(newoffset_ptr)
}

///|
fn fd_tell_ffi(fd : Int, newoffset : Int) -> UInt = "wasi_snapshot_preview1" "fd_tell"

///|
fn Fd::fd_tell(self : Fd) -> FileSize raise Errno {
  let newoffset_ptr = @ffi.malloc(8)
  defer @ffi.free(newoffset_ptr)
  check_errno(fd_tell_ffi(self.0, newoffset_ptr))
  @ffi.load64_u(newoffset_ptr)
}

///|
fn Fd::read_all(self : Fd, chunk_size? : Int = 4096) -> Bytes raise Errno {
  if chunk_size <= 0 {
    raise Inval
  }
  let chunks = []
  let mut total = 0
  while true {
    let buf = FixedArray::make(chunk_size, b'\x00')
    let read = self.fd_read([buf]).0.reinterpret_as_int()
    if read == 0 {
      break
    }
    chunks.push((buf, read))
    total += read
  }
  let result = FixedArray::make(total, b'\x00')
  let mut offset = 0
  for chunk in chunks {
    let (buf, len) = chunk
    result.unsafe_blit(offset, buf, 0, len)
    offset += len
  }
  result.unsafe_reinterpret_as_bytes()
}

///|
fn Fd::write_all(self : Fd, data : BytesView) -> Unit raise Errno {
  let mut view = data
  while view.length() > 0 {
    let written = self.fd_write([view]).0.reinterpret_as_int()
    if written <= 0 {
      raise IO
    }
    view = view[written:]
  }
}

///|
pub fn File::read(
  self : File,
  buf : FixedArray[Byte],
  offset? : Int = 0,
  max_len? : Int = buf.length() - offset,
) -> Int raise Errno {
  if offset < 0 ||
    max_len < 0 ||
    offset > buf.length() ||
    offset + max_len > buf.length() {
    raise Inval
  }
  if max_len == 0 {
    return 0
  }
  let tmp = FixedArray::make(max_len, b'\x00')
  let read = self.fd.fd_read([tmp]).0.reinterpret_as_int()
  tmp.blit_to(buf, len=read, dst_offset=offset)
  read
}

///|
pub fn File::write_once(self : File, data : BytesView) -> Int raise Errno {
  self.fd.fd_write([data]).0.reinterpret_as_int()
}

///|
pub fn File::close(self : File) -> Unit raise Errno {
  self.fd.fd_close()
}

///|
pub fn File::read_all(
  self : File,
  chunk_size? : Int = 4096,
) -> Bytes raise Errno {
  self.fd.read_all(chunk_size~)
}

///|
pub fn File::write_all(self : File, data : BytesView) -> Unit raise Errno {
  self.fd.write_all(data)
}

///|
pub fn File::write_text(self : File, text : StringView) -> Unit raise Errno {
  self.write_all(@encoding/utf8.encode(text)[:])
}

///|
pub fn File::seek(
  self : File,
  offset : Int64,
  from? : SeekFrom = Start,
) -> UInt64 raise Errno {
  self.fd.fd_seek(FileDelta(offset), from.to_whence()).0
}

///|
pub fn File::tell(self : File) -> UInt64 raise Errno {
  self.fd.fd_tell().0
}
