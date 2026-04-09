///|
pub fn args_get() -> Array[String] raise Errno {
  wrap(() => @raw.args())
}

///|
pub fn environ_get() -> Array[(String, String)] raise Errno {
  wrap(() => @raw.envs())
}
