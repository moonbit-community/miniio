///|
test "write_file supports create append and truncate" {
  let dir = "minimum_test_write_file"
  @minimum.remove(dir) catch {
    Noent => ()
    Notempty => @minimum.rmdir(dir, recursive=true)
    e => raise e
  }
  @minimum.mkdir(dir)
  defer ignore(try? @minimum.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  @minimum.write_file(path, b"hello", create=true)
  inspect(@minimum.read_file(path).text(), content="hello")

  @minimum.write_file(path, b" moonbit", append=true)
  inspect(@minimum.read_file(path).text(), content="hello moonbit")

  @minimum.write_file(path, b"reset", truncate=true)
  inspect(@minimum.read_file(path).text(), content="reset")
}

///|
test "readdir sorts and filters hidden entries" {
  let dir = "minimum_test_readdir"
  @minimum.remove(dir) catch {
    Noent => ()
    Notempty => @minimum.rmdir(dir, recursive=true)
    e => raise e
  }
  @minimum.mkdir(dir)
  defer ignore(try? @minimum.rmdir(dir, recursive=true))

  @minimum.write_file(dir + "/b.txt", b"b", create=true)
  @minimum.write_file(dir + "/a.txt", b"a", create=true)
  @minimum.write_file(dir + "/.hidden", b"h", create=true)

  inspect(
    @minimum.readdir(dir, include_hidden=false, sort=true),
    content="[\"a.txt\", \"b.txt\"]",
  )
  inspect(
    @minimum.readdir(dir, include_hidden=true, sort=true),
    content="[\"a.txt\", \"b.txt\", \".hidden\"]",
  )
}

///|
test "read_file returns io data" {
  let dir = "minimum_test_read_file"
  @minimum.remove(dir) catch {
    Noent => ()
    Notempty => @minimum.rmdir(dir, recursive=true)
    e => raise e
  }
  @minimum.mkdir(dir)
  defer ignore(try? @minimum.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  @minimum.write_file(path, "hello", create=true)

  let data = @minimum.read_file(path)
  inspect(data.text(), content="hello")
  assert_eq(data.binary(), b"hello")
}

///|
test "remove and recursive rmdir delete created paths" {
  let dir = "minimum_test_remove"
  @minimum.remove(dir) catch {
    Noent => ()
    Notempty => @minimum.rmdir(dir, recursive=true)
    e => raise e
  }
  @minimum.mkdir(dir)
  defer ignore(try? @minimum.rmdir(dir, recursive=true))

  let file_path = dir + "/sample.txt"
  let nested_dir = dir + "/nested"
  @minimum.write_file(file_path, b"sample", create=true)
  @minimum.mkdir(nested_dir)
  @minimum.write_file(nested_dir + "/child.txt", b"child", create=true)
  @minimum.write_file(nested_dir + "/.hidden", b"hidden", create=true)

  @minimum.remove(file_path)
  inspect(try? @minimum.remove(file_path), content="Err(Noent)")

  @minimum.rmdir(dir, recursive=true)
  inspect(try? @minimum.rmdir(dir), content="Err(Noent)")
}
