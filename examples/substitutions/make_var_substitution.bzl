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
    doc = """Provides a set of variables to the template engine.
Any variable defined as $(VAR_NAME) in the rule using this as a toolchain will be replaced by the value of VAR_NAME.
It provides the following substitution variables by default:

- BUILD_VERSION: The version of the build. If the build is stamped, it will be taken from --stamp-version. Otherwise, it will be "0.0.0".

Example:

```bzl
make_var_substitution(
    variables = {
        "MY_VARIABLE": "my_value",
        "VERSION": "1.0.0",
    },
)

doxygen(
    name = "doxygen",
    srcs = ["main.cpp"],
    project_brief = "$(MY_VARIABLE)", # => "my_value"
    project_number = "$(VERSION)", # => "1.0.0"
    toolchains = [":make_var_substitution"],
)
```

This will make the variable `MY_VARIABLE` available to the template engine.
""",
)
