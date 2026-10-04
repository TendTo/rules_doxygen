# Graphviz example

This is an example of how to use `doxygen` alongside `graphviz` to generate inheritance, collaboration, and dependency diagrams for C++ classes.

Remember to set `have_dot = True`, otherwise no graphs will be produced.

```bash
bazel build //graphviz:doxygen
```

## Hermetic vs. Non-Hermetic Dot

Depending on how `graphviz` is provided, there are two mutually exclusive ways to configure the `dot` tool:

### 1. Hermetic Bazel target (`dot_executable`)

For a fully hermetic build using a Bazel target (e.g. from the BCR's [`@graphviz`](https://registry.bazel.build/modules/graphviz) module or a local target), pass the label to the **`dot_executable`** attribute.

> [!NOTE]
> The `@graphviz` module in BCR requires **Bazel >= 8.0.0**. If you are using Bazel >= 8, enable `bazel_dep(name = "graphviz", version = "14.0.0.bcr.3")` in `examples/MODULE.bazel`.

```bzl
load("@doxygen//:doxygen.bzl", "doxygen")

doxygen(
    name = "doxygen",
    srcs = glob([
        "*.h",
        "*.cpp",
    ]),
    dot_executable = "@graphviz//:dot",
    have_dot = True,
    project_name = "graphviz",
)
```

`rules_doxygen` automatically stages the executable into the execution sandbox tools and ensures Doxygen can resolve it regardless of working directory changes during documentation generation.

### 2. Non-hermetic host installation (`dot_path` or system `PATH`)

For a non-hermetic build using a host installation (such as Homebrew or a system package manager):

- **Specific host directory (`dot_path`)**: Specify the host directory containing the `dot` executable with `dot_path`, which corresponds directly to `DOT_PATH` in the generated `Doxyfile`:

  ```bzl
  doxygen(
      name = "doxygen",
      srcs = glob([
          "*.h",
          "*.cpp",
      ]),
      dot_path = "/home/linuxbrew/.linuxbrew/bin",  # or "/opt/homebrew/bin"
      have_dot = True,
      project_name = "graphviz",
  )
  ```

- **System `PATH` lookup**: If `dot` is installed in a standard location on your `PATH` (such as `/usr/bin/dot`), leave both `dot_executable` and `dot_path` unset. Doxygen will automatically search the system `PATH`.
