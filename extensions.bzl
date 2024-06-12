"""Repository rule for downloading the correct version of doxygen using module extensions."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _doxygen_extension_impl(ctx):
    """_doxygen_module_impl

    Downloads the correct version of doxygen and make the repository available to the requesting module.

    Args:
        ctx: a context object that contains the module's attributes
    """
    for mod in ctx.modules:
        if len(mod.tags.version) > 1:
            fail("Only one version of doxygen can be specified")
        doxygen_version = "1.11.0"
        strip_prefix = ""
        if ctx.os.name.startswith("windows"):
            doxygen_sha256 = "478fc9897d00ca181835d248a4d3e5c83c26a32d1c7571f4321ddb0f2e97459f"
        elif ctx.os.name == "macos":  # TODO: Update this to the correct version
            doxygen_sha256 = "0" * 64
        elif ctx.os.name == "linux":
            doxygen_sha256 = "db68ca22b43c3d7efd15351329db5af9146ab1ac7eaccd61a894fe36612da8fb"
        else:
            fail("Unsuppported OS: %s" % ctx.os.name)

        for attr in mod.tags.version:
            doxygen_version = attr.version if attr.version != "" else fail("Version must be specified")
            doxygen_sha256 = attr.sha256 if attr.sha256 != "" else "0" * 64

        doxygen_version_dash = doxygen_version.replace(".", "_")

        url = "https://github.com/doxygen/doxygen/releases/download/Release_%s/doxygen-%s.%s"
        if ctx.os.name.startswith("windows"):
            url = url % (doxygen_version_dash, doxygen_version, "windows.x64.bin.zip")
            # elif ctx.os.name == "macos": # TODO: support macos
            # url = url % (doxygen_version_dash, doxygen_version, "dmg")

        elif ctx.os.name == "linux":
            url = url % (doxygen_version_dash, doxygen_version, "linux.bin.tar.gz")
            strip_prefix = "doxygen-%s" % doxygen_version
        else:
            fail("Unsuppported OS: %s" % ctx.os.name)

        doxygen_bzl = Label("@rules_doxygen//:doxygen.bzl")
        doxygen_bzl_content = ctx.read(doxygen_bzl)
        http_archive(
            name = "doxygen",
            build_file = "@rules_doxygen//:doxygen.BUILD.bazel",
            url = url,
            sha256 = doxygen_sha256,
            patch_cmds = ["cat > 'doxygen.bzl' <<- EOF\n%s\nEOF" % doxygen_bzl_content],
            patch_cmds_win = ["Set-Content -Path 'doxygen.bzl' -Value '%s'" % doxygen_bzl_content],
            strip_prefix = strip_prefix,
        )

_version = tag_class(attrs = {
    "version": attr.string(doc = "The version of doxygen to use", mandatory = True),
    "sha256": attr.string(doc = "The sha256 hash of the doxygen archive. If not specified, an all-zero hash will be used."),
})

doxygen_extension = module_extension(
    implementation = _doxygen_extension_impl,
    tag_classes = {"version": _version},
    doc = """
Module extension for declaring the doxygen version to use.

The resulting repository will have the following targets:
- `@doxygen//:doxygen.bzl`, containing the doxygen macro used to generate the documentation.
- `@doxygen//:Doxyfile.template`, default Doxyfile template used to generate the Doxyfile.

### Example

```starlark
bazel_dep(name = "rules_doxygen", version = "...", dev_dependency = True)

doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")

# Using the 1.10.0 version of Doxygen on Windows instead of the default 1.11.0
doxygen_extension.version(version = "1.10.0", sha256 = "2135c1d5bdd6e067b3d0c40a4daac5d63d0fee1b3f4d6ef1e4f092db0d632d5b")

use_repo(doxygen_extension, "doxygen")
```
""",
)
