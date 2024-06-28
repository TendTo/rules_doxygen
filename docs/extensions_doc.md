<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Repository rule for downloading the correct version of doxygen using module extensions.

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

By default, version `1.11.0` of Doxygen is used. To select a different version, indicate it in the `version` module:

If you don't know the SHA256 of the Doxygen binary, just leave it empty.
The build will fail with an error message containing the correct SHA256.

```bash
Download from https://github.com/doxygen/doxygen/releases/download/Release_1_10_0/doxygen-1.10.0.windows.x64.bin.zip failed: class com.google.devtools.build.lib.bazel.repository.downloader.UnrecoverableHttpException Checksum was 2135c1d5bdd6e067b3d0c40a4daac5d63d0fee1b3f4d6ef1e4f092db0d632d5b but wanted 0000000000000000000000000000000000000000000000000000000000000000
```

### Example

```starlark
bazel_dep(name = "rules_doxygen", version = "...", dev_dependency = True)

doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")

# Using the 1.10.0 version of Doxygen on Windows instead of the default 1.11.0
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
| <a id="doxygen_extension.version-version"></a>version |  The version of doxygen to use   | String | required |  |


