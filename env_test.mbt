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
test "environment helpers mirror environ_get" {
  let envs = @miniio.environ_get()
  let env_map = @miniio.get_env_vars()

  for entry in envs {
    let (key, value) = entry
    inspect(env_map.get(key) == Some(value), content="true")
    inspect(@miniio.get_env_var(key) == Some(value), content="true")
  }

  let missing = @miniio.get_env_var("__MINIIO_ENV_KEY_THAT_SHOULD_NOT_EXIST__")
  inspect(missing is None, content="true")
}
