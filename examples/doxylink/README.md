# Doxyfile example

A complex example combining `doxygen` and `sphinx` with the `doxylink` extension.
This minimal example is based on the [doxylink example](https://github.com/sphinx-contrib/doxylink/tree/master/examples).

```bash
bazel build //doxyfile:doxygen
```

## Producing extra outputs

`rules_doxygen` expects the `doxygen` binary to produce the `html` folder and all its contents.
If you want to produce additional outputs, such as the `tag` files needed for the `doxylink` extension, you need to make sure they are generated in the correct location.
You can do this by using the `OUTDIR` make variable in the `doxygen` rule:

```bzl
doxygen(
    name = "doxygen",
    srcs = glob([
        "*.h",
        "*.cpp",
    ]),
    outs = [
        "html",
        # Mark `tags` as an output folder/group, and ensure its creation
        "tags",
    ],
    extract_all = True,
    # Add the `OUTDIR` make variable to specify the root output directory
    # where to generate the file
    generate_tagfile = "$(OUTDIR)/tags/lib.tag",
)
```

## Using the `doxylink` extension

The `doxylink` example is slightly more involved.
After producing the `tags` file, we want to use it with the `doxylink` extension in Sphinx.
First of all, create a [`requirements.txt`](./requirements.txt) file listing all the necessary dependencies.

Then, since we are using [rules_python](https://github.com/bazel-contrib/rules_python)'s sphinx implementation, we can just do the following:

```bzl
load("@rules_python//sphinxdocs:sphinx.bzl", "sphinx_build_binary", "sphinx_docs")
load("@rules_python//sphinxdocs:sphinx_docs_library.bzl", "sphinx_docs_library")
load("@pypi//:requirements.bzl", "requirement")

# Define the `sphinx` build binary that will be used to build the documentation
sphinx_build_binary(
    name = "sphinx_bin",
    deps = [
        requirement("sphinx"),
        requirement("sphinxcontrib-doxylink"),
    ],
)

# Capture the Doxygen output files and put them in the `doxygen` subdirectory
sphinx_docs_library(
    name = "sphinx_doxygen_tags",
    srcs = [":doxygen"],
    prefix = "doxygen/",
)

# Use sphinx to generate HTML documentation
sphinx_docs(
    name = "sphinx",
    srcs = ["index.rst"],
    config = "conf.py",
    formats = ["html"],
    sphinx = ":sphinx_bin",
    # This ensures that we are in the `sphinx/_source` directory,
    # without more nesting
    strip_prefix = package_name() + "/",
    deps = [":sphinx_doxygen_tags"],
)
```

Lastly, we need to ensure that the `doxylink` extension is properly configured in the Sphinx `conf.py` file.
Here is how you can set it up:

```python
# conf.py

import os

# ...
extensions = [
                "sphinxcontrib.doxylink",
                # other extensions ...
            ]

doxylink = {
    "lib": (
        os.path.abspath("doxygen/tags/lib.tag"),  # Path to the Doxygen tag file
        "../../../html",  # Path to the Doxygen html output files. 
        # Should be correct with respect to the hosted Sphinx documentation 
    ),
}

# ...
```
