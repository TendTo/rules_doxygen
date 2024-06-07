# Nested subpackages example

This is an example of how to use the rules in a nested subpackage that split the project in multiple libraries.
Move to the parent directory and run the following command:

```bash
bazel build //nested:doxygen
```

## Lib a

The `lib_a` library is in a subpackage, determined by the presence of a _BUILD.bazel_ file.
It must export a `filegroup` target to make the sources available to the `doxygen` rule.

```bzl
# BUILD.bazel file in the lib_a directory
filegroup(
    name = "sources",
    srcs = glob([
        "*.h",
        "*.cpp",
    ]),
    visibility = ["//visibility:public"],
)
```

```bzl
# BUILD.bazel file in this directory
doxygen(
    name = "doxygen",
    srcs = glob([
        "*.h",
        "*.cpp",
    ]) + ["//nested/lib_a:sources"],
    configurations = ["INPUT = nested nested/lib_a"]
    project_name = "nested",
)
```

## Lib b

The `lib_b` library does not have a _BUILD.bazel_ file, so it is not a subpackage.
Its files are available to the `doxygen` rule from its parent directory.

```bzl
# BUILD.bazel file in this directory
doxygen(
    name = "doxygen",
    srcs = glob([
        "*.h",
        "*.cpp",
        "lib_b/*.h",
        "lib_b/*.cpp",
    ]),
    configurations = ["INPUT = nested nested/lib_b"]
    project_name = "nested",
)
```

## Putting it all together

It is possible to fuse both approaches together, with the following _BUILD.bazel_ file:

```bzl
doxygen(
    name = "doxygen",
    srcs = glob([
        "*.h",
        "*.cpp",
        "lib_b/*.h",
        "lib_b/*.cpp",
    ]) + ["//nested/lib_a:sources"],
    configurations = [
        "INPUT = nested nested/lib_a nested/lib_b",
    ],
    project_brief = "Example project for doxygen",
    project_name = "nested",
)
```
