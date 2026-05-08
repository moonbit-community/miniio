///|
fn write(data : String) -> Unit {
  @miniwasi.stdout.write_text(data) catch {
    err => abort("stdout failed: \{err}")
  }
}

///|
fn write_line(line : String) -> Unit {
  write(line + "\n")
}

///|
fn usage() -> Unit {
  write_line("usage: cli_tools <cat|ls|tree> <path>")
}

///|
fn path_join(parent : String, name : String) -> String {
  if parent == "." || parent == "" {
    name
  } else {
    parent + "/" + name
  }
}

///|
fn cat(path : String) -> Unit {
  let text = @miniwasi.read_file(path).text() catch {
    err => abort("cat failed: \{err}")
  }
  write(text)
}

///|
fn ls(path : String) -> Unit {
  let entries = @miniwasi.readdir(path, sort=true) catch {
    err => abort("ls failed: \{err}")
  }
  for entry in entries {
    write_line(entry)
  }
}

///|
fn tree(path : String, indent : String) -> Unit {
  write_line(indent + path)
  let entries = @miniwasi.readdir(path, sort=true) catch { _ => return }
  for entry in entries {
    tree(path_join(path, entry), indent + "  ")
  }
}

///|
fn main {
  let args = @miniwasi.args_get() catch { err => abort("args failed: \{err}") }
  if args.length() < 3 {
    usage()
    return
  }
  let command = args[1]
  let path = args[2]
  match command {
    "cat" => cat(path)
    "ls" => ls(path)
    "tree" => tree(path, "")
    _ => usage()
  }
}
