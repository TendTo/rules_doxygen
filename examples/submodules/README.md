# Submodules

This repository simulates a situation where a root module depends on `rules_doxygen` as well as other two modules, `submodule1` and `submodule2`, which also depend on `rules_doxygen`.
The goal is to make sure there are no conflicts between the different versions of `rules_doxygen` used by the root module and the submodules.

To try this example, move to either `submodule1`, `submodule2` or `root` and run the following command:

```bash
bazel build //:doxygen
```

## Using `dev_dependency`

Since `rules_doxygen` is usually juts a development dependency, it is recommended to set the `dev_dependency` parameter to `True` when declaring the dependency on `rules_doxygen` in the `MODULE.bazel` file of any module.

```bzl
# MODULE.bazel file

module(name = "my_module")

bazel_dep(name = "rules_doxygen", version = "...", dev_dependency = True)
```

This way, all modules that depend on `my_module` will not inherit the dependency on `rules_doxygen`, and will be free to use their own version of `rules_doxygen`.

## Build dependencies

If you use `rules_doxygen` as a build dependency, make sure to use the `repository` tag to avoid conflicts when your module is used by other modules.

```bzl
# MODULE.bazel file

module(name = "my_module")

bazel_dep(name = "rules_doxygen", version = "...")

doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")
doxygen_extension.repository(name = "submodule2_doxygen")
use_repo(doxygen_extension, "submodule2_doxygen")
```
