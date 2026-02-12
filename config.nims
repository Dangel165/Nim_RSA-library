switch("path", "$projectDir/src")

when defined(release):
  switch("opt", "speed")
  switch("define", "danger")

switch("warning", "BareExcept:off")
