"""Doxygen rule for Bazel."""

def _doxygen_impl(ctx):
    doxyfile = ctx.actions.declare_file("Doxyfile")
    outs = [ctx.actions.declare_directory(out) for out in ctx.attr.outs]

    if len(outs) == 0:
        fail("At least one output folder must be specified")

    input_dirs = {(file.dirname or "."): None for file in ctx.files.srcs}
    ctx.actions.expand_template(
        template = ctx.file.doxyfile_template,
        output = doxyfile,
        substitutions = {
            "# {{INPUT}}": "INPUT = %s" % " ".join(input_dirs.keys()),
            "# {{ADDITIONAL PARAMETERS}}": "\n".join(ctx.attr.configurations),
            "# {{OUTPUT DIRECTORY}}": "OUTPUT_DIRECTORY = %s" % doxyfile.dirname,
        },
    )

    ctx.actions.run(
        inputs = ctx.files.srcs + [doxyfile],
        outputs = outs,
        arguments = [doxyfile.path] + ctx.attr.doxygen_extra_args,
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
        "doxyfile_template": attr.label(
            allow_single_file = True,
            default = Label("@doxygen//:Doxyfile.template"),
            doc = """The template file to use to generate the Doxyfile. You can provide your own or use the default one. 
The following substitutions are available: 
- `# {{INPUT}}`: Subpackage directory in the sandbox.
- `# {{ADDITIONAL PARAMETERS}}`: Additional parameters given in the `configurations` attribute.
- `# {{OUTPUT DIRECTORY}}`: The directory provided in the `outs` attribute.
""",
        ),
        "doxygen_extra_args": attr.string_list(default = [], doc = "Extra arguments to pass to the doxygen executable."),
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
        project_number = None,
        project_logo = None,
        use_mdfile_as_mainpage = None,
        extract_private = None,
        html_footer = None,
        html_header = None,
        filter_patterns = [],
        use_mathjax = None,
        html_extra_stylesheet = [],
        html_extra_files = [],
        aliases = [],
        have_dot = None,
        dot_image_format = None,
        dot_transparent = None,
        configurations = [],
        doxyfile_template = "@doxygen//:Doxyfile.template",
        doxygen_extra_args = [],
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
        project_number: The version number of the project.
        project_logo: The path to the project logo.
        use_mdfile_as_mainpage: The path to the markdown file to use as the main page.
        extract_private: Whether to extract private members.
        html_footer: The path to the HTML footer file.
        html_header: The path to the HTML header file.
        filter_patterns: A list of filter patterns. Enables alteration of the input files before they are parsed by doxygen.
        use_mathjax: Whether to use MathJax.
        html_extra_stylesheet: A list of extra stylesheets.
        html_extra_files: A list of extra files.
        aliases: A list of aliases.
        have_dot: Whether to use dot.
        dot_image_format: The image format to use for dot.
        dot_transparent: Whether to use transparent backgrounds for dot.
        configurations: A list of additional configuration parameters to pass to Doxygen.
        doxyfile_template: The template file to use to generate the Doxyfile.
            The following substitutions are available:<br>
            - `# {{INPUT}}`: Subpackage directory in the sandbox.<br>
            - `# {{ADDITIONAL PARAMETERS}}`: Additional parameters given in the `configurations` attribute.<br>
            - `# {{OUTPUT DIRECTORY}}`: The directory provided in the `outs` attribute.
        doxygen_extra_args: Extra arguments to pass to the doxygen executable.
        outs: The output folders bazel will keep. If only the html outputs is of interest, the default value will do.
             otherwise, a list of folders to keep is expected (e.g. ["html", "latex"]).
    """
    if not configurations:
        configurations = []
    if project_name != None:
        configurations.append("PROJECT_NAME = %s" % project_name)
    if project_brief != None:
        configurations.append("PROJECT_BRIEF = %s" % project_brief)
    if project_number != None:
        configurations.append("PROJECT_NUMBER = %s" % project_number)
    if project_logo != None:
        configurations.append("PROJECT_LOGO = %s" % project_logo)
    if use_mdfile_as_mainpage != None:
        configurations.append("USE_MDFILE_AS_MAINPAGE = %s" % use_mdfile_as_mainpage)
    if extract_private != None:
        if isinstance(extract_private, bool):
            extract_private = "YES" if extract_private else "NO"
        configurations.append("EXTRACT_PRIVATE = %s" % extract_private)
    if html_footer != None:
        configurations.append("HTML_FOOTER = %s" % html_footer)
    if html_header != None:
        configurations.append("HTML_HEADER = %s" % html_header)
    if filter_patterns:
        configurations.append("FILTER_PATTERNS = %s" % " ".join(filter_patterns))
    if use_mathjax != None:
        if isinstance(use_mathjax, bool):
            use_mathjax = "YES" if use_mathjax else "NO"
        configurations.append("USE_MATHJAX = %s" % use_mathjax)
    if html_extra_stylesheet:
        configurations.append("HTML_EXTRA_STYLESHEET = %s" % " ".join(html_extra_stylesheet))
    if html_extra_files:
        configurations.append("HTML_EXTRA_FILES = %s" % " ".join(html_extra_files))
    if aliases:
        configurations.append("ALIASES = %s" % " ".join(aliases))
    if have_dot != None:
        if isinstance(have_dot, bool):
            have_dot = "YES" if have_dot else "NO"
        configurations.append("HAVE_DOT = %s" % have_dot)
    if dot_image_format != None:
        configurations.append("DOT_IMAGE_FORMAT = %s" % dot_image_format)
    if dot_transparent != None:
        if isinstance(dot_transparent, bool):
            dot_transparent = "YES" if dot_transparent else "NO"
        configurations.append("DOT_TRANSPARENT = %s" % dot_transparent)

    _doxygen(
        name = name,
        srcs = srcs,
        outs = outs,
        configurations = configurations,
        doxyfile_template = doxyfile_template,
        doxygen_extra_args = doxygen_extra_args,
    )
