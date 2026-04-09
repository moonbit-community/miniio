///|
pub extern "wasm" fn store32(offset : Int, value : Int) =
  #|(func (param i32) (param i32) local.get 0 local.get 1 i32.store)

///|
pub extern "wasm" fn load8_u(offset : Int) -> Int =
  #|(func (param i32) (result i32) local.get 0 i32.load8_u)

///|
pub extern "wasm" fn load32(offset : Int) -> Int =
  #|(func (param i32) (result i32) local.get 0 i32.load)

///|
pub extern "wasm" fn load32_u(offset : Int) -> UInt =
  #|(func (param i32) (result i32) local.get 0 i32.load)

///|
pub extern "wasm" fn load64_u(offset : Int) -> UInt64 =
  #|(func (param i32) (result i64) local.get 0 i64.load)

///|
pub fn malloc(size : Int) -> Int {
  bytes2ptr(Bytes::make(size, b'\x00'))
}

///|
pub extern "wasm" fn free(position : Int) =
  #|(func (param i32) local.get 0 i32.const 8 i32.sub call $moonbit.decref)

///|
#owned(bytes)
pub extern "wasm" fn byte_array2ptr(bytes : FixedArray[Byte]) -> Int =
  #|(func (param i32) (result i32) local.get 0 i32.const 8 i32.add)

///|
#owned(bytes)
pub extern "wasm" fn bytes2ptr(bytes : Bytes) -> Int =
  #|(func (param i32) (result i32) local.get 0 i32.const 8 i32.add)
