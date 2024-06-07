"""Doxygen rule for Bazel."""

def _doxygen_impl(ctx):
    doxyfile = ctx.actions.declare_file("Doxyfile")
    outs = [ctx.actions.declare_directory(out) for out in ctx.attr.outs]

    if len(outs) == 0:
        fail("At least one output folder must be specified")

    output_path = outs[0].short_path.split("/")
    output_dir = output_path[0] if len(output_path) > 1 else ""

    ctx.actions.expand_template(
        template = ctx.file._config_file_template,
        output = doxyfile,
        substitutions = {
            "# {{INPUT}}": "INPUT = %s" % output_dir,
            "# {{ADDITIONAL PARAMETERS}}": "\\n".join(ctx.attr.configurations),
            "# {{OUTPUT DIRECTORY}}": "OUTPUT_DIRECTORY = %s" % doxyfile.dirname,
        },
    )

    ctx.actions.run(
        inputs = ctx.files.srcs + [doxyfile],
        outputs = outs,
        arguments = [doxyfile.path],
        progress_message = "Running doxygen",
        executable = ctx.executable._executable,
    )
    return [DefaultInfo(files = depset(outs))]

_doxygen = rule(
    doc = """Run the doxygen binary to generate the documentation.

It is advised to use the `doxygen` macro instead of this rule directly.

### Example

```starlark
# MODULE.bazel file
bazel_dep(name = "rules_doxygen", dev_dependency = True)
doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")
use_repo(doxygen_extension, "doxygen")
```

```starlark
# BUILD.bazel file
load("@doxygen//:doxygen.bzl", "doxygen")

doxygen(
    name = "doxygen",
    srcs = glob([
        "*.h",
        "*.cpp",
    ]),
    project_brief = "Example project for doxygen",
    project_name = "example",
)
```
""",
    implementation = _doxygen_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, doc = "The source files to generate documentation for. Can include header files, source files, and any other file Doxygen can parse."),
        "configurations": attr.string_list(doc = "Additional configuration parameters to append to the Doxyfile. For example, to set the project name, use `PROJECT_NAME = example`."),
        "outs": attr.string_list(default = ["html"], allow_empty = False, doc = """The output folders to keep. If only the html outputs is of interest, the default value will do. Otherwise, a list of folders to keep is expected (e.g. `["html", "latex"]`)."""),
        "_config_file_template": attr.label(
            allow_single_file = True,
            default = Label("@doxygen//:Doxyfile.template"),
            doc = "The template file to use for the Doxyfile.",
        ),
        "_executable": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("@doxygen//:executable"),
            doc = "The doxygen executable to use.",
        ),
    },
)

def doxygen(
        name,
        srcs,
        project_name = None,
        project_brief = None,
        configurations = [],
        outs = ["html"]):
    """
    Generates documentation using Doxygen.

    ### Example

    ```starlark
    # MODULE.bazel file
    bazel_dep(name = "rules_doxygen", dev_dependency = True)
    doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")
    use_repo(doxygen_extension, "doxygen")
    ```

    ```starlark
    # BUILD.bazel file
    load("@doxygen//:doxygen.bzl", "doxygen")

    doxygen(
        name = "doxygen",
        srcs = glob([
            "*.h",
            "*.cpp",
        ]),
        project_brief = "Example project for doxygen",
        project_name = "example",
    )
    ```
    Args:
        name: A name for the target.
        srcs: A list of source files to generate documentation for.
        project_name: The name of the project.
        project_brief: A brief description of the project.
        configurations: A list of additional configuration parameters to pass to Doxygen.
        outs: The output folders bazel will keep. If only the html outputs is of interest, the default value will do.
             otherwise, a list of folders to keep is expected (e.g. ["html", "latex"]).
    """
    if project_name == None:
        configurations.append("PROJECT_NAME = %s" % project_name)
    if project_brief == None:
        configurations.append("PROJECT_BRIEF = %s" % project_brief)
    _doxygen(
        name = name,
        srcs = srcs,
        outs = outs,
        configurations = configurations,
    )
