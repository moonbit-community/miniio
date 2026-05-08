///|
fn write_line(line : String) -> Unit {
  @miniwasi.stdout.write_text(line + "\n") catch {
    err => abort("stdout failed: \{err}")
  }
}

///|
fn animation_name(name : String?) -> String {
  match name {
    Some(name) => name
    None => ""
  }
}

///|
fn inspect_lottie(json_text : String) -> String raise {
  let animation = @parser.parse_animation(@json.parse(json_text))
  [
    "name=\{animation_name(animation.name)}",
    "size=\{animation.width}x\{animation.height}",
    "frames=\{animation.in_point}..\{animation.out_point}",
    "layers=\{animation.layers.length()}",
    "",
  ].join("\n")
}

///|
fn main {
  let args = @miniwasi.args_get() catch { err => abort("args failed: \{err}") }
  if args.length() != 3 {
    write_line("usage: lottie_manifest <input.json> <output.txt>")
    return
  }
  let input = args[1]
  let output = args[2]
  let json_text = @miniwasi.read_file(input).text() catch {
    err => abort("read failed: \{err}")
  }
  let manifest = inspect_lottie(json_text) catch {
    err => abort("parse failed: \{err}")
  }
  @miniwasi.write_file(output, manifest, create=true, truncate=true) catch {
    err => abort("write failed: \{err}")
  }
  write_line("manifest=\{output}")
}
