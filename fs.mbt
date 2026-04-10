///|
fn[X] with_closed_file(
  file : File,
  work : (File) -> X raise Errno,
) -> X raise Errno {
  try work(file) catch {
    err =>
      try file.close() catch {
        close_err => raise close_err
      } noraise {
        _ => raise err
      }
  } noraise {
    value => {
      file.close()
      value
    }
  }
}

///|
pub fn open(
  path : StringView,
  mode? : Mode = ReadOnly,
  append? : Bool = false,
  create? : Bool = false,
  truncate? : Bool = false,
) -> File raise Errno {
  {
    raw: wrap(() => {
      @raw.open(path, mode=mode.to_raw(), append~, create~, truncate~)
    }),
    read_buf: @io.ReaderBuffer::new(),
  }
}

///|
pub fn create(path : StringView) -> File raise Errno {
  { raw: wrap(() => @raw.create(path)), read_buf: @io.ReaderBuffer::new() }
}

///|
pub fn mkdir(path : StringView) -> Unit raise Errno {
  wrap(() => @raw.mkdir(path))
}

///|
pub fn remove(path : StringView) -> Unit raise Errno {
  wrap(() => @raw.remove_file(path)) catch {
    Isdir | Perm => wrap(() => @raw.remove_dir(path))
    Acces =>
      wrap(() => @raw.remove_dir(path)) catch {
        Notdir => raise Acces
        e => raise e
      }
    e => raise e
  }
}

///|
pub fn readdir(
  path : StringView,
  include_hidden? : Bool = true,
  sort? : Bool = false,
) -> Array[String] raise Errno {
  let result = wrap(() => @raw.readdir_names(path))
  let result = if include_hidden {
    result
  } else {
    result.filter(fn(name) { !name.has_prefix(".") })
  }
  if sort {
    result.sort()
  }
  result
}

///|
pub fn rmdir(path : StringView, recursive? : Bool = false) -> Unit raise Errno {
  if recursive {
    for entry in readdir(path, include_hidden=true, sort=false) {
      let entry_path = path.to_string() + "/" + entry
      remove(entry_path) catch {
        Notempty => rmdir(entry_path, recursive=true)
        e => raise e
      }
    }
  }
  wrap(() => @raw.remove_dir(path))
}

///|
pub fn read_file(path : StringView) -> &@io.Data raise Errno {
  let file = open(path, mode=ReadOnly)
  with_closed_file(file, file => file.read_all())
}

///|
pub fn write_file(
  path : StringView,
  data : &@io.Data,
  append? : Bool = false,
  create? : Bool = false,
  truncate? : Bool = false,
) -> Unit raise Errno {
  let file = open(path, mode=WriteOnly, append~, create~, truncate~)
  with_closed_file(file, file => file.write_all(data.binary()))
}
