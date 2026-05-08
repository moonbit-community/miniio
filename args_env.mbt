///|
pub fn args_get() -> Array[String] raise Errno {
  wrap(() => @raw.args())
}

///|
pub fn environ_get() -> Array[(String, String)] raise Errno {
  wrap(() => @raw.envs())
}

///|
pub fn get_env_var(key : StringView) -> String? raise Errno {
  let key = key.to_owned()
  for entry in environ_get() {
    let (entry_key, value) = entry
    if entry_key == key {
      return Some(value)
    }
  }
  None
}

///|
pub fn get_env_vars() -> Map[String, String] raise Errno {
  let envs = environ_get()
  let result : Map[String, String] = Map([], capacity=envs.length())
  for entry in envs {
    let (key, value) = entry
    result.set(key, value)
  }
  result
}

///|
fn proc_exit_ffi(rval : UInt) = "wasi_snapshot_preview1" "proc_exit"

///|
pub fn exit(code : Int) -> Unit {
  proc_exit_ffi(code.reinterpret_as_uint())
  panic()
}
