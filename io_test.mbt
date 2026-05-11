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
test "file implements io reader and writer" {
  let dir = "minimum_test_io"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer ignore(try? @miniio.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  let writer = @miniio.create(path)
  writer.write("hello")
  writer.write(", moonbit")
  writer.close()

  let reader = @miniio.open(path)
  let dst = FixedArray::make(4, b'\x00')
  let n = reader.read(dst, max_len=2)
  inspect(n, content="2")
  debug_inspect(reader.read_until(", "), content="Some(\"llo\")")
  inspect(reader.read_all().text(), content="moonbit")
  reader.close()
}

///|
test "write_reader copies file content" {
  let dir = "minimum_test_copy"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer ignore(try? @miniio.rmdir(dir, recursive=true))

  let src_path = dir + "/src.txt"
  let dst_path = dir + "/dst.txt"

  let src_writer = @miniio.create(src_path)
  src_writer.write("copy me")
  src_writer.close()

  let src = @miniio.open(src_path)
  let dst = @miniio.create(dst_path)
  dst.write_reader(src)
  src.close()
  dst.close()

  let copied = @miniio.open(dst_path)
  inspect(copied.read_all().text(), content="copy me")
  copied.close()
}
