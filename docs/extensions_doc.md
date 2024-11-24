<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Repository rule for downloading the correct version of doxygen using module extensions.

<a id="doxygen_repository"></a>

## doxygen_repository

<pre>
load("@rules_doxygen//:extensions.bzl", "doxygen_repository")

doxygen_repository(<a href="#doxygen_repository-name">name</a>, <a href="#doxygen_repository-build">build</a>, <a href="#doxygen_repository-doxyfile_template">doxyfile_template</a>, <a href="#doxygen_repository-doxygen_bzl">doxygen_bzl</a>, <a href="#doxygen_repository-executables">executables</a>, <a href="#doxygen_repository-platforms">platforms</a>,
                   <a href="#doxygen_repository-repo_mapping">repo_mapping</a>, <a href="#doxygen_repository-sha256s">sha256s</a>, <a href="#doxygen_repository-versions">versions</a>)
</pre>

Repository rule for doxygen.

It can be provided with a configuration for each of the three platforms (windows, mac, mac-arm, linux, linux-arm) to download the correct version of doxygen only when the configuration matches the current platform.
Depending on the version, the behavior will change:
- If the version is set to `0.0.0`, the repository will use the installed version of doxygen, getting the binary from the PATH.
- If a version is specified, the repository will download the correct version of doxygen and make it available to the requesting module.

> [!Warning]
> If version is set to `0.0.0`, the rules needs doxygen to be installed on your system and the binary (named doxygen) must available in the PATH.
> Keep in mind that this will break the hermeticity of your build, as it will now depend on the environment.

You can further customize the repository by specifying the `doxygen_bzl`, `build`, and `doxyfile_template` attributes, but the default values should be enough for most use cases.

### Example

```starlark
# Download the os specific version 1.12.0 of doxygen supporting all the indicated platforms
doxygen_repository(
    name = "doxygen",
    versions = ["1.12.0", "1.12.0", "1.12.0"],
    sha256s = [
        "07f1c92cbbb32816689c725539c0951f92c6371d3d7f66dfa3192cbe88dd3138",
        "6ace7dde967d41f4e293d034a67eb2c7edd61318491ee3131112173a77344001",
        "3c42c3f3fb206732b503862d9c9c11978920a8214f223a3950bbf2520be5f647",
    ]
    platforms = ["windows", "mac", "linux"],
    executables = ["", "", ""],
)

# Use the system installed version of doxygen on linux and download version 1.11.0 for windows. Use the provided executable on mac-arm
doxygen_repository(
    name = "doxygen",
    version = ["0.0.0", "1.11.0", ""],
    sha256s = ["", "478fc9897d00ca181835d248a4d3e5c83c26a32d1c7571f4321ddb0f2e97459f", ""],
    platforms = ["linux", "windows", "mac-arm"],
    executables = ["", "", "/path/to/doxygen"],
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="doxygen_repository-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="doxygen_repository-build"></a>build |  The BUILD file of the repository   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_doxygen//doxygen:BUILD.bazel"`  |
| <a id="doxygen_repository-doxyfile_template"></a>doxyfile_template |  The Doxyfile template to use   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_doxygen//doxygen:Doxyfile.template"`  |
| <a id="doxygen_repository-doxygen_bzl"></a>doxygen_bzl |  The starlark file containing the doxygen macro   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_doxygen//doxygen:doxygen.bzl"`  |
| <a id="doxygen_repository-executables"></a>executables |  List of doxygen executables to use. If set, no download will take place and the provided doxygen executable will be used. Mutually exclusive with `version`. Must be the same length as `version`, `sha256s` and `platforms`.   | List of strings | required |  |
| <a id="doxygen_repository-platforms"></a>platforms |  List of platforms to download the doxygen binary for. Available options are (windows, mac, mac-arm, linux, linux-arm). Must be the same length as `version`, `sha256s` and `executables`.   | List of strings | required |  |
| <a id="doxygen_repository-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |
| <a id="doxygen_repository-sha256s"></a>sha256s |  List of sha256 hashes of the doxygen archive. Must be the same length as `versions, `platforms` and `executables`.   | List of strings | required |  |
| <a id="doxygen_repository-versions"></a>versions |  List of versions of doxygen to use. If set to `0.0.0`, the doxygen executable will be assumed to be available from the PATH. Must be the same length as `sha256s`, `platforms` and `executables`.   | List of strings | required |  |


<a id="doxygen_extension"></a>

## doxygen_extension

<pre>
doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")
doxygen_extension.configuration(<a href="#doxygen_extension.configuration-executable">executable</a>, <a href="#doxygen_extension.configuration-platform">platform</a>, <a href="#doxygen_extension.configuration-sha256">sha256</a>, <a href="#doxygen_extension.configuration-version">version</a>)
</pre>

Module extension for declaring the doxygen configurations to use.

The resulting repository will have the following targets:
- `@doxygen//:doxygen.bzl`, containing the doxygen macro used to generate the documentation.
- `@doxygen//:Doxyfile.template`, default Doxyfile template used to generate the Doxyfile.

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

### Examples

```starlark
# MODULE.bazel file

bazel_dep(name = "rules_doxygen", version = "...", dev_dependency = True)

doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")

# Using the 1.10.0 version of Doxygen instead of the default 1.12.0.
# Note that che checksum is correct only if the platform is windows.
# If the platform is different, the build will fail.
doxygen_extension.configuration(
    version = "1.10.0",
    sha256 = "2135c1d5bdd6e067b3d0c40a4daac5d63d0fee1b3f4d6ef1e4f092db0d632d5b",
)

use_repo(doxygen_extension, "doxygen")
```

```starlark
# MODULE.bazel file

bazel_dep(name = "rules_doxygen", version = "...", dev_dependency = True)

doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")

doxygen_extension.configuration(
    version = "1.10.0",
    sha256 = "dcfc9aa4cc05aef1f0407817612ad9e9201d9bf2ce67cecf95a024bba7d39747",
    platform = "linux",
)
doxygen_extension.configuration(
    version = "1.10.0",
    sha256 = "dcfc9aa4cc05aef1f0407817612ad9e9201d9bf2ce67cecf95a024bba7d39747",
    platform = "linux-arm",
)
doxygen_extension.configuration(
    version = "1.12.0",
    sha256 = "6ace7dde967d41f4e293d034a67eb2c7edd61318491ee3131112173a77344001",
    platform = "mac",
)
doxygen_extension.configuration(
    version = "1.12.0",
    sha256 = "6ace7dde967d41f4e293d034a67eb2c7edd61318491ee3131112173a77344001",
    platform = "mac-arm",
)
doxygen_extension.configuration(
    version = "1.11.0",
    sha256 = "478fc9897d00ca181835d248a4d3e5c83c26a32d1c7571f4321ddb0f2e97459f",
    platform = "windows",
)

use_repo(doxygen_extension, "doxygen")
```

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


**TAG CLASSES**

<a id="doxygen_extension.configuration"></a>

### configuration

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="doxygen_extension.configuration-executable"></a>executable |  The doxygen executable to use. If set, no download will take place and the provided doxygen executable will be used. Mutually exclusive with `version`.   | String | optional |  `""`  |
| <a id="doxygen_extension.configuration-platform"></a>platform |  The target platform for the doxygen binary. Available options are (windows, mac, mac-arm, linux, linux-arm). If not specified, it will select the platform it is currently running on.   | String | optional |  `""`  |
| <a id="doxygen_extension.configuration-sha256"></a>sha256 |  The sha256 hash of the doxygen archive. If not specified, an all-zero hash will be used.   | String | optional |  `""`  |
| <a id="doxygen_extension.configuration-version"></a>version |  The version of doxygen to use. If set to `0.0.0`, the doxygen executable will be assumed to be available from the PATH. Mutually exclusive with `executable`.   | String | optional |  `""`  |


