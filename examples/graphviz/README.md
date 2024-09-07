# Graphiz path example

This is an example of how to use the `doxygen` alongside `graphviz` to generate inheritance diagrams for C++ classes.
By default, `doxygen` looks for the `dot` executable in the system path, meaning that a system installation of `graphviz` will work out of the box.
If you want to make the build fully hermetic, you can specify the path to the `dot` executable in the `doxygen` rule, making it point to a `dot` binary of your choosing.

```bash
bazel build //doxyfile:doxygen
```

## Custom dot binary

To ensure the `dot` binary is available to the rule, make sure to add it to the sources of the macro.
Also, remember to add the `have_dot = True` parameter, otherwise no graphs will be produced.

```bzl
load("@doxygen//:doxygen.bzl", "doxygen")

# Assuming the binary is located in the same folder

filegroup(
    name = "dot_executable",
    srcs = select(
        {
            "@platforms//os:linux": ["dot"],
            "@platforms//os:macos": ["dot"],
            "@platforms//os:windows": ["dot"],
        },
        "Unsupported platform",
    ),
)

# Ideally, instead of using a local filegroup, you would want and external module, like "@graphviz//:bin/dot"

doxygen(
    name = "doxygen",
    srcs = glob([
        "*.h",
        "*.cpp",
        "*.sh",
    ]) + [":dot_executable"],
    dot_executable = ":dot_executable",
    have_dot = True,
    project_name = "graphviz",
)
```
