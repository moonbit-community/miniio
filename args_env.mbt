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
pub fn args_get() -> Array[String] raise Errno {
  wrap(() => @raw.args())
}

///|
pub fn environ_get() -> Array[(String, String)] raise Errno {
  wrap(() => @raw.envs())
}

///|
pub fn get_env_var(key : StringView) -> String? raise Errno {
  let key = key.to_owned()
  for entry in environ_get() {
    let (entry_key, value) = entry
    if entry_key == key {
      return Some(value)
    }
  }
  None
}

///|
pub fn get_env_vars() -> Map[String, String] raise Errno {
  let envs = environ_get()
  let result : Map[String, String] = Map([], capacity=envs.length())
  for entry in envs {
    let (key, value) = entry
    result.set(key, value)
  }
  result
}

///|
fn proc_exit_ffi(rval : UInt) = "wasi_snapshot_preview1" "proc_exit"

///|
pub fn exit(code : Int) -> Unit {
  proc_exit_ffi(code.reinterpret_as_uint())
  panic()
}
