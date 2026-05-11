///|
fn write_stderr(line : String) -> Unit {
  @miniio.stderr.write_text(line + "\n") catch {
    err => abort("stderr failed: \{err}")
  }
}

///|
fn write_stdout(text : String) -> Unit {
  @miniio.stdout.write_text(text) catch {
    err => abort("stdout failed: \{err}")
  }
}

///|
fn main {
  let args = @miniio.args_get() catch { err => abort("args failed: \{err}") }
  if args.length() != 2 {
    write_stderr("usage: miniio-cli <guest-path>")
    return
  }

  let path = args[1]
  let text = @miniio.read_text_file(path) catch {
    err => abort("read failed: \{err}")
  }
  write_stdout(text)
}
