///|
fn path_open_ffi(
  dirfd : Int,
  dirflags : UInt,
  path : Int,
  path_len : Int,
  oflags : UInt,
  fs_rights_base : UInt64,
  fs_rights_inheriting : UInt64,
  fs_flags : UInt,
  fd : Int,
) -> UInt = "wasi_snapshot_preview1" "path_open"

///|
fn Fd::path_open(
  self : Fd,
  dirflags : LookupFlags,
  path : String,
  oflags : OpenFlags,
  fs_rights_base : Rights,
  fs_rights_inheriting : Rights,
  fs_flags : FdFlags,
) -> Fd raise Errno {
  let path_bytes = @encoding/utf8.encode(path)
  let path_ptr = @ffi.bytes2ptr(path_bytes)
  defer @ffi.free(path_ptr)
  let fd_ptr = @ffi.malloc(4)
  defer @ffi.free(fd_ptr)
  check_errno(
    path_open_ffi(
      self.0,
      dirflags.0,
      path_ptr,
      path_bytes.length(),
      oflags.0,
      fs_rights_base.0,
      fs_rights_inheriting.0,
      fs_flags.0,
      fd_ptr,
    ),
  )
  Fd(@ffi.load32(fd_ptr))
}

///|
fn path_create_directory_ffi(fd : Int, path : Int, path_len : Int) -> UInt = "wasi_snapshot_preview1" "path_create_directory"

///|
fn Fd::path_create_directory(self : Fd, path : String) -> Unit raise Errno {
  let path_bytes = @encoding/utf8.encode(path)
  let path_ptr = @ffi.bytes2ptr(path_bytes)
  defer @ffi.free(path_ptr)
  check_errno(path_create_directory_ffi(self.0, path_ptr, path_bytes.length()))
}

///|
fn path_unlink_file_ffi(fd : Int, path : Int, path_len : Int) -> UInt = "wasi_snapshot_preview1" "path_unlink_file"

///|
fn Fd::path_unlink_file(self : Fd, path : String) -> Unit raise Errno {
  let path_bytes = @encoding/utf8.encode(path)
  let path_ptr = @ffi.bytes2ptr(path_bytes)
  defer @ffi.free(path_ptr)
  check_errno(path_unlink_file_ffi(self.0, path_ptr, path_bytes.length()))
}

///|
fn path_remove_directory_ffi(fd : Int, path : Int, path_len : Int) -> UInt = "wasi_snapshot_preview1" "path_remove_directory"

///|
fn Fd::path_remove_directory(self : Fd, path : String) -> Unit raise Errno {
  let path_bytes = @encoding/utf8.encode(path)
  let path_ptr = @ffi.bytes2ptr(path_bytes)
  defer @ffi.free(path_ptr)
  check_errno(path_remove_directory_ffi(self.0, path_ptr, path_bytes.length()))
}

///|
fn list_preopens() -> Array[(String, Fd)] raise Errno {
  let dirs = []
  for fd = 3; ; fd = fd + 1 {
    let prestat = Some(Fd(fd).fd_prestat_get()) catch {
      Badf => None
      e => raise e
    }
    if prestat is None {
      break
    }
    dirs.push((Fd(fd).fd_prestat_dir_name(), Fd(fd)))
  }
  dirs
}

///|
pub fn preopens() -> Array[String] raise Errno {
  let names = []
  for entry in list_preopens() {
    names.push(entry.0)
  }
  names
}

///|
fn resolve_path(path : StringView) -> (Fd, String) raise Errno {
  let preopens = list_preopens()
  let mut best_fd = Fd(0)
  let mut best_path = ""
  let mut best_len = -1
  for entry in preopens {
    let (dir_name, fd) = entry
    if path is ['/', .. path] {
      if dir_name == "/" {
        best_fd = fd
        best_path = if path == "" { "." } else { path.to_string() }
        best_len = 1
        continue
      }
      if !dir_name.has_prefix("/") {
        continue
      }
    } else {
      if dir_name.has_prefix("/") {
        continue
      }
      if dir_name == "." {
        if best_len < 0 {
          best_fd = fd
          best_path = if path == "" { "." } else { path.to_string() }
          best_len = 0
        }
        continue
      }
    }
    if path == dir_name {
      let len = dir_name.length()
      if len > best_len {
        best_fd = fd
        best_path = "."
        best_len = len
      }
    } else if path.has_prefix(dir_name + "/") {
      let len = dir_name.length()
      if len > best_len {
        best_fd = fd
        best_path = path[dir_name.length() + 1:].to_string()
        best_len = len
      }
    }
  }
  if best_len < 0 {
    raise Noent
  }
  (best_fd, best_path)
}

///|
fn file_rights(mode : Mode, can_resize : Bool) -> Rights {
  let mut rights = Rights::new() |> Rights::set(Fd_seek) |> Rights::set(Fd_tell)
  if mode is ReadOnly || mode is ReadWrite {
    rights = rights |> Rights::set(Fd_read)
  }
  if mode is WriteOnly || mode is ReadWrite {
    rights = rights |> Rights::set(Fd_write)
  }
  if can_resize {
    rights = rights |> Rights::set(Fd_filestat_set_size)
  }
  rights
}

///|
pub fn open(
  path : StringView,
  mode? : Mode = ReadOnly,
  append? : Bool = false,
  create? : Bool = false,
  truncate? : Bool = false,
) -> File raise Errno {
  let (base_fd, relative_path) = resolve_path(path)
  let mut oflags = OpenFlags::new()
  if create {
    oflags = oflags |> OpenFlags::set(Create)
  }
  if truncate {
    oflags = oflags |> OpenFlags::set(Trunc)
  }
  let mut fdflags = FdFlags::new()
  if append {
    fdflags = fdflags |> FdFlags::set(Append)
  }
  let needs_resize = truncate || mode is WriteOnly || mode is ReadWrite
  {
    fd: base_fd.path_open(
      LookupFlags::new(),
      relative_path,
      oflags,
      file_rights(mode, needs_resize),
      Rights::new(),
      fdflags,
    ),
  }
}

///|
pub fn open_read(path : StringView) -> File raise Errno {
  open(path, mode=ReadOnly)
}

///|
pub fn open_write(
  path : StringView,
  append? : Bool = false,
  create? : Bool = false,
  truncate? : Bool = false,
) -> File raise Errno {
  open(path, mode=WriteOnly, append~, create~, truncate~)
}

///|
pub fn create(path : StringView) -> File raise Errno {
  open(path, mode=WriteOnly, create=true, truncate=true)
}

///|
fn open_dir(path : StringView) -> Fd raise Errno {
  let (base_fd, relative_path) = resolve_path(path)
  let rights = Rights::new() |> Rights::set(Fd_read) |> Rights::set(Fd_readdir)
  let oflags = OpenFlags::new() |> OpenFlags::set(Directory)
  base_fd.path_open(
    LookupFlags::new(),
    relative_path,
    oflags,
    rights,
    rights,
    FdFlags::new(),
  )
}

///|
pub fn mkdir(path : StringView) -> Unit raise Errno {
  let (base_fd, relative_path) = resolve_path(path)
  base_fd.path_create_directory(relative_path)
}

///|
pub fn remove_file(path : StringView) -> Unit raise Errno {
  let (base_fd, relative_path) = resolve_path(path)
  base_fd.path_unlink_file(relative_path)
}

///|
pub fn remove_dir(path : StringView) -> Unit raise Errno {
  let (base_fd, relative_path) = resolve_path(path)
  base_fd.path_remove_directory(relative_path)
}

///|
pub fn readdir(
  path : StringView,
  buffer_size? : Int = 4096,
) -> Array[DirEntry] raise Errno {
  if buffer_size <= 0 {
    raise Inval
  }
  let fd = open_dir(path)
  defer ignore(try? fd.fd_close())
  let result : Array[DirEntry] = []
  let mut cookie : DirCookie = DirCookie(0)
  let mut current_size : Int = buffer_size
  while true {
    let (entries, more) = fd.fd_readdir(
      cookie~,
      buffer=Bytes::make(current_size, 0),
    )
    if entries.length() == 0 {
      if more {
        current_size = current_size * 2
        if current_size > 1_048_576 {
          raise Range
        }
        continue
      }
      break
    }
    for entry in entries {
      let (name, dirent) = entry
      if name == "." || name == ".." {
        continue
      }
      result.push({ name, kind: dirent.d_type.to_entry_kind() })
    }
    cookie = entries[entries.length() - 1].1.d_next
    if !more {
      break
    }
  }
  result
}

///|
pub fn readdir_names(
  path : StringView,
  buffer_size? : Int = 4096,
) -> Array[String] raise Errno {
  let names = []
  for entry in readdir(path, buffer_size~) {
    names.push(entry.name())
  }
  names
}

///|
pub fn read_file(path : StringView) -> Bytes raise Errno {
  let file = open_read(path)
  defer ignore(try? file.close())
  file.read_all()
}

///|
pub fn write_file(
  path : StringView,
  data : BytesView,
  append? : Bool = false,
  create? : Bool = false,
  truncate? : Bool = false,
) -> Unit raise Errno {
  let file = open_write(path, append~, create~, truncate~)
  defer ignore(try? file.close())
  file.write_all(data)
}

///|
pub fn write_text_file(
  path : StringView,
  text : StringView,
  append? : Bool = false,
  create? : Bool = false,
  truncate? : Bool = false,
) -> Unit raise Errno {
  write_file(path, @encoding/utf8.encode(text)[:], append~, create~, truncate~)
}
