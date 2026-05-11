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
