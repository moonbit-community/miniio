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
pub(open) trait Reader {
  fn _get_internal_buffer(Self) -> ReaderBuffer
  fn _direct_read(Self, FixedArray[Byte], offset~ : Int, max_len~ : Int) -> Int raise
  fn read(Self, FixedArray[Byte], offset? : Int, max_len? : Int) -> Int raise = _
  fn drop(Self, Int) -> Int raise = _
  fn read_exactly(Self, len : Int) -> Bytes raise = _
  fn read_some(Self, max_len? : Int) -> Bytes? raise = _
  fn read_all(Self) -> &Data raise = _
  fn read_until(Self, StringView) -> String? raise = _
}

///|
pub(all) suberror ReaderClosed derive(Debug, ToJson)

///|
impl Reader with fn read(
  self,
  dst,
  offset? = 0,
  max_len? = dst.length() - offset,
) {
  let buf = self._get_internal_buffer()
  if buf.len() > 0 {
    let n = @cmp.minimum(max_len, buf.len())
    buf.buf().blit_to(dst, src_offset=buf.start(), dst_offset=offset, len=n)
    buf.drop(n)
    n
  } else {
    self._direct_read(dst, offset~, max_len~)
  }
}

///|
impl Reader with fn drop(self, len) {
  let buf = self._get_internal_buffer()
  if buf.len() >= len {
    buf.drop(len)
    len
  } else {
    let buffered = buf.len()
    buf.drop(buffered)
    buf.enlarge_to(1)
    for dropped = buffered; dropped < len; {
      let received = self._direct_read(
        buf.buf(),
        offset=0,
        max_len=buf.buf().length(),
      )
      buf.set_len(received)
      if received == 0 {
        return dropped
      }
      continue dropped + received
    } nobreak {
      buf.set_start(buf.len() - (dropped - len))
      buf.set_len(dropped - len)
      len
    }
  }
}

///|
impl Reader with fn read_exactly(self, len) {
  let buf = FixedArray::make(len, b'\x00')
  for received = 0; received < len; {
    let new_received = self.read(buf, offset=received, max_len=len - received)
    if new_received == 0 {
      raise ReaderClosed
    }
    continue received + new_received
  }
  buf.unsafe_reinterpret_as_bytes()
}

///|
impl Reader with fn read_some(self, max_len?) {
  let buf = self._get_internal_buffer()
  if buf.len() > 0 {
    let buf_bytes = buf.buf().unsafe_reinterpret_as_bytes()
    if max_len is Some(max_len) && max_len < buf.len() {
      let data = buf_bytes[buf.start():buf.start() + max_len].to_owned()
      buf.set_start(buf.start() + max_len)
      buf.set_len(buf.len() - max_len)
      return Some(data)
    } else {
      let data = buf_bytes[buf.start():buf.start() + buf.len()].to_owned()
      buf.clear()
      return Some(data)
    }
  }
  buf.enlarge_to(if max_len is Some(max_len) { max_len } else { 1 })
  let n = self._direct_read(buf.buf(), offset=0, max_len=buf.buf().length())
  if n == 0 {
    return None
  }
  if max_len is Some(max_len) && max_len < n {
    buf.set_start(max_len)
    buf.set_len(n - max_len)
    Some(buf.buf().unsafe_reinterpret_as_bytes()[:max_len].to_owned())
  } else {
    let data = buf.buf().unsafe_reinterpret_as_bytes()[:n].to_owned()
    buf.clear()
    Some(data)
  }
}

///|
impl Reader with fn read_all(self) {
  let buffer_list = []
  let mut buffer = FixedArray::make(1024, b'\x00')
  let mut offset = 0
  while self.read(buffer, offset~, max_len=buffer.length() - offset) is n &&
        n > 0 {
    offset += n
    if offset == buffer.length() {
      buffer_list.push(buffer)
      buffer = FixedArray::make(1024, b'\x00')
      offset = 0
    }
  }
  let total_size = buffer_list.length() * 1024 + offset
  let result = FixedArray::make(total_size, b'\x00')
  for i, buf in buffer_list {
    result.unsafe_blit(i * 1024, buf, 0, 1024)
  }
  result.unsafe_blit(buffer_list.length() * 1024, buffer, 0, offset)
  result.unsafe_reinterpret_as_bytes()
}

///|
impl Reader with fn read_until(self, sep) {
  let sep = @utf8.encode(sep)
  let buf = self._get_internal_buffer()
  match buf.find_opt(sep, reader=self) {
    None if buf.len() > 0 => {
      let buf_bytes = buf.buf().unsafe_reinterpret_as_bytes()
      let remaining = @utf8.decode(
        buf_bytes[buf.start():buf.start() + buf.len()],
      )
      buf.drop(buf.len())
      Some(remaining)
    }
    None => None
    Some(index) => {
      let buf_bytes = buf.buf().unsafe_reinterpret_as_bytes()
      let result = @utf8.decode(buf_bytes[buf.start():buf.start() + index])
      buf.drop(index + sep.length())
      Some(result)
    }
  }
}
