///|
pub(open) trait Reader {
  _get_internal_buffer(Self) -> ReaderBuffer
  _direct_read(Self, FixedArray[Byte], offset~ : Int, max_len~ : Int) -> Int raise
  read_sync(Self, FixedArray[Byte], offset? : Int, max_len? : Int) -> Int raise = _
  drop(Self, Int) -> Int raise = _
  read_exactly_sync(Self, len : Int) -> Bytes raise = _
  read_some_sync(Self, max_len? : Int) -> Bytes? raise = _
  read_all_sync(Self) -> &Data raise = _
  read_until_sync(Self, StringView) -> String? raise = _
}

///|
pub(all) suberror ReaderClosed derive(Debug, ToJson)

///|
impl Reader with read_sync(
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
impl Reader with drop(self, len) {
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
impl Reader with read_exactly_sync(self, len) {
  let buf = FixedArray::make(len, b'\x00')
  for received = 0; received < len; {
    let new_received = self.read_sync(
      buf,
      offset=received,
      max_len=len - received,
    )
    if new_received == 0 {
      raise ReaderClosed
    }
    continue received + new_received
  }
  buf.unsafe_reinterpret_as_bytes()
}

///|
impl Reader with read_some_sync(self, max_len?) {
  let buf = self._get_internal_buffer()
  if buf.len() > 0 {
    let buf_bytes = buf.buf().unsafe_reinterpret_as_bytes()
    if max_len is Some(max_len) && max_len < buf.len() {
      let data = buf_bytes[buf.start():buf.start() + max_len].to_bytes()
      buf.set_start(buf.start() + max_len)
      buf.set_len(buf.len() - max_len)
      return Some(data)
    } else {
      let data = buf_bytes[buf.start():buf.start() + buf.len()].to_bytes()
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
    Some(buf.buf().unsafe_reinterpret_as_bytes()[:max_len].to_bytes())
  } else {
    let data = buf.buf().unsafe_reinterpret_as_bytes()[:n].to_bytes()
    buf.clear()
    Some(data)
  }
}

///|
impl Reader with read_all_sync(self) {
  let buffer_list = []
  let mut buffer = FixedArray::make(1024, b'\x00')
  let mut offset = 0
  while self.read_sync(buffer, offset~, max_len=buffer.length() - offset) is n &&
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
impl Reader with read_until_sync(self, sep) {
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
