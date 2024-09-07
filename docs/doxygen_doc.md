<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Doxygen rule for Bazel.

<a id="doxygen"></a>

## doxygen

<pre>
doxygen(<a href="#doxygen-name">name</a>, <a href="#doxygen-srcs">srcs</a>, <a href="#doxygen-project_name">project_name</a>, <a href="#doxygen-project_brief">project_brief</a>, <a href="#doxygen-project_number">project_number</a>, <a href="#doxygen-project_logo">project_logo</a>, <a href="#doxygen-project_icon">project_icon</a>,
        <a href="#doxygen-use_mdfile_as_mainpage">use_mdfile_as_mainpage</a>, <a href="#doxygen-extract_private">extract_private</a>, <a href="#doxygen-html_footer">html_footer</a>, <a href="#doxygen-html_header">html_header</a>, <a href="#doxygen-filter_patterns">filter_patterns</a>,
        <a href="#doxygen-use_mathjax">use_mathjax</a>, <a href="#doxygen-html_extra_stylesheet">html_extra_stylesheet</a>, <a href="#doxygen-html_extra_files">html_extra_files</a>, <a href="#doxygen-html_colorstyle">html_colorstyle</a>, <a href="#doxygen-aliases">aliases</a>, <a href="#doxygen-have_dot">have_dot</a>,
        <a href="#doxygen-dot_image_format">dot_image_format</a>, <a href="#doxygen-dot_transparent">dot_transparent</a>, <a href="#doxygen-disable_index">disable_index</a>, <a href="#doxygen-full_sidebar">full_sidebar</a>, <a href="#doxygen-generate_treeview">generate_treeview</a>,
        <a href="#doxygen-javadoc_autobrief">javadoc_autobrief</a>, <a href="#doxygen-builtin_stl_support">builtin_stl_support</a>, <a href="#doxygen-hide_undoc_members">hide_undoc_members</a>, <a href="#doxygen-hide_in_body_docs">hide_in_body_docs</a>,
        <a href="#doxygen-exclude_symbols">exclude_symbols</a>, <a href="#doxygen-example_path">example_path</a>, <a href="#doxygen-dot_executable">dot_executable</a>, <a href="#doxygen-configurations">configurations</a>, <a href="#doxygen-doxyfile_template">doxyfile_template</a>,
        <a href="#doxygen-doxygen_extra_args">doxygen_extra_args</a>, <a href="#doxygen-outs">outs</a>, <a href="#doxygen-kwargs">kwargs</a>)
</pre>

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


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="doxygen-name"></a>name |  A name for the target.   |  none |
| <a id="doxygen-srcs"></a>srcs |  A list of source files to generate documentation for.   |  none |
| <a id="doxygen-project_name"></a>project_name |  The name of the project.   |  `None` |
| <a id="doxygen-project_brief"></a>project_brief |  A brief description of the project.   |  `None` |
| <a id="doxygen-project_number"></a>project_number |  The version number of the project.   |  `None` |
| <a id="doxygen-project_logo"></a>project_logo |  The path to the project logo.   |  `None` |
| <a id="doxygen-project_icon"></a>project_icon |  The path to the project icon.   |  `None` |
| <a id="doxygen-use_mdfile_as_mainpage"></a>use_mdfile_as_mainpage |  The path to the markdown file to use as the main page.   |  `None` |
| <a id="doxygen-extract_private"></a>extract_private |  Whether to extract private members.   |  `None` |
| <a id="doxygen-html_footer"></a>html_footer |  The path to the HTML footer file.   |  `None` |
| <a id="doxygen-html_header"></a>html_header |  The path to the HTML header file.   |  `None` |
| <a id="doxygen-filter_patterns"></a>filter_patterns |  A list of filter patterns. Enables alteration of the input files before they are parsed by doxygen.   |  `[]` |
| <a id="doxygen-use_mathjax"></a>use_mathjax |  Whether to use MathJax.   |  `None` |
| <a id="doxygen-html_extra_stylesheet"></a>html_extra_stylesheet |  A list of extra stylesheets.   |  `[]` |
| <a id="doxygen-html_extra_files"></a>html_extra_files |  A list of extra files.   |  `[]` |
| <a id="doxygen-html_colorstyle"></a>html_colorstyle |  The color style to use for HTML.   |  `None` |
| <a id="doxygen-aliases"></a>aliases |  A list of aliases.   |  `[]` |
| <a id="doxygen-have_dot"></a>have_dot |  Whether to use dot.   |  `None` |
| <a id="doxygen-dot_image_format"></a>dot_image_format |  The image format to use for dot.   |  `None` |
| <a id="doxygen-dot_transparent"></a>dot_transparent |  Whether to use transparent backgrounds for dot.   |  `None` |
| <a id="doxygen-disable_index"></a>disable_index |  Whether to disable the index.   |  `None` |
| <a id="doxygen-full_sidebar"></a>full_sidebar |  Whether to use a full sidebar.   |  `None` |
| <a id="doxygen-generate_treeview"></a>generate_treeview |  Whether to generate a tree view.   |  `None` |
| <a id="doxygen-javadoc_autobrief"></a>javadoc_autobrief |  Whether to use Javadoc-style auto brief.   |  `None` |
| <a id="doxygen-builtin_stl_support"></a>builtin_stl_support |  Whether to support the built-in standard library.   |  `None` |
| <a id="doxygen-hide_undoc_members"></a>hide_undoc_members |  Whether to hide undocumented members.   |  `None` |
| <a id="doxygen-hide_in_body_docs"></a>hide_in_body_docs |  Whether to hide in body docs.   |  `None` |
| <a id="doxygen-exclude_symbols"></a>exclude_symbols |  A list of symbols to exclude.   |  `[]` |
| <a id="doxygen-example_path"></a>example_path |  The path to the examples. They must be added to the source files.   |  `None` |
| <a id="doxygen-dot_executable"></a>dot_executable |  Label of the doxygen executable. Make sure it is also added to the `srcs` of the macro   |  `None` |
| <a id="doxygen-configurations"></a>configurations |  A list of additional configuration parameters to pass to Doxygen.   |  `[]` |
| <a id="doxygen-doxyfile_template"></a>doxyfile_template |  The template file to use to generate the Doxyfile. The following substitutions are available:<br> - `# {{INPUT}}`: Subpackage directory in the sandbox.<br> - `# {{ADDITIONAL PARAMETERS}}`: Additional parameters given in the `configurations` attribute.<br> - `# {{OUTPUT DIRECTORY}}`: The directory provided in the `outs` attribute.   |  `"@doxygen//:Doxyfile.template"` |
| <a id="doxygen-doxygen_extra_args"></a>doxygen_extra_args |  Extra arguments to pass to the doxygen executable.   |  `[]` |
| <a id="doxygen-outs"></a>outs |  The output folders bazel will keep. If only the html outputs is of interest, the default value will do. otherwise, a list of folders to keep is expected (e.g. ["html", "latex"]).   |  `["html"]` |
| <a id="doxygen-kwargs"></a>kwargs |  Additional arguments to pass to the rule (e.g. `visibility = ["//visibility:public"], tags = ["manual"]`)   |  none |


