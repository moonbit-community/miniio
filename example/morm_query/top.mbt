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
fn main {
  let args = @miniio.args_get() catch { err => abort("args failed: \{err}") }
  if args.length() != 2 {
    write_line("usage: morm_query <output.sql>")
    return
  }
  let query = @morm.select_from("posts")
    .where_eq("published", true)
    .order_by(Desc("slug"))
    .limit(20)
  let (sql, _params) = @engine.render_query_sql(query)
  let output = args[1]
  @miniio.write_text_file(output, sql + "\n") catch {
    err => abort("write failed: \{err}")
  }
  write_line("sql=\{output}")
}
