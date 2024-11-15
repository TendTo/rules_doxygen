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
            "# {{DOT_PATH}}": ("DOT_PATH = %s" % ctx.executable.dot_executable.dirname) if ctx.executable.dot_executable else "",
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
- `# {{DOT_PATH}}`: Indicate to doxygen the location of the `dot_executable`
- `# {{ADDITIONAL PARAMETERS}}`: Additional parameters given in the `configurations` attribute.
- `# {{OUTPUT DIRECTORY}}`: The directory provided in the `outs` attribute.
""",
        ),
        "dot_executable": attr.label(
            executable = True,
            cfg = "exec",
            allow_single_file = True,
            doc = "The dot executable to use. Must refer to an executable file.",
        ),
        "doxygen_extra_args": attr.string_list(default = [], doc = "Extra arguments to pass to the doxygen executable."),
        "_executable": attr.label(
            executable = True,
            cfg = "exec",
            allow_single_file = True,
            default = Label("@doxygen//:executable"),
            doc = "The doxygen executable to use. Must refer to an executable file.",
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
        project_icon = None,
        use_mdfile_as_mainpage = None,
        extract_private = None,
        html_footer = None,
        html_header = None,
        filter_patterns = [],
        use_mathjax = None,
        html_extra_stylesheet = [],
        html_extra_files = [],
        html_colorstyle = None,
        aliases = [],
        have_dot = None,
        dot_image_format = None,
        dot_transparent = None,
        disable_index = None,
        full_sidebar = None,
        generate_treeview = None,
        javadoc_autobrief = None,
        builtin_stl_support = None,
        hide_undoc_members = None,
        hide_in_body_docs = None,
        exclude_symbols = [],
        example_path = None,
        dot_executable = None,
        configurations = [],
        doxyfile_template = "@doxygen//:Doxyfile.template",
        doxygen_extra_args = [],
        outs = ["html"],
        **kwargs):
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
        project_icon: The path to the project icon.
        use_mdfile_as_mainpage: The path to the markdown file to use as the main page.
        extract_private: Whether to extract private members.
        html_footer: The path to the HTML footer file.
        html_header: The path to the HTML header file.
        filter_patterns: A list of filter patterns. Enables alteration of the input files before they are parsed by doxygen.
        use_mathjax: Whether to use MathJax.
        html_extra_stylesheet: A list of extra stylesheets.
        html_extra_files: A list of extra files.
        html_colorstyle: The color style to use for HTML.
        aliases: A list of aliases.
        have_dot: Whether to use dot.
        dot_image_format: The image format to use for dot.
        dot_transparent: Whether to use transparent backgrounds for dot.
        disable_index: Whether to disable the index.
        full_sidebar: Whether to use a full sidebar.
        generate_treeview: Whether to generate a tree view.
        javadoc_autobrief: Whether to use Javadoc-style auto brief.
        builtin_stl_support: Whether to support the built-in standard library.
        hide_undoc_members: Whether to hide undocumented members.
        hide_in_body_docs: Whether to hide in body docs.
        exclude_symbols: A list of symbols to exclude.
        example_path: The path to the examples. They must be added to the source files.
        dot_executable: Label of the doxygen executable. Make sure it is also added to the `srcs` of the macro
        configurations: A list of additional configuration parameters to pass to Doxygen.
        doxyfile_template: The template file to use to generate the Doxyfile.
            The following substitutions are available:<br>
            - `# {{INPUT}}`: Subpackage directory in the sandbox.<br>
            - `# {{ADDITIONAL PARAMETERS}}`: Additional parameters given in the `configurations` attribute.<br>
            - `# {{OUTPUT DIRECTORY}}`: The directory provided in the `outs` attribute.
        doxygen_extra_args: Extra arguments to pass to the doxygen executable.
        outs: The output folders bazel will keep. If only the html outputs is of interest, the default value will do.
             otherwise, a list of folders to keep is expected (e.g. ["html", "latex"]).
        **kwargs: Additional arguments to pass to the rule (e.g. `visibility = ["//visibility:public"], tags = ["manual"]`)
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
    if project_icon != None:
        configurations.append("PROJECT_ICON = %s" % project_icon)
    if use_mdfile_as_mainpage != None:
        configurations.append("USE_MDFILE_AS_MAINPAGE = %s" % use_mdfile_as_mainpage)
    if extract_private != None:
        if type(extract_private) == type(True):
            extract_private = "YES" if extract_private else "NO"
        configurations.append("EXTRACT_PRIVATE = %s" % extract_private)
    if html_colorstyle != None:
        configurations.append("HTML_COLORSTYLE = %s" % html_colorstyle)
    if html_footer != None:
        configurations.append("HTML_FOOTER = %s" % html_footer)
    if html_header != None:
        configurations.append("HTML_HEADER = %s" % html_header)
    if filter_patterns:
        configurations.append("FILTER_PATTERNS = %s" % " ".join(filter_patterns))
    if use_mathjax != None:
        if type(use_mathjax) == type(True):
            use_mathjax = "YES" if use_mathjax else "NO"
        configurations.append("USE_MATHJAX = %s" % use_mathjax)
    if html_extra_stylesheet:
        configurations.append("HTML_EXTRA_STYLESHEET = %s" % " ".join(html_extra_stylesheet))
    if html_extra_files:
        configurations.append("HTML_EXTRA_FILES = %s" % " ".join(html_extra_files))
    if aliases:
        configurations.append("ALIASES = %s" % " ".join(aliases))
    if have_dot != None:
        if type(have_dot) == type(True):
            have_dot = "YES" if have_dot else "NO"
        configurations.append("HAVE_DOT = %s" % have_dot)
    if dot_image_format != None:
        configurations.append("DOT_IMAGE_FORMAT = %s" % dot_image_format)
    if dot_transparent != None:
        if type(dot_transparent) == type(True):
            dot_transparent = "YES" if dot_transparent else "NO"
        configurations.append("DOT_TRANSPARENT = %s" % dot_transparent)
    if disable_index != None:
        if type(disable_index) == type(True):
            disable_index = "YES" if disable_index else "NO"
        configurations.append("DISABLE_INDEX = %s" % disable_index)
    if full_sidebar != None:
        if type(full_sidebar) == type(True):
            full_sidebar = "YES" if full_sidebar else "NO"
        configurations.append("FULL_SIDEBAR = %s" % full_sidebar)
    if generate_treeview != None:
        if type(generate_treeview) == type(True):
            generate_treeview = "YES" if generate_treeview else "NO"
        configurations.append("GENERATE_TREEVIEW = %s" % generate_treeview)
    if javadoc_autobrief != None:
        if type(javadoc_autobrief) == type(True):
            javadoc_autobrief = "YES" if javadoc_autobrief else "NO"
        configurations.append("JAVADOC_AUTOBRIEF = %s" % javadoc_autobrief)
    if builtin_stl_support != None:
        if type(builtin_stl_support) == type(True):
            builtin_stl_support = "YES" if builtin_stl_support else "NO"
        configurations.append("BUILTIN_STL_SUPPORT = %s" % builtin_stl_support)
    if hide_undoc_members != None:
        if type(hide_undoc_members) == type(True):
            hide_undoc_members = "YES" if hide_undoc_members else "NO"
        configurations.append("HIDE_UNDOC_MEMBERS = %s" % hide_undoc_members)
    if hide_in_body_docs != None:
        if type(hide_in_body_docs) == type(True):
            hide_in_body_docs = "YES" if hide_in_body_docs else "NO"
        configurations.append("HIDE_IN_BODY_DOCS = %s" % hide_in_body_docs)
    if exclude_symbols:
        configurations.append("EXCLUDE_SYMBOLS = %s" % " ".join(exclude_symbols))
    if example_path != None:
        configurations.append("EXAMPLE_PATH = %s" % example_path)

    _doxygen(
        name = name,
        srcs = srcs,
        outs = outs,
        configurations = configurations,
        doxyfile_template = doxyfile_template,
        doxygen_extra_args = doxygen_extra_args,
        dot_executable = dot_executable,
        **kwargs
    )
