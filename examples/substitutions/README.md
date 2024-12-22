# Basic usage example

This is a basic example of how to use the doxygen rule with make variable substitutions.
The advantage of using make variable substitutions instead of directly working over the values passed to the doxygen rule is that you can access informations from other rules and toolchains and use them in the documentation.
Move to the parent directory and run the following command:

```bash
bazel build //substitutions:doxygen # Version 0.0.0
# or
bazel build //substitutions:doxygen --stamp --//substitutions:build_version=1.0.0
```

## Custom substitutions

First you need to define a simple rule that will create the substitutions for you.
Let's say we want to pass a version number to the doxygen rule from a command line flag, but only if the build is stamped.
So, first we use `skylib` to define a string flag.

```bzl
# BUILD.bazel

load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

string_flag(
    name = "build_version",
    build_setting_default = "0.0.0",
)
```

> [!TIP]  
> You can define an alias for the flag to make it easier to use in the command line.
> Create a `.bazelrc` file in the root of your workspace with the following content:
>
> ```bash
> build --flag_alias=build_version=//substitutions:build_version
> ```
>
> Now you can use `--build_version=1.0.0` instead of `--//substitutions:build_version=1.0.0`.

Then we create a substitution rule.

```bzl
# make_var_substitution.bzl

load("@aspect_bazel_lib//lib:stamping.bzl", "STAMP_ATTRS", "maybe_stamp")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

def _make_var_substitution_impl(ctx):
    vars = dict(ctx.attr.variables)
    stamp = maybe_stamp(ctx)
    if stamp:  # If the build is stamped, use the value from --//substitutions:build_version as the build version.
        vars["BUILD_VERSION"] = ctx.attr._build_version[BuildSettingInfo].value
    else:  # Otherwise use the hardcoded value.
        vars["BUILD_VERSION"] = "0.0.0"
    return [platform_common.TemplateVariableInfo(vars)]

make_var_substitution = rule(
    implementation = _make_var_substitution_impl,
    attrs = dict({
        "variables": attr.string_dict(),
        "_build_version": attr.label(default = "//substitutions:build_version"),
    }, **STAMP_ATTRS),
)
```

Finally, the substitution rule can be used as a toolchain in the doxygen rule.
All configurations using the make variable syntax will be replaced with the values defined in the make_var_substitution rule.

```bzl
# BUILD.bazel

load("@doxygen//:doxygen.bzl", "doxygen")
load("//substitutions:make_var_substitution.bzl", "make_var_substitution")

# Use the make_var_substitution rule to define some other custom substitutions
make_var_substitution(
    name = "make_var_substitution",
    variables = {
        "DESCRIPTION": "Example project for doxygen using make vars substitutions",
        "NAME": "substitutions",
    },
)

doxygen(
    name = "doxygen",
    srcs = glob([
        "*.h",
        "*.cpp",
    ]),
    project_brief = "$(DESCRIPTION)", # => "Example project for doxygen using make vars substitutions"
    project_name = "$(NAME)", # => "substitutions"
    project_number = "$(BUILD_VERSION)", # => "0.0.0" or "//substitutions:build_version" if the build is stamped
    toolchains = [":make_var_substitution"],
)
```
