load("@aspect_bazel_lib//lib:stamping.bzl", "STAMP_ATTRS", "maybe_stamp")

def _make_var_substitution_impl(ctx):
    vars = dict(ctx.attr.variables)
    stamp = maybe_stamp(ctx)
    if stamp:
        # You have access to the files
        # - stamp.volatile_status_file
        # - stamp.stable_status_file
        # If should somehow read the content of the file and set the variable
        vars["BUILD_EMBED_LABEL"] = "stamp.stable_status_file.BUILD_EMBED_LABEL"
    else:
        vars["BUILD_EMBED_LABEL"] = "0.0.0"
    return [platform_common.TemplateVariableInfo(vars)]

make_var_substitution = rule(
    implementation = _make_var_substitution_impl,
    attrs = dict({
        "variables": attr.string_dict(),
    }, **STAMP_ATTRS),
    doc = """Provides a set of variables to the template engine.

Example:

```bzl
make_var_substitution(
    variables = {
        "MY_VARIABLE": "my_value",
    },
)
```

This will make the variable `MY_VARIABLE` available to the template engine.
""",
)