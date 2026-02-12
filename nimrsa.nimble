# Package

version       = "2.0.0"
author        = "NimRSA Team"
description   = "Enterprise-grade RSA encryption library"
license       = "MIT"
srcDir        = "src"
skipDirs      = @["tests", "examples", "tools"]

requires "nim >= 1.6.0"
requires "bigints >= 0.7.0"

task test, "Run tests":
  exec "nim c -r tests/test_all.nim"

task docs, "Generate documentation":
  exec "nim doc --project --index:on --outdir:docs src/nimrsa.nim"

task example, "Run basic example":
  exec "nim c -r examples/basic_usage.nim"

task enterprise, "Run enterprise example":
  exec "nim c -r examples/enterprise_usage.nim"

task benchmark, "Run performance benchmarks":
  exec "nim c -d:release -r tests/benchmark.nim"
