<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Repository rule for downloading the correct version of doxygen using module extensions.

<a id="local_repository_doxygen"></a>

## local_repository_doxygen

<pre>
local_repository_doxygen(<a href="#local_repository_doxygen-name">name</a>, <a href="#local_repository_doxygen-build">build</a>, <a href="#local_repository_doxygen-doxyfile_template">doxyfile_template</a>, <a href="#local_repository_doxygen-doxygen_bzl">doxygen_bzl</a>, <a href="#local_repository_doxygen-executable">executable</a>, <a href="#local_repository_doxygen-repo_mapping">repo_mapping</a>)
</pre>

Repository rule for doxygen.

Used to create a local repository for doxygen, containing the installed doxygen binary and all the necessary files to run the doxygen macro.
In order to use this rule, you must have doxygen installed on your system and the binary (named doxygen) must available in the PATH.
Keep in mind that this will break the hermeticity of your build, as it will now depend on the environment.

### Example

```starlark
local_repository_doxygen(
    name = "doxygen",
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="local_repository_doxygen-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="local_repository_doxygen-build"></a>build |  The BUILD file of the repository   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_doxygen//:doxygen.BUILD.bazel"`  |
| <a id="local_repository_doxygen-doxyfile_template"></a>doxyfile_template |  The Doxyfile template to use   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_doxygen//:Doxyfile.template"`  |
| <a id="local_repository_doxygen-doxygen_bzl"></a>doxygen_bzl |  The starlark file containing the doxygen macro   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_doxygen//:doxygen.bzl"`  |
| <a id="local_repository_doxygen-executable"></a>executable |  The doxygen executable to use. Must refer to an executable file. Defaults to the doxygen executable in the PATH.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="local_repository_doxygen-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |


<a id="doxygen_extension"></a>

## doxygen_extension

<pre>
doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")
doxygen_extension.version(<a href="#doxygen_extension.version-sha256">sha256</a>, <a href="#doxygen_extension.version-version">version</a>)
</pre>

Module extension for declaring the doxygen version to use.

The resulting repository will have the following targets:
- `@doxygen//:doxygen.bzl`, containing the doxygen macro used to generate the documentation.
- `@doxygen//:Doxyfile.template`, default Doxyfile template used to generate the Doxyfile.

By default, version `1.12.0` of Doxygen is used. To select a different version, indicate it in the `version` module:

If you don't know the SHA256 of the Doxygen binary, just leave it empty.
The build will fail with an error message containing the correct SHA256.

```bash
Download from https://github.com/doxygen/doxygen/releases/download/Release_1_10_0/doxygen-1.10.0.windows.x64.bin.zip failed: class com.google.devtools.build.lib.bazel.repository.downloader.UnrecoverableHttpException Checksum was 2135c1d5bdd6e067b3d0c40a4daac5d63d0fee1b3f4d6ef1e4f092db0d632d5b but wanted 0000000000000000000000000000000000000000000000000000000000000000
```

If you set the version to `0.0.0`, the doxygen executable will be assumed to be available from the PATH.
No download will be performed and bazel will use the installed version of doxygen.
Keep in mind that this will break the hermeticity of your build, as it will now depend on the environment.

### Example

```starlark
bazel_dep(name = "rules_doxygen", version = "...", dev_dependency = True)

doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")

# Using the 1.10.0 version of Doxygen on Windows instead of the default 1.12.0
doxygen_extension.version(version = "1.10.0", sha256 = "2135c1d5bdd6e067b3d0c40a4daac5d63d0fee1b3f4d6ef1e4f092db0d632d5b")

use_repo(doxygen_extension, "doxygen")
```


**TAG CLASSES**

<a id="doxygen_extension.version"></a>

### version

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="doxygen_extension.version-sha256"></a>sha256 |  The sha256 hash of the doxygen archive. If not specified, an all-zero hash will be used.   | String | optional |  `""`  |
| <a id="doxygen_extension.version-version"></a>version |  The version of doxygen to use. If set to `0.0.0`, the doxygen executable will be assumed to be available from the PATH   | String | required |  |


