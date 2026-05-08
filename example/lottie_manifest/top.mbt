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
fn inspect_lottie(json : Json) -> String raise {
  let animation = @parser.parse_animation(json)
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
  let json = @miniwasi.read_json_file(input) catch {
    err => abort("read failed: \{err}")
  }
  let manifest = inspect_lottie(json) catch {
    err => abort("parse failed: \{err}")
  }
  @miniwasi.write_text_file(output, manifest) catch {
    err => abort("write failed: \{err}")
  }
  write_line("manifest=\{output}")
}
