"""Repository rule for downloading the correct version of doxygen using module extensions."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _local_repository_doxygen(ctx):
    """
    Repository rule for doxygen.

    Used to create a local repository for doxygen, containing the installed doxygen binary and all the necessary files to run the doxygen macro.

    Args:
        ctx: a [repository context](https://bazel.build/rules/lib/builtins/repository_ctx) object containing the repository's attributes
    """

    # Copy the necessary files to the repository by reading them from the current repository
    ctx.file("WORKSPACE", "workspace(name = %s)\n" % repr(ctx.name))
    ctx.file("doxygen.bzl", ctx.read(ctx.attr.doxygen_bzl))
    ctx.file("BUILD.bazel", ctx.read(ctx.attr.build))
    ctx.file("Doxyfile.template", ctx.read(ctx.attr.doxyfile_template))

    # Copy the doxygen executable to the repository
    doxygen_content = ctx.read(ctx.attr.executable or ctx.which("doxygen"))
    if ctx.os.name.startswith("windows"):
        ctx.file("doxygen.exe", doxygen_content, legacy_utf8 = False)
    elif ctx.os.name.startswith("mac"):
        ctx.file("doxygen", doxygen_content, legacy_utf8 = False)
    elif ctx.os.name == "linux":
        ctx.file("bin/doxygen", doxygen_content, legacy_utf8 = False)
    else:
        fail("Unsuppported OS: %s" % ctx.os.name)

local_repository_doxygen = repository_rule(
    implementation = _local_repository_doxygen,
    doc = """
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
""",
    attrs = {
        "doxygen_bzl": attr.label(
            doc = "The starlark file containing the doxygen macro",
            allow_single_file = True,
            default = Label("@rules_doxygen//:doxygen.bzl"),
        ),
        "build": attr.label(
            doc = "The BUILD file of the repository",
            allow_single_file = True,
            default = Label("@rules_doxygen//:doxygen.BUILD.bazel"),
        ),
        "doxyfile_template": attr.label(
            doc = "The Doxyfile template to use",
            allow_single_file = True,
            default = Label("@rules_doxygen//:Doxyfile.template"),
        ),
        "executable": attr.label(
            executable = True,
            cfg = "exec",
            allow_single_file = True,
            doc = "The doxygen executable to use. Must refer to an executable file. Defaults to the doxygen executable in the PATH.",
        ),
    },
)

def _doxygen_extension_impl(ctx):
    """_doxygen_module_impl

    Downloads the correct version of doxygen and make the repository available to the requesting module.

    Args:
        ctx: a [module context](https://bazel.build/rules/lib/builtins/module_ctx) object containing the module's attributes
    """
    for mod in ctx.modules:
        if len(mod.tags.version) > 1:
            fail("Only one version of doxygen can be specified")
        doxygen_version = "1.11.0"
        strip_prefix = ""
        if ctx.os.name.startswith("windows"):
            doxygen_sha256 = "478fc9897d00ca181835d248a4d3e5c83c26a32d1c7571f4321ddb0f2e97459f"
        elif ctx.os.name.startswith("mac"):
            doxygen_sha256 = "7ffb89909800242e29585e619582972c901ee0045cf4b7c4ef58a91c445f89eb"
        elif ctx.os.name == "linux":
            doxygen_sha256 = "db68ca22b43c3d7efd15351329db5af9146ab1ac7eaccd61a894fe36612da8fb"
        else:
            fail("Unsuppported OS: %s" % ctx.os.name)

        for attr in mod.tags.version:
            doxygen_version = attr.version if attr.version != "" else fail("Version must be specified")
            doxygen_sha256 = attr.sha256 if attr.sha256 != "" else "0" * 64

        if doxygen_version == "0.0.0":
            local_repository_doxygen(
                name = "doxygen",
            )
            return

        doxygen_version_dash = doxygen_version.replace(".", "_")

        url = "https://github.com/doxygen/doxygen/releases/download/Release_%s/doxygen-%s.%s"
        if ctx.os.name.startswith("windows"):
            url = url % (doxygen_version_dash, doxygen_version, "windows.x64.bin.zip")
        elif ctx.os.name.startswith("mac"):  # TODO: support macos for hermetic build
            url = url % (doxygen_version_dash, doxygen_version, "dmg")
            fail("Unsuppported OS: %s" % ctx.os.name)
        elif ctx.os.name == "linux":
            url = url % (doxygen_version_dash, doxygen_version, "linux.bin.tar.gz")
            strip_prefix = "doxygen-%s" % doxygen_version
        else:
            fail("Unsuppported OS: %s" % ctx.os.name)

        doxygen_bzl_content = ctx.read(Label("@rules_doxygen//:doxygen.bzl"))
        http_archive(
            name = "doxygen",
            build_file = "@rules_doxygen//:doxygen.BUILD.bazel",
            url = url,
            sha256 = doxygen_sha256,
            patch_cmds = ["cat > 'doxygen.bzl' <<- EOF\n%s\nEOF" % doxygen_bzl_content],
            patch_cmds_win = ["Set-Content -Path 'doxygen.bzl' -Value '%s'" % doxygen_bzl_content],
            strip_prefix = strip_prefix,
        )

_doxygen_version = tag_class(attrs = {
    "version": attr.string(doc = "The version of doxygen to use. If set to `0.0.0`, the doxygen executable will be assumed to be available from the PATH", mandatory = True),
    "sha256": attr.string(doc = "The sha256 hash of the doxygen archive. If not specified, an all-zero hash will be used."),
})

doxygen_extension = module_extension(
    implementation = _doxygen_extension_impl,
    tag_classes = {"version": _doxygen_version},
    doc = """
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

If you set the version to `0.0.0`, the doxygen executable will be assumed to be available from the PATH.
No download will be performed and bazel will use the installed version of doxygen.
Keep in mind that this will break the hermeticity of your build, as it will now depend on the environment.

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
