# Doxygen rules for Bazel

[![Bazel Central Repository](https://img.shields.io/badge/BCR-2.2.2-%230C713A?logo=bazel)](https://registry.bazel.build/modules/rules_doxygen)
[![CI](https://github.com/TendTo/rules_doxygen/actions/workflows/ci.yml/badge.svg)](https://github.com/TendTo/rules_doxygen/actions/workflows/ci.yml)

This repository contains a [Starlark](https://github.com/bazelbuild/starlark) implementation of [Doxygen](https://www.doxygen.nl/) rules in [Bazel](https://bazel.build/).

## Setup as a module dependency (Bzlmod)

Add the following to your _MODULE.bazel_:

```bzl
# MODULE.bazel file

bazel_dep(name = "rules_doxygen", version = "2.2.2", dev_dependency = True)
```

If you don't want to depend on the [Bazel package registry](https://bazel.build/external/bazelbuild/rules_pkg) or need a not-yet-published version of this module, you can use a `git_override` by adding the following lines below `bazel_dep` in your _MODULE.bazel_ file:

```bzl
# MODULE.bazel file

bazel_dep(name = "rules_doxygen", version = "2.2.2", dev_dependency = True)
git_override(
    module_name = "rules_doxygen",
    commit = "aacc1c856c350a89a0fa9c43b9318a248d5f1781", # Commit hash you want to use
    remote = "https://github.com/TendTo/rules_doxygen.git",
)
```

> [!Note]  
> Only [Bazel 7](https://blog.bazel.build/2023/12/11/bazel-7-release.html) and above are supported.

### Doxygen version selection

To add the `@doxygen` repository to your module, use `doxygen_extension` under `bazel_dep` in your MODULE.bazel file.

```bzl
# MODULE.bazel file

bazel_dep(name = "rules_doxygen", version = "...", dev_dependency = True)

doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")
use_repo(doxygen_extension, "doxygen")
```

The extension will create a default configuration for all platforms with the version `1.13.2` of Doxygen.
You can override this value with a custom one for each supported platform, i.e. _windows_, _mac_, _mac-arm_, _linux_ and _linux-arm_.

```bzl
# MODULE.bazel file

bazel_dep(name = "rules_doxygen", version = "...", dev_dependency = True)

doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")

# Download doxygen version 1.10.0 on linux, default version on all other platforms
doxygen_extension.configuration(
    version = "1.10.0",
    sha256 = "dcfc9aa4cc05aef1f0407817612ad9e9201d9bf2ce67cecf95a024bba7d39747",
    platform = "linux",
)

use_repo(doxygen_extension, "doxygen")
```

When you do so, you must also provide the SHA256 of the given doxygen archive.
If you don't know the SHA256 value, just leave it empty.
The build will fail with an error message containing the correct SHA256.

```bash
Download from https://github.com/doxygen/doxygen/releases/download/Release_1_10_0/doxygen-1.10.0.windows.x64.bin.zip failed: class com.google.devtools.build.lib.bazel.repository.downloader.UnrecoverableHttpException Checksum was 2135c1d5bdd6e067b3d0c40a4daac5d63d0fee1b3f4d6ef1e4f092db0d632d5b but wanted 0000000000000000000000000000000000000000000000000000000000000000
```

> [!Tip]  
> Not indicating the platform will make the configuration apply to the platform it is running on.
> The build will fail when the download does not match the SHA256 checksum, i.e. when the platform changes.
> Unless you are using a system-wide doxygen installation, you should always specify the platform.

#### System-wide doxygen installation

If you set the version to `0.0.0`, the doxygen executable will be assumed to be available from the PATH.
No download will be performed and Bazel will use the installed version of doxygen.

> [!Warning]  
> Setting the version to `0.0.0` this will break the hermeticity of your build, as it will now depend on the environment.

#### Using a local doxygen executable

You can also provide a label pointing to the `doxygen` executable you want to use by using the `executable` parameter in the extension configuration.
No download will be performed, and the file indicated by the label will be used as the doxygen executable.

> [!Note]  
> `version` and `executable` are mutually exclusive.
> You must provide exactly one of them.

#### Example

Different strategies can be combined in the same file, one for each platform, as shown below:

```bzl
# MODULE.bazel file

bazel_dep(name = "rules_doxygen", version = "...", dev_dependency = True)

doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")

# Download doxygen version 1.10.0 on linux
doxygen_extension.configuration(
    version = "1.10.0",
    sha256 = "dcfc9aa4cc05aef1f0407817612ad9e9201d9bf2ce67cecf95a024bba7d39747",
    platform = "linux",
)
# Use the local doxygen installation on mac
doxygen_extension.configuration(
    version = "0.0.0",
    platform = "mac",
)
# Use the doxygen provided executable on mac-arm
doxygen_extension.configuration(
    executable = "@my_module//path/to/doxygen:doxygen",
    platform = "mac-arm",
)
# Since no configuration has been provided for them,
# all other platforms will fallback to the default version

use_repo(doxygen_extension, "doxygen")
```

> [!Note]
> See [the documentation](docs/extensions_doc.md) for more information.

## Use

The main macro exposed by this module is `doxygen`.
It generates a Doxygen documentation target from a list of sources.
Only the sources are required, the rest of the parameters are optional.

```bzl
# My BUILD.bazel file

load("@doxygen//:doxygen.bzl", "doxygen")

NAME = "base"
DESCRIPTION = "Example project for doxygen"

doxygen(
    name = "doxygen",   # Name of the rule, can be anything
    srcs = glob([       # List of sources to document.
        "*.h",          # Usually includes the source files and the markdown files.
        "*.cpp",
    ]) + ["README.md"],
    # Additionally, you can use the `deps` attribute to select a target
    # and automatically include all of the files in its `srcs`, `hdrs`, and `data` attributes,
    # along with all of its transitive dependencies.
    # deps = [":my_cc_target"],
    project_brief = DESCRIPTION,            # Brief description of the project
    project_name = NAME,                    # Name of the project
    generate_html = True,                   # Whether to generate HTML output
    generate_latex = False,                 # Whether to generate LaTeX output
    use_mdfile_as_mainpage = "README.md",   # The main page of the documentation
    # Equivalently, you can manually set the configurations
    # that will be appended to the Doxyfile in the form of a list of strings
    # configurations = [
    #    "GENERATE_HTML = YES",
    #    "GENERATE_LATEX = NO",
    #    "USE_MDFILE_AS_MAINPAGE = README.md",
    # ],
    tags = ["manual"]  # Tags to add to the target.
                       # This way the target won't run unless explicitly called
)
```

Use the [Doxygen documentation](https://www.doxygen.nl/manual/config.html) or generate a brand new _Doxyfile_ with `doxygen -g` to see all the available options to put in the `configurations` list.
They will simply be appended at the end of the file, overriding the default values.

> [!Note]
> See the [documentation](docs/doxygen_doc.md) for more information or the [examples](examples) directory for examples of how to use the rules.

### Differences between `srcs` and `deps`

The `srcs` and `deps` attributes work differently, and are not interchangeable.

`srcs` is a list of files that will be passed to Doxygen for documentation generation.
You can use `glob` to include a collection of multiple files.  
On the other hand, if you indicate a target (e.g., `:my_genrule`), it will include all the files produced by that target.
More precisely, the files in the DefaultInfo provider the target returns.
Hence, when the documentation is generated, all rules in the `srcs` attribute **will** be built, and the files they output will be passed to Doxygen.

On the other hand, `deps` is a list of targets whose sources will be included in the documentation generation.
It will automatically include all the files in the `srcs`, `hdrs`, and `data` attributes of the target, and the same applies to all of its transitive dependencies, recursively.
Since we are only interested in the source files, the `deps` targets **will not** be built when the documentation is generated.

```bzl
# My BUILD.bazel file
load("@doxygen//:doxygen.bzl", "doxygen")
load("@rules_cc//cc:defs.bzl", "cc_library")

cc_library(
    name = "lib",
    hdrs = ["add.h", "sub.h"],
    srcs = ["add.cpp", "sub.cpp"],
)

cc_library(
    name = "main",
    srcs = ["main.cpp"],
    deps = [":lib"],
)


genrule(
    name = "section",
    outs = ["Section.md"],
    cmd = """
        echo "# Section " > $@
        echo "This is some amazing documentation with section!!  " >> $@
        echo "Incredible." >> $@
    """,
)

doxygen(
    name = "doxygen",
    project_name = "dependencies",

    # The output of the genrule will be included in the documentation.
    # The genrule will be executed when the documentation is generated.
    srcs = [
        "README.md",  # file
        ":section",  # genrule

        # WARNING: By adding this, the main target will be built
        # and only the output file `main.o` will be passed to Doxygen,
        # which is likely not what you want.
        # ":main"
    ],

    # The sources of the main target and its dependencies will be included.
    # No compilation will be performed, so compile error won't be reported.
    deps = [":main"],  # cc_library

    # Always starts at the root folder
    use_mdfile_as_mainpage = "dependencies/README.md",
)
```

## Build

To build the documentation, run the following command:

```bash
bazel build //path/to:doxygen_target
```

For example, if the _BUILD.bazel_ file is in the root of the repository, and the target is named `doxygen`

```bzl
# BUILD.bazel file in the root of the repository

load("@doxygen//:doxygen.bzl", "doxygen")

doxygen(
    name = "doxygen",
    srcs = glob([
        "*.h",
        "*.cpp",
    ]),
    project_name = "base",
)
```

the build command would be:

```bash
bazel build //:doxygen
```

The generated documentation will be in the `bazel-bin/<subpackage>` directory.
If the _BUILD.bazel_ file was in the root of the repository, the `<subpackage>` would be an empty string.

The documentation can be viewed by opening the `index.html` file in a browser using any web server:

```bash
# Using Python 3
cd bazel-bin/<subpackage>/html
python3 -m http.server 8000
```

Lastly, you may want to compress the documentation to share it with others:

```bash
tar -czvf doxygen.tar.gz bazel-bin/<subpackage>/html
```
