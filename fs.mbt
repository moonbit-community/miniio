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
  create_mode? : CreateMode = OpenExisting,
) -> File raise Errno {
  {
    raw: wrap(() => {
      @raw.open(
        path,
        mode=mode.to_raw(),
        append~,
        create_mode=create_mode.to_raw(),
      )
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
pub fn remove_file(path : StringView) -> Unit raise Errno {
  wrap(() => @raw.remove_file(path))
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
pub fn kind(path : StringView) -> FileKind raise Errno {
  try {
    ignore(readdir(path, include_hidden=true, sort=false))
    Directory
  } catch {
    Notdir => {
      let file = open(path, mode=ReadOnly)
      file.close()
      Regular
    }
    Acces | Perm =>
      try {
        let file = open(path, mode=ReadOnly)
        file.close()
        Regular
      } catch {
        Isdir => Directory
        e => raise e
      }
    e => raise e
  }
}

///|
pub fn exists(path : StringView) -> Bool raise Errno {
  try {
    ignore(kind(path))
    true
  } catch {
    Noent | Notdir => false
    Acces | Perm => true
    e => raise e
  }
}

///|
pub fn is_dir(path : StringView) -> Bool raise Errno {
  kind(path) is Directory
}

///|
pub fn is_file(path : StringView) -> Bool raise Errno {
  kind(path) is Regular
}

///|
pub fn rmdir(path : StringView, recursive? : Bool = false) -> Unit raise Errno {
  if recursive {
    for entry in readdir(path, include_hidden=true, sort=false) {
      let entry_path = path.to_owned() + "/" + entry
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
fn default_create_mode(append : Bool, create_mode : CreateMode?) -> CreateMode {
  match create_mode {
    Some(mode) => mode
    None if append => OpenOrCreate
    None => CreateOrTruncate
  }
}

///|
pub fn write_file(
  path : StringView,
  data : &@io.Data,
  append? : Bool = false,
  create_mode? : CreateMode,
) -> Unit raise Errno {
  let create_mode = default_create_mode(append, create_mode)
  let file = open(path, mode=WriteOnly, append~, create_mode~)
  with_closed_file(file, file => file.write_all(data.binary()))
}

///|
pub fn copy_file(
  src : StringView,
  dst : StringView,
  append? : Bool = false,
  create_mode? : CreateMode,
) -> Unit raise Errno {
  let create_mode = default_create_mode(append, create_mode)
  let src_file = open(src, mode=ReadOnly)
  with_closed_file(src_file, src_file => {
    let dst_file = open(dst, mode=WriteOnly, append~, create_mode~)
    with_closed_file(dst_file, dst_file => {
      dst_file.write_reader_sync(src_file) catch {
        _ => raise IO
      }
    })
  })
}

///|
pub fn read_text_file(path : StringView) -> String raise Errno {
  let data = read_file(path)
  data.text() catch {
    _ => raise IO
  }
}

///|
pub fn read_json_file(path : StringView) -> Json raise Errno {
  let data = read_file(path)
  data.json() catch {
    _ => raise IO
  }
}

///|
pub fn write_text_file(
  path : StringView,
  text : StringView,
  append? : Bool = false,
  create_mode? : CreateMode,
) -> Unit raise Errno {
  let create_mode = default_create_mode(append, create_mode)
  write_file(path, text, append~, create_mode~)
}

///|
pub fn write_json_file(
  path : StringView,
  json : Json,
  append? : Bool = false,
  create_mode? : CreateMode,
) -> Unit raise Errno {
  let create_mode = default_create_mode(append, create_mode)
  write_file(path, json, append~, create_mode~)
}
