///|
pub fn File::close(self : File) -> Unit raise Errno {
  wrap(() => self.raw.close())
}

///|
pub fn File::read_all(
  self : File,
  chunk_size? : Int = 4096,
) -> Bytes raise Errno {
  wrap(() => self.raw.read_all(chunk_size~))
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
pub impl @io.Reader for File with _get_internal_buffer(self) {
  self.read_buf
}

///|
pub impl @io.Reader for File with _direct_read(self, buf, offset~, max_len~) {
  wrap(() => self.raw.read(buf, offset~, max_len~))
}

///|
pub impl @io.Writer for File with write_once_sync(self, data) {
  wrap(() => self.raw.write_once(data))
}
