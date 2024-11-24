# Doxygen rules for Bazel

[![Bazel Central Repository](https://img.shields.io/badge/BCR-2.0.0-%230C713A?logo=bazel)](https://registry.bazel.build/modules/rules_doxygen)
[![CI](https://github.com/TendTo/rules_doxygen/actions/workflows/ci.yml/badge.svg)](https://github.com/TendTo/rules_doxygen/actions/workflows/ci.yml)

This repository contains a [Starlark](https://github.com/bazelbuild/starlark) implementation of [Doxygen](https://www.doxygen.nl/) rules in [Bazel](https://bazel.build/).

## Setup as a module dependency (bzlmod)

Add the following to your _MODULE.bazel_:

```bzl
# MODULE.bazel file

bazel_dep(name = "rules_doxygen", version = "2.0.0", dev_dependency = True)
```

If you don't want to depend on the [Bazel package registry](https://bazel.build/external/bazelbuild/rules_pkg) or you want to use a not-yet-published version of this module, you can use an archive override by adding the following lines below the `bazel_dep` rule in your _MODULE.bazel_ file:

```bzl
# MODULE.bazel file

bazel_dep(name = "rules_doxygen", version = "2.0.0", dev_dependency = True)
archive_override(
    module_name = "rules_doxygen",
    urls = "https://github.com/TendTo/rules_doxygen/archive/refs/heads/main.tar.gz",
    strip_prefix = "rules_doxygen-main",
    # The SHA256 checksum of the archive file, based on the rules' version
    # integrity = "sha256-0SCaZuAerluoDs6HXMb0Bj9FttZVieM4+Dpd9gnMM+o=", # Example
)
```

### Doxygen version selection

To select a doxygen version to use, use the `doxygen_extension` module extension below the `bazel_dep` rule in your MODULE.bazel file.

```bzl
# MODULE.bazel file

bazel_dep(name = "rules_doxygen", version = "...", dev_dependency = True)

doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")
use_repo(doxygen_extension, "doxygen")
```

By default, version `1.12.0` of Doxygen is used.
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

When you do so, you must also provide the SHA256 of the given doxygen installation.
If you don't know the SHA256 value, just leave it empty.
The build will fail with an error message containing the correct SHA256.

```bash
Download from https://github.com/doxygen/doxygen/releases/download/Release_1_10_0/doxygen-1.10.0.windows.x64.bin.zip failed: class com.google.devtools.build.lib.bazel.repository.downloader.UnrecoverableHttpException Checksum was 2135c1d5bdd6e067b3d0c40a4daac5d63d0fee1b3f4d6ef1e4f092db0d632d5b but wanted 0000000000000000000000000000000000000000000000000000000000000000
```

#### System-wide doxygen installation

If you set the version to `0.0.0`, the doxygen executable will be assumed to be available from the PATH.
No download will be performed and bazel will use the installed version of doxygen.

> [!Warning]  
> Setting the version to `0.0.0` this will break the hermeticity of your build, as it will now depend on the environment.

> [!Tip]  
> Not indicating the platform will make the configuration apply to the platform it is running on.
> The build will fail when the downloaded file does not match the SHA256 checksum, i.e. when the platform changes.
> Unless you are using a system-wide doxygen installation, you should always specify the platform.

#### Using a local doxygen executable

You can also provide a label to the `doxygen` executable you want to use by using the `executable` parameter in the extension configuration.
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
    executable = "@@//path/to/doxygen:doxygen",
    platform = "mac-arm",
)
# Since no configuration has been provided, all other platforms will fallback to the default version

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

doxygen(
    name = "doxygen",   # Name of the rule, can be anything
    srcs = glob([       # List of sources to document.
        "*.h",          # Usually includes the source files and the markdown files.
        "*.cpp",
    ]) + ["README.md"],
    project_brief = "Example project for doxygen",  # Brief description of the project
    project_name = "base",                          # Name of the project
    configurations = [                              # Customizable configurations
        "GENERATE_HTML = YES",                      # that override the default ones
        "GENERATE_LATEX = NO",                      # from the Doxyfile
        "USE_MDFILE_AS_MAINPAGE = README.md",
    ]
    tags = ["manual"]  # Tags to add to the target.
                       # This way the target won't run unless explicitly called
)
```

Use the [Doxygen documentation](https://www.doxygen.nl/manual/config.html) or generate a brand new _Doxyfile_ with `doxygen -g` to see all the available options to put in the `configurations` list.
They will simply be appended at the end of the file, overriding the default values.

> [!Note]
> See the [documentation](docs/doxygen_doc.md) for more information or the [examples](examples) directory for examples of how to use the rules.

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

## TODO

- [ ] Add more easy-to-use common configuration for the Doxyfile
