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
    ctx.file("WORKSPACE", "workspace(name = doxygen)\n")
    ctx.file("doxygen.bzl", ctx.read(ctx.attr.doxygen_bzl))
    ctx.file("BUILD.bazel", ctx.read(ctx.attr.build))
    ctx.file("Doxyfile.template", ctx.read(ctx.attr.doxyfile_template))

    # Copy the doxygen executable to the repository
    if ctx.os.name.startswith("windows"):
        doxygen_content = ctx.read(ctx.attr.executable or ctx.which("doxygen"))
        ctx.file("doxygen.exe", doxygen_content, executable = True, legacy_utf8 = False)
    elif ctx.os.name.startswith("mac"):
        if ctx.which("doxygen"):
            doxygen_content = ctx.read(ctx.which("doxygen"))
            ctx.file("doxygen", doxygen_content, legacy_utf8 = False)
        elif ctx.attr.executable:
            doxygen_content = ctx.read(ctx.attr.executable)
            ctx.file("doxygen", doxygen_content, legacy_utf8 = False)
        else:
            doxygen_path = ctx.path("doxygen")
            dmg_path = ctx.path("doxygen.dmg")
            mount_path = ctx.path("tmp_mount")
            executable_path = ctx.path("mac_executable")
            ctx.download(url = ctx.attr.url, output = dmg_path, sha256 = ctx.attr.sha256)
            ctx.execute(["mkdir", "-p", str(mount_path)])
            ctx.execute(["hdiutil", "attach", str(dmg_path), "-mountpoint", str(mount_path), "-nobrowse"])
            ctx.execute(["cp", str(mount_path) + "/Doxygen.app/Contents/Resources/doxygen", str(executable_path)])
            ctx.execute(["chmod", "+x", str(executable_path)])
            ctx.execute(["hdiutil", "detach", str(mount_path)])
            ctx.execute(["rm", "-rf", str(mount_path)])
            ctx.execute(["rm", str(dmg_path)])
            doxygen_content = ctx.read(executable_path)
            ctx.file(doxygen_path, doxygen_content, executable = True, legacy_utf8 = False)
    elif ctx.os.name == "linux":
        doxygen_path = ctx.path("bin/doxygen")
        doxygen_content = ctx.read(ctx.attr.executable or ctx.which("doxygen"))
        ctx.file(doxygen_path, doxygen_content, executable = True, legacy_utf8 = False)
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
        "url": attr.string(
            doc = "The Doxygen download URL.",
        ),
        "sha256": attr.string(
            doc = "The expected SHA-256 of the Doxygen download URL.",
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

        for attr in mod.tags.version:
            doxygen_version = attr.version if attr.version != "" else fail("Version must be specified")
            doxygen_mac_sha256 = attr.mac_sha256 if attr.mac_sha256 != "" else "0" * 64
            doxygen_linux_sha256 = attr.linux_sha256 if attr.linux_sha256 != "" else "0" * 64
            doxygen_windows_sha256 = attr.windows_sha256 if attr.windows_sha256 != "" else "0" * 64

        if doxygen_version == "0.0.0":
            local_repository_doxygen(
                name = "doxygen",
            )
            return

        if doxygen_version == "1.12.0":
            doxygen_mac_sha256 = "6ace7dde967d41f4e293d034a67eb2c7edd61318491ee3131112173a77344001"
            doxygen_linux_sha256 = "3c42c3f3fb206732b503862d9c9c11978920a8214f223a3950bbf2520be5f647"
            doxygen_windows_sha256 = "07f1c92cbbb32816689c725539c0951f92c6371d3d7f66dfa3192cbe88dd3138"

        strip_prefix = ""

        use_http_archive = True
        if ctx.os.name.startswith("windows"):
            file_ext = "windows.x64.bin.zip"
        elif ctx.os.name.startswith("mac"):
            file_ext = "dmg"
            use_http_archive = False
        elif ctx.os.name == "linux":
            file_ext = "linux.bin.tar.gz"
            strip_prefix = "doxygen-%s" % doxygen_version
        else:
            fail("Unsuppported OS: %s" % ctx.os.name)

        doxygen_version_dash = doxygen_version.replace(".", "_")
        url = "https://github.com/doxygen/doxygen/releases/download/Release_%s/doxygen-%s.%s" % (
            doxygen_version_dash,
            doxygen_version,
            file_ext
        )

        if use_http_archive:
            doxygen_bzl_content = ctx.read(Label("@rules_doxygen//:doxygen.bzl"))
            sha256 = doxygen_linux_sha256 if ctx.os.name == "linux" else doxygen_windows_sha256
            http_archive(
                name = "doxygen",
                build_file = "@rules_doxygen//:doxygen.BUILD.bazel",
                url = url,
                sha256 = sha256,
                patch_cmds = ["cat > 'doxygen.bzl' <<- EOF\n%s\nEOF" % doxygen_bzl_content],
                patch_cmds_win = ["Set-Content -Path 'doxygen.bzl' -Value '%s'" % doxygen_bzl_content],
                strip_prefix = strip_prefix,
            )
        else:
            local_repository_doxygen(
                name = "doxygen",
                url = url,
                sha256 = doxygen_mac_sha256,
            )

_doxygen_version = tag_class(attrs = {
    "version": attr.string(doc = "The version of doxygen to use. If set to `0.0.0`, the doxygen executable will be assumed to be available from the PATH", mandatory = True),
    "mac_sha256": attr.string(doc = "The sha256 hash of the doxygen archive. If not specified, an all-zero hash will be used."),
    "linux_sha256": attr.string(doc = "The sha256 hash of the doxygen archive. If not specified, an all-zero hash will be used."),
    "windows_sha256": attr.string(doc = "The sha256 hash of the doxygen archive. If not specified, an all-zero hash will be used."),
})

doxygen_extension = module_extension(
    implementation = _doxygen_extension_impl,
    tag_classes = {"version": _doxygen_version},
    doc = """
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
""",
)
