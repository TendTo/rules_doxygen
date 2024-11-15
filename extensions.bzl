"""Repository rule for downloading the correct version of doxygen using module extensions."""

load("@bazel_tools//tools/build_defs/repo:cache.bzl", "get_default_canonical_id")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "get_auth")

def _doxygen_repository(ctx):
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

    doxygen_version = ctx.attr.version

    # If the version is set to 0.0.0 use the installed version of doxygen from the PATH
    if doxygen_version == "0.0.0":
        if ctx.os.name.startswith("windows"):
            ctx.file("doxygen.exe", ctx.read(ctx.which("doxygen")), legacy_utf8 = False)
        else:
            ctx.file("doxygen", ctx.read(ctx.which("doxygen")), legacy_utf8 = False)
        return

    doxygen_version_dash = doxygen_version.replace(".", "_")

    url = "https://github.com/doxygen/doxygen/releases/download/Release_%s/doxygen-%s.%s"

    if ctx.os.name.startswith("windows"):
        # For windows, download the zip file and extract the executable
        url = url % (doxygen_version_dash, doxygen_version, "windows.x64.bin.zip")
        ctx.download_and_extract(
            url = url,
            sha256 = ctx.attr.sha256,
            type = "zip",
            canonical_id = get_default_canonical_id(ctx, [url]),
            auth = get_auth(ctx, [url]),
        )

    elif ctx.os.name.startswith("mac"):
        # For mac, download the dmg file, mount it and copy the executable
        url = url % (doxygen_version_dash, doxygen_version, "dmg")
        ctx.download(
            url = url,
            output = "doxygen.dmg",
            sha256 = ctx.attr.sha256,
            canonical_id = get_default_canonical_id(ctx, [url]),
            auth = get_auth(ctx, [url]),
        )

        # Mount the dmg file
        ctx.execute(["hdiutil", "attach", "-nobrowse", "-readonly", "-mountpoint", "doxygen-mount", "doxygen.dmg"])

        # Copy the doxygen executable to the repository
        ctx.file("doxygen", ctx.read("doxygen-mount/Doxygen.app/Contents/Resources/doxygen"), legacy_utf8 = False)

        # Unmount the dmg file
        ctx.execute(["hdiutil", "detach", "doxygen-mount"])

        # Delete the temporary files
        ctx.delete("doxygen.dmg")

    elif ctx.os.name == "linux":
        # For linux, download the tar.gz file and extract the executable
        url = url % (doxygen_version_dash, doxygen_version, "linux.bin.tar.gz")
        ctx.download_and_extract(
            url = url,
            sha256 = ctx.attr.sha256,
            type = "tar.gz",
            canonical_id = get_default_canonical_id(ctx, [url]),
            auth = get_auth(ctx, [url]),
            stripPrefix = "doxygen-%s" % doxygen_version,
        )

        # Copy the doxygen executable to the repository
        ctx.file("doxygen", ctx.read("bin/doxygen"), legacy_utf8 = False)

        # Delete other temporary files
        for file in ("bin", "examples", "html", "man"):
            ctx.delete(file)
    else:
        fail("Unsuppported OS: %s" % ctx.os.name)

doxygen_repository = repository_rule(
    implementation = _doxygen_repository,
    doc = """
Repository rule for doxygen.

Depending on the version, the behavior will change:
- If the version is set to `0.0.0`, the repository will use the installed version of doxygen, getting the binary from the PATH.
- If a version is specified, the repository will download the correct version of doxygen and make it available to the requesting module.

> [!Note]  
> The local installation version of the rules needs doxygen to be installed on your system and the binary (named doxygen) must available in the PATH.
> Keep in mind that this will break the hermeticity of your build, as it will now depend on the environment.

You can further customize the repository by specifying the `doxygen_bzl`, `build`, and `doxyfile_template` attributes, but the default values should be enough for most use cases.

### Example

```starlark
# Download the os specific version 1.12.0 of doxygen
doxygen_repository(
    name = "doxygen",
    version = "1.12.0",
    sha256 = "07f1c92cbbb32816689c725539c0951f92c6371d3d7f66dfa3192cbe88dd3138",
)

# Use the system installed version of doxygen
doxygen_repository(
    name = "doxygen",
    version = "0.0.0",
)
```
""",
    attrs = {
        "doxygen_bzl": attr.label(
            doc = "The starlark file containing the doxygen macro",
            allow_single_file = True,
            default = Label("@rules_doxygen//doxygen:doxygen.bzl"),
        ),
        "build": attr.label(
            doc = "The BUILD file of the repository",
            allow_single_file = True,
            default = Label("@rules_doxygen//doxygen:BUILD.bazel"),
        ),
        "doxyfile_template": attr.label(
            doc = "The Doxyfile template to use",
            allow_single_file = True,
            default = Label("@rules_doxygen//doxygen:Doxyfile.template"),
        ),
        "sha256": attr.string(
            doc = "The sha256 hash of the doxygen archive. If not specified, an all-zero hash will be used.",
            default = "0" * 64,
        ),
        "version": attr.string(
            doc = "The version of doxygen to use. If set to `0.0.0`, the doxygen executable will be assumed to be available from the PATH",
            mandatory = True,
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
        doxygen_version = "1.12.0"
        if ctx.os.name.startswith("windows"):
            doxygen_sha256 = "07f1c92cbbb32816689c725539c0951f92c6371d3d7f66dfa3192cbe88dd3138"
        elif ctx.os.name.startswith("mac"):
            doxygen_sha256 = "6ace7dde967d41f4e293d034a67eb2c7edd61318491ee3131112173a77344001"
        elif ctx.os.name == "linux":
            doxygen_sha256 = "3c42c3f3fb206732b503862d9c9c11978920a8214f223a3950bbf2520be5f647"
        else:
            fail("Unsuppported OS: %s" % ctx.os.name)

        for attr in mod.tags.version:
            doxygen_version = attr.version if attr.version != "" else fail("Version must be specified")
            doxygen_sha256 = attr.sha256 if attr.sha256 != "" else "0" * 64

        doxygen_repository(
            name = "doxygen",
            sha256 = doxygen_sha256,
            version = doxygen_version,
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
# MODULE.bazel file

bazel_dep(name = "rules_doxygen", version = "...", dev_dependency = True)

doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")

# Using the 1.10.0 version of Doxygen on Windows instead of the default 1.12.0
doxygen_extension.version(version = "1.10.0", sha256 = "2135c1d5bdd6e067b3d0c40a4daac5d63d0fee1b3f4d6ef1e4f092db0d632d5b")

use_repo(doxygen_extension, "doxygen")
```
""",
)
