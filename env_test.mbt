///|
test "environment helpers mirror environ_get" {
  let envs = @miniio.environ_get()
  let env_map = @miniio.get_env_vars()

  for entry in envs {
    let (key, value) = entry
    inspect(env_map.get(key) == Some(value), content="true")
    inspect(@miniio.get_env_var(key) == Some(value), content="true")
  }

  let missing = @miniio.get_env_var("__MINIIO_ENV_KEY_THAT_SHOULD_NOT_EXIST__")
  inspect(missing is None, content="true")
}
