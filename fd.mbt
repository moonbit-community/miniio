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
pub fn File::close(self : File) -> Unit raise Errno {
  wrap(() => self.raw.close())
}

///|
pub fn File::write_all(self : File, data : BytesView) -> Unit raise Errno {
  wrap(() => self.raw.write_all(data))
}

///|
pub fn File::write_text(self : File, text : StringView) -> Unit raise Errno {
  wrap(() => self.raw.write_text(text))
}

///|
pub fn File::seek(
  self : File,
  offset : Int64,
  from? : SeekFrom = Start,
) -> UInt64 raise Errno {
  wrap(() => self.raw.seek(offset, from=from.to_raw()))
}

///|
pub fn File::tell(self : File) -> UInt64 raise Errno {
  wrap(() => self.raw.tell())
}

///|
pub impl @io.Reader for File with fn _get_internal_buffer(self) {
  self.read_buf
}

///|
pub impl @io.Reader for File with fn _direct_read(self, buf, offset~, max_len~) {
  wrap(() => self.raw.read(buf, offset~, max_len~))
}

///|
pub impl @io.Writer for File with fn write_once(self, data) {
  wrap(() => self.raw.write_once(data))
}
