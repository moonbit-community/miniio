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
/// This type is for internal use only,
/// end users should not use this type directly.
#internal(internal, "this type is for internal use only")
struct ReaderBuffer(@io_buffer.Buffer)

///|
#internal(internal, "this function is for internal use only")
pub fn ReaderBuffer::new() -> ReaderBuffer {
  @io_buffer.new(0)
}

///|
fn ReaderBuffer::clear(self : Self) -> Unit {
  self.0.clear()
}

///|
fn ReaderBuffer::buf(self : Self) -> FixedArray[Byte] {
  self.0.buf
}

///|
fn ReaderBuffer::len(self : Self) -> Int {
  self.0.len
}

///|
fn ReaderBuffer::start(self : Self) -> Int {
  self.0.start
}

///|
fn ReaderBuffer::set_len(self : Self, len : Int) -> Unit {
  self.0.len = len
}

///|
fn ReaderBuffer::set_start(self : Self, start : Int) -> Unit {
  self.0.start = start
}

///|
fn ReaderBuffer::drop(self : Self, n : Int) -> Unit {
  self.0.drop(n)
}

///|
fn ReaderBuffer::enlarge_to(self : Self, n : Int) -> Unit {
  self.0.enlarge_to(n)
}

///|
fn[R : Reader] ReaderBuffer::try_ensure(
  self : Self,
  len : Int,
  reader~ : R,
) -> Bool raise {
  if self.len() >= len {
    return true
  }
  self.enlarge_to(len)
  let capacity = self.buf().length()
  while self.len() < len {
    let offset = self.start() + self.len()
    let n = reader._direct_read(self.buf(), offset~, max_len=capacity - offset)
    if n == 0 {
      return false
    }
    self.set_len(self.len() + n)
  }
  true
}

///|
fn[R : Reader] ReaderBuffer::find_opt(
  self : Self,
  target : Bytes,
  reader~ : R,
) -> Int? raise {
  let target_len = target.length()
  for searched = 0 {
    guard self.try_ensure(searched + target_len, reader~) else { return None }
    let len = self.len()
    let start = self.start() + searched
    let end = self.start() + len
    let region = self.buf().unsafe_reinterpret_as_bytes()[start:end]
    if region.find(target) is Some(i) {
      return Some(searched + i)
    }
    continue len - target_len + 1
  }
}
