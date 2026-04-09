///|
pub(open) trait Writer {
  write_once_sync(Self, BytesView) -> Int raise
  write_sync(Self, &Data) -> Unit raise = _
  write_reader_sync(Self, &Reader) -> Unit raise = _
}

///|
impl Writer with write_sync(self, data) {
  let mut view = data.to_bytesview()
  while view.length() > 0 {
    let written = self.write_once_sync(view)
    view = view[written:]
  }
}

///|
impl Writer with write_reader_sync(self, reader) {
  let buf = reader._get_internal_buffer()
  if buf.len() > 0 {
    let buf_bytes = buf.buf().unsafe_reinterpret_as_bytes()
    self.write_sync(buf_bytes[buf.start():buf.start() + buf.len()])
    buf.clear()
  }
  buf.enlarge_to(1)
  let max_len = buf.buf().length()
  while reader._direct_read(buf.buf(), offset=0, max_len~) is n && n > 0 {
    let buf_bytes = buf.buf().unsafe_reinterpret_as_bytes()
    self.write_sync(buf_bytes[:n])
  }
}
