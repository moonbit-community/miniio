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
fn write(data : String) -> Unit {
  @miniio.stdout.write_text(data) catch {
    err => abort("stdout failed: \{err}")
  }
}

///|
fn write_line(line : String) -> Unit {
  write(line + "\n")
}

///|
fn usage() -> Unit {
  write_line("usage: cli_tools <cat|cp|ls|tree> <path> [output]")
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
  let text = @miniio.read_text_file(path) catch {
    err => abort("cat failed: \{err}")
  }
  write(text)
}

///|
fn cp(src : String, dst : String) -> Unit {
  @miniio.copy_file(src, dst) catch {
    err => abort("cp failed: \{err}")
  }
}

///|
fn ls(path : String) -> Unit {
  let entries = @miniio.readdir(path, sort=true) catch {
    err => abort("ls failed: \{err}")
  }
  for entry in entries {
    write_line(entry)
  }
}

///|
fn tree(path : String, indent : String) -> Unit {
  write_line(indent + path)
  let entries = @miniio.readdir(path, sort=true) catch { _ => return }
  for entry in entries {
    tree(path_join(path, entry), indent + "  ")
  }
}

///|
fn main {
  let args = @miniio.args_get() catch { err => abort("args failed: \{err}") }
  if args.length() < 3 {
    usage()
    return
  }
  let command = args[1]
  let path = args[2]
  match command {
    "cat" => cat(path)
    "cp" => if args.length() == 4 { cp(path, args[3]) } else { usage() }
    "ls" => ls(path)
    "tree" => tree(path, "")
    _ => usage()
  }
}
