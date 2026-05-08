///|
fn write_stderr(line : String) -> Unit {
  @miniwasi.stderr.write_text(line + "\n") catch {
    err => abort("stderr failed: \{err}")
  }
}

///|
fn write_stdout(text : String) -> Unit {
  @miniwasi.stdout.write_text(text) catch {
    err => abort("stdout failed: \{err}")
  }
}

///|
fn main {
  let args = @miniwasi.args_get() catch { err => abort("args failed: \{err}") }
  if args.length() != 2 {
    write_stderr("usage: miniwasi-cli <guest-path>")
    return
  }

  let path = args[1]
  let text = @miniwasi.read_text_file(path) catch {
    err => abort("read failed: \{err}")
  }
  write_stdout(text)
}
