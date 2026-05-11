# Morm Query Example

This workspace member uses `oboard/morm@0.3.12` and
`moonbit-community/miniio` through versioned dependencies. It does not use a
local path dependency.

The example stays on Morm's synchronous query-builder surface. It does not open
a database, run migrations, or use async engine APIs.

```bash
moon run example/morm_query query.sql
```
