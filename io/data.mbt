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
trait Data {
  fn to_bytesview(Self) -> BytesView = _
  fn to_bytes(Self) -> Bytes
}

///|
impl Data with fn to_bytesview(self) {
  self.to_bytes()[:]
}

///|
pub impl Data for Bytes with fn to_bytes(self) {
  self
}

///|
pub impl Data for BytesView with fn to_bytes(self) {
  self.to_owned()
}

///|
pub impl Data for BytesView with fn to_bytesview(self) {
  self
}

///|
pub impl Data for String with fn to_bytes(self) {
  @utf8.encode(self)
}

///|
pub impl Data for StringView with fn to_bytes(self) {
  @utf8.encode(self)
}

///|
pub impl Data for Json with fn to_bytes(self) {
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
