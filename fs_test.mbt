///|
test "write_file supports create append and truncate" {
  let dir = "minimum_test_write_file"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  @miniwasi.write_file(path, b"hello")
  inspect(@miniwasi.read_file(path).text(), content="hello")

  @miniwasi.write_file(path, b" moonbit", append=true)
  inspect(@miniwasi.read_file(path).text(), content="hello moonbit")

  @miniwasi.write_file(path, b"reset", create_mode=TruncateExisting)
  inspect(@miniwasi.read_file(path).text(), content="reset")
}

///|
test "create modes distinguish existing files" {
  let dir = "minimum_test_create_mode"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  @miniwasi.write_text_file(path, "first", create_mode=CreateNew)
  inspect(@miniwasi.read_text_file(path), content="first")

  inspect(
    try? @miniwasi.write_text_file(path, "second", create_mode=CreateNew),
    content="Err(Exist)",
  )

  @miniwasi.write_text_file(path, "second", create_mode=CreateOrTruncate)
  inspect(@miniwasi.read_text_file(path), content="second")
}

///|
test "readdir sorts and filters hidden entries" {
  let dir = "minimum_test_readdir"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  @miniwasi.write_file(dir + "/b.txt", b"b")
  @miniwasi.write_file(dir + "/a.txt", b"a")
  @miniwasi.write_file(dir + "/.hidden", b"h")

  inspect(
    @miniwasi.readdir(dir, include_hidden=false, sort=true),
    content="[\"a.txt\", \"b.txt\"]",
  )
  inspect(
    @miniwasi.readdir(dir, include_hidden=true, sort=true),
    content="[\"a.txt\", \"b.txt\", \".hidden\"]",
  )
}

///|
test "exists and kind classify file and directory" {
  let dir = "minimum_test_kind"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  @miniwasi.write_file(path, b"sample")

  assert_true(@miniwasi.exists(dir))
  assert_true(@miniwasi.exists(path))
  assert_false(@miniwasi.exists(dir + "/missing.txt"))

  assert_true(@miniwasi.kind(dir) is Directory)
  assert_true(@miniwasi.kind(path) is Regular)

  assert_true(@miniwasi.is_dir(dir))
  assert_false(@miniwasi.is_dir(path))
  assert_true(@miniwasi.is_file(path))
  assert_false(@miniwasi.is_file(dir))
}

///|
test "read_file returns io data" {
  let dir = "minimum_test_read_file"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  @miniwasi.write_text_file(path, "hello")

  let data = @miniwasi.read_file(path)
  inspect(@miniwasi.read_text_file(path), content="hello")
  assert_eq(data.binary(), b"hello")
}

///|
test "remove and recursive rmdir delete created paths" {
  let dir = "minimum_test_remove"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  let file_path = dir + "/sample.txt"
  let nested_dir = dir + "/nested"
  @miniwasi.write_file(file_path, b"sample")
  @miniwasi.mkdir(nested_dir)
  @miniwasi.write_file(nested_dir + "/child.txt", b"child")
  @miniwasi.write_file(nested_dir + "/.hidden", b"hidden")

  @miniwasi.remove(file_path)
  inspect(try? @miniwasi.remove(file_path), content="Err(Noent)")

  @miniwasi.rmdir(dir, recursive=true)
  inspect(try? @miniwasi.rmdir(dir), content="Err(Noent)")
}
