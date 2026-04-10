///|
test "environment helpers mirror environ_get" {
  let envs = @miniwasi.environ_get()
  let env_map = @miniwasi.get_env_vars()

  for entry in envs {
    let (key, value) = entry
    assert_eq(env_map.get(key), Some(value))
    assert_eq(@miniwasi.get_env_var(key), Some(value))
  }

  assert_eq(
    @miniwasi.get_env_var("__MINIWASI_ENV_KEY_THAT_SHOULD_NOT_EXIST__"),
    None,
  )
}
