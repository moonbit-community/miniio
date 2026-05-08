const textDecoder = new TextDecoder("utf-8");
const cliToolsWasm =
  "_build/wasm/debug/build/moonbit-community/miniwasi-example-cli-tools/miniwasi-example-cli-tools.wasm";

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEquals<T>(actual: T, expected: T, message?: string) {
  if (actual !== expected) {
    throw new Error(message ?? `Expected ${expected}, got ${actual}`);
  }
}

function assertIncludes(actual: string, expected: string) {
  assert(
    actual.includes(expected),
    `Expected ${JSON.stringify(actual)} to include ${JSON.stringify(expected)}`,
  );
}

async function runMoonPackage(
  pkg: string,
  args: string[] = [],
  env: Record<string, string> = {},
) {
  const output = await new Deno.Command("moon", {
    args: ["run", pkg, "--target", "wasm", ...args],
    stdout: "piped",
    stderr: "piped",
    env,
  }).output();
  return {
    code: output.code,
    stdout: textDecoder.decode(output.stdout),
    stderr: textDecoder.decode(output.stderr),
  };
}

async function buildMoonPackage(pkg: string) {
  const output = await new Deno.Command("moon", {
    args: ["build", pkg, "--target", "wasm"],
    stdout: "piped",
    stderr: "piped",
  }).output();
  assertEquals(output.code, 0, textDecoder.decode(output.stderr));
}

async function runWasmtime(args: string[]) {
  const output = await new Deno.Command("wasmtime", {
    args: ["run", ...args],
    stdout: "piped",
    stderr: "piped",
  }).output();
  return {
    code: output.code,
    stdout: textDecoder.decode(output.stdout),
    stderr: textDecoder.decode(output.stderr),
  };
}

Deno.test("moon run demo sees args and env", async () => {
  const output = await runMoonPackage("demo", ["alpha", "beta"], {
    MINIWASI_E2E_TOKEN: "env-value",
  });

  assertEquals(output.code, 0, output.stderr);
  assertIncludes(output.stdout, "- alpha\n");
  assertIncludes(output.stdout, "- beta\n");
  assertIncludes(output.stdout, "- MINIWASI_E2E_TOKEN=env-value\n");
});

Deno.test("moon run cli_tools cat reads a file", async () => {
  const tmpDir = `miniwasi_cli_${crypto.randomUUID()}`;
  const file = `${tmpDir}/input.txt`;
  const copied = `${tmpDir}/copied.txt`;
  await Deno.mkdir(tmpDir);
  await Deno.writeTextFile(file, "first\nsecond\n");
  try {
    const output = await runMoonPackage("example/cli_tools", ["cat", file]);

    assertEquals(output.code, 0, output.stderr);
    assertEquals(output.stdout, "first\nsecond\n");

    const copy = await runMoonPackage("example/cli_tools", ["cp", file, copied]);
    assertEquals(copy.code, 0, copy.stderr);
    assertEquals(await Deno.readTextFile(copied), "first\nsecond\n");
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("wasmtime preopen maps guest paths", async () => {
  const tmpDir = `miniwasi_preopen_${crypto.randomUUID()}`;
  await Deno.mkdir(`${tmpDir}/host`, { recursive: true });
  await Deno.writeTextFile(`${tmpDir}/host/input.txt`, "from preopen\n");
  try {
    await buildMoonPackage("example/cli_tools");
    const output = await runWasmtime([
      "--dir",
      `${tmpDir}/host::data`,
      cliToolsWasm,
      "cat",
      "data/input.txt",
    ]);

    assertEquals(output.code, 0, output.stderr);
    assertEquals(output.stdout, "from preopen\n");
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("wasmtime requires a matching preopen", async () => {
  await buildMoonPackage("example/cli_tools");
  const output = await runWasmtime([cliToolsWasm, "cat", "data/input.txt"]);

  assert(output.code !== 0, "cat without a matching preopen should fail");
});

Deno.test("wasmtime path resolution uses longest preopen prefix", async () => {
  const tmpDir = `miniwasi_prefix_${crypto.randomUUID()}`;
  await Deno.mkdir(`${tmpDir}/parent/nested`, { recursive: true });
  await Deno.mkdir(`${tmpDir}/child`, { recursive: true });
  await Deno.writeTextFile(`${tmpDir}/parent/nested/input.txt`, "parent\n");
  await Deno.writeTextFile(`${tmpDir}/child/input.txt`, "child\n");
  try {
    await buildMoonPackage("example/cli_tools");
    const output = await runWasmtime([
      "--dir",
      `${tmpDir}/parent::data`,
      "--dir",
      `${tmpDir}/child::data/nested`,
      cliToolsWasm,
      "cat",
      "data/nested/input.txt",
    ]);

    assertEquals(output.code, 0, output.stderr);
    assertEquals(output.stdout, "child\n");
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("wasmtime absolute guest paths require absolute preopens", async () => {
  const tmpDir = `miniwasi_absolute_${crypto.randomUUID()}`;
  await Deno.mkdir(`${tmpDir}/host`, { recursive: true });
  await Deno.writeTextFile(`${tmpDir}/host/input.txt`, "absolute\n");
  try {
    await buildMoonPackage("example/cli_tools");
    const withoutPreopen = await runWasmtime([
      "--dir",
      `${tmpDir}/host::data`,
      cliToolsWasm,
      "cat",
      "/sandbox/input.txt",
    ]);
    assert(
      withoutPreopen.code !== 0,
      "absolute guest path should not match a relative preopen",
    );

    const withPreopen = await runWasmtime([
      "--dir",
      `${tmpDir}/host::/sandbox`,
      cliToolsWasm,
      "cat",
      "/sandbox/input.txt",
    ]);
    assertEquals(withPreopen.code, 0, withPreopen.stderr);
    assertEquals(withPreopen.stdout, "absolute\n");
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("moon run cli_tools ls and tree use sandboxed file ops", async () => {
  const tmpDir = `miniwasi_tree_${crypto.randomUUID()}`;
  await Deno.mkdir(`${tmpDir}/src/nested`, { recursive: true });
  await Deno.writeTextFile(`${tmpDir}/README.txt`, "");
  await Deno.writeTextFile(`${tmpDir}/src/main.mbt`, "");
  await Deno.writeTextFile(`${tmpDir}/src/nested/leaf.txt`, "");
  try {
    const ls = await runMoonPackage("example/cli_tools", ["ls", tmpDir]);
    assertEquals(ls.code, 0, ls.stderr);
    assertEquals(ls.stdout, "src\nREADME.txt\n");

    const tree = await runMoonPackage("example/cli_tools", ["tree", tmpDir]);
    assertEquals(tree.code, 0, tree.stderr);
    assertEquals(
      tree.stdout,
      [
        tmpDir,
        `  ${tmpDir}/src`,
        `    ${tmpDir}/src/nested`,
        `      ${tmpDir}/src/nested/leaf.txt`,
        `    ${tmpDir}/src/main.mbt`,
        `  ${tmpDir}/README.txt`,
        "",
      ].join("\n"),
    );
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("moon run lottie_manifest parses a Lottie file", async () => {
  const tmpDir = `miniwasi_lottie_${crypto.randomUUID()}`;
  const input = `${tmpDir}/spinner.json`;
  const outputFile = `${tmpDir}/manifest.txt`;
  await Deno.mkdir(tmpDir);
  await Deno.writeTextFile(
    input,
    JSON.stringify({
      v: "5.7.4",
      fr: 30,
      ip: 0,
      op: 1,
      w: 64,
      h: 64,
      nm: "spinner",
      ddd: 0,
      assets: [],
      layers: [],
    }),
  );
  try {
    const output = await runMoonPackage("example/lottie_manifest", [
      input,
      outputFile,
    ]);

    assertEquals(output.code, 0, output.stderr);
    assertEquals(output.stdout, `manifest=${outputFile}\n`);
    const manifest = await Deno.readTextFile(outputFile);
    assertIncludes(manifest, "name=spinner\n");
    assertIncludes(manifest, "size=64x64\n");
    assertIncludes(manifest, "layers=0\n");
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("moon run morm_query writes generated SQL", async () => {
  const tmpDir = `miniwasi_morm_${crypto.randomUUID()}`;
  const outputFile = `${tmpDir}/query.sql`;
  await Deno.mkdir(tmpDir);
  try {
    const output = await runMoonPackage("example/morm_query", [outputFile]);

    assertEquals(output.code, 0, output.stderr);
    assertEquals(output.stdout, `sql=${outputFile}\n`);
    const sql = await Deno.readTextFile(outputFile);
    assertIncludes(sql, "SELECT");
    assertIncludes(sql, "posts");
    assertIncludes(sql, "published");
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});
