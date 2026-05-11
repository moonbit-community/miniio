// Copyright 2026 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
fn write_line(line : String) -> Unit {
  @miniio.stdout.write_text(line + "\n") catch {
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
  let args = @miniio.args_get() catch { err => abort("args failed: \{err}") }
  if args.length() != 3 {
    write_line("usage: lottie_manifest <input.json> <output.txt>")
    return
  }
  let input = args[1]
  let output = args[2]
  let json = @miniio.read_json_file(input) catch {
    err => abort("read failed: \{err}")
  }
  let manifest = inspect_lottie(json) catch {
    err => abort("parse failed: \{err}")
  }
  @miniio.write_text_file(output, manifest) catch {
    err => abort("write failed: \{err}")
  }
  write_line("manifest=\{output}")
}
