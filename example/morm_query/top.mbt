///|
fn write_line(line : String) -> Unit {
  @miniio.stdout.write_text(line + "\n") catch {
    err => abort("stdout failed: \{err}")
  }
}

///|
fn main {
  let args = @miniio.args_get() catch { err => abort("args failed: \{err}") }
  if args.length() != 2 {
    write_line("usage: morm_query <output.sql>")
    return
  }
  let query = @morm.select_from("posts")
    .where_eq("published", true)
    .order_by(Desc("slug"))
    .limit(20)
  let (sql, _params) = @engine.render_query_sql(query)
  let output = args[1]
  @miniio.write_text_file(output, sql + "\n") catch {
    err => abort("write failed: \{err}")
  }
  write_line("sql=\{output}")
}
