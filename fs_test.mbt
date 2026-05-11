///|
test "write_file supports create append and truncate" {
  let dir = "minimum_test_write_file"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer ignore(try? @miniio.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  @miniio.write_file(path, b"hello")
  inspect(@miniio.read_file(path).text(), content="hello")

  @miniio.write_file(path, b" moonbit", append=true)
  inspect(@miniio.read_file(path).text(), content="hello moonbit")

  @miniio.write_file(path, b"reset", create_mode=TruncateExisting)
  inspect(@miniio.read_file(path).text(), content="reset")
}

///|
test "create modes distinguish existing files" {
  let dir = "minimum_test_create_mode"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer ignore(try? @miniio.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  @miniio.write_text_file(path, "first", create_mode=CreateNew)
  inspect(@miniio.read_text_file(path), content="first")

  inspect(
    try? @miniio.write_text_file(path, "second", create_mode=CreateNew),
    content="Err(Exist)",
  )

  @miniio.write_text_file(path, "second", create_mode=CreateOrTruncate)
  inspect(@miniio.read_text_file(path), content="second")
}

///|
test "readdir sorts and filters hidden entries" {
  let dir = "minimum_test_readdir"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer ignore(try? @miniio.rmdir(dir, recursive=true))

  @miniio.write_file(dir + "/b.txt", b"b")
  @miniio.write_file(dir + "/a.txt", b"a")
  @miniio.write_file(dir + "/.hidden", b"h")

  inspect(
    @miniio.readdir(dir, include_hidden=false, sort=true),
    content="[\"a.txt\", \"b.txt\"]",
  )
  inspect(
    @miniio.readdir(dir, include_hidden=true, sort=true),
    content="[\"a.txt\", \"b.txt\", \".hidden\"]",
  )
}

///|
test "exists and kind classify file and directory" {
  let dir = "minimum_test_kind"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer ignore(try? @miniio.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  @miniio.write_file(path, b"sample")

  assert_true(@miniio.exists(dir))
  assert_true(@miniio.exists(path))
  assert_false(@miniio.exists(dir + "/missing.txt"))

  assert_true(@miniio.kind(dir) is Directory)
  assert_true(@miniio.kind(path) is Regular)

  assert_true(@miniio.is_dir(dir))
  assert_false(@miniio.is_dir(path))
  assert_true(@miniio.is_file(path))
  assert_false(@miniio.is_file(dir))
}

///|
test "read_file returns io data" {
  let dir = "minimum_test_read_file"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer ignore(try? @miniio.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  @miniio.write_text_file(path, "hello")

  let data = @miniio.read_file(path)
  inspect(@miniio.read_text_file(path), content="hello")
  assert_eq(data.binary(), b"hello")
}

///|
test "copy_file copies through reader and writer" {
  let dir = "minimum_test_copy_file"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer ignore(try? @miniio.rmdir(dir, recursive=true))

  let src = dir + "/src.txt"
  let dst = dir + "/dst.txt"
  @miniio.write_text_file(src, "copy me")
  @miniio.copy_file(src, dst)
  inspect(@miniio.read_text_file(dst), content="copy me")
}

///|
test "json file helpers read and write json" {
  let dir = "minimum_test_json_file"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer ignore(try? @miniio.rmdir(dir, recursive=true))

  let path = dir + "/config.json"
  @miniio.write_json_file(path, { "name": "miniio", "ok": true })
  inspect(
    @miniio.read_json_file(path).stringify(),
    content="{\"name\":\"miniio\",\"ok\":true}",
  )
}

///|
test "remove and recursive rmdir delete created paths" {
  let dir = "minimum_test_remove"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer ignore(try? @miniio.rmdir(dir, recursive=true))

  let file_path = dir + "/sample.txt"
  let nested_dir = dir + "/nested"
  @miniio.write_file(file_path, b"sample")
  @miniio.mkdir(nested_dir)
  @miniio.write_file(nested_dir + "/child.txt", b"child")
  @miniio.write_file(nested_dir + "/.hidden", b"hidden")

  @miniio.remove_file(file_path)
  inspect(try? @miniio.remove(file_path), content="Err(Noent)")

  @miniio.rmdir(dir, recursive=true)
  inspect(try? @miniio.rmdir(dir), content="Err(Noent)")
}
