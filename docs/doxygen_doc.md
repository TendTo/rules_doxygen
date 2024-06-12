<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Doxygen rule for Bazel.

<a id="doxygen"></a>

## doxygen

<pre>
doxygen(<a href="#doxygen-name">name</a>, <a href="#doxygen-srcs">srcs</a>, <a href="#doxygen-project_name">project_name</a>, <a href="#doxygen-project_brief">project_brief</a>, <a href="#doxygen-configurations">configurations</a>, <a href="#doxygen-doxyfile_template">doxyfile_template</a>, <a href="#doxygen-outs">outs</a>)
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
| <a id="doxygen-configurations"></a>configurations |  A list of additional configuration parameters to pass to Doxygen.   |  `[]` |
| <a id="doxygen-doxyfile_template"></a>doxyfile_template |  The template file to use to generate the Doxyfile. The following substitutions are available:<br> - `# {{INPUT}}`: Subpackage directory in the sandbox.<br> - `# {{ADDITIONAL PARAMETERS}}`: Additional parameters given in the `configurations` attribute.<br> - `# {{OUTPUT DIRECTORY}}`: The directory provided in the `outs` attribute.   |  `"@doxygen//:Doxyfile.template"` |
| <a id="doxygen-outs"></a>outs |  The output folders bazel will keep. If only the html outputs is of interest, the default value will do. otherwise, a list of folders to keep is expected (e.g. ["html", "latex"]).   |  `["html"]` |


