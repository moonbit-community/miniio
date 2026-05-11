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
fn main {
  try {
    @miniio.stdout.write_text("args:\n")
    for arg in @miniio.args_get() {
      @miniio.stdout.write_text("- \{arg}\n")
    }

    @miniio.stdout.write_text("env:\n")
    for env in @miniio.environ_get() {
      let (key, value) = env
      @miniio.stdout.write_text("- \{key}=\{value}\n")
    }
  } catch {
    e => try! @miniio.stderr.write_text("demo failed: \{e}\n")
  }
}
