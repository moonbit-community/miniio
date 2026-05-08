///|
trait Data {
  to_bytesview(Self) -> BytesView = _
  to_bytes(Self) -> Bytes
}

///|
impl Data with to_bytesview(self) {
  self.to_bytes()[:]
}

///|
pub impl Data for Bytes with to_bytes(self) {
  self
}

///|
pub impl Data for BytesView with to_bytes(self) {
  self.to_owned()
}

///|
pub impl Data for BytesView with to_bytesview(self) {
  self
}

///|
pub impl Data for String with to_bytes(self) {
  @utf8.encode(self)
}

///|
pub impl Data for StringView with to_bytes(self) {
  @utf8.encode(self)
}

///|
pub impl Data for Json with to_bytes(self) {
  @utf8.encode(self.stringify())
}

///|
pub fn &Data::binary(self : &Data) -> Bytes {
  self.to_bytes()
}

///|
pub fn &Data::text(self : &Data) -> String raise {
  self.to_bytes() |> @utf8.decode
}

///|
pub fn &Data::json(self : &Data) -> Json raise {
  self.to_bytes() |> @utf8.decode |> @json.parse
}
