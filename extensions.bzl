"""Repository rule for downloading the correct version of doxygen using module extensions."""

load("@bazel_tools//tools/build_defs/repo:cache.bzl", "get_default_canonical_id")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "get_auth")

def _get_current_platform(ctx):
    """
    Get the current platform.

    It uses the context to get the current platform and architecture and returns the platform name.
    The string returned is one of the following:

    - windows
    - mac
    - mac-arm
    - linux
    - linux-arm

    Args:
        ctx: a [repository context](https://bazel.build/rules/lib/builtins/repository_ctx) object
            or a [module context](https://bazel.build/rules/lib/builtins/module_ctx) object
            containing the repository's attributes
    """

    if ctx.os.name.startswith("windows"):
        return "windows"
    if ctx.os.name.startswith("mac") and (ctx.os.arch == "amd64" or ctx.os.arch == "i686" or ctx.os.arch == "x86_64"):
        return "mac"
    if ctx.os.name.startswith("mac") and ctx.os.arch == "aarch64":
        return "mac-arm"
    if ctx.os.name == "linux" and (ctx.os.arch == "amd64" or ctx.os.arch == "i686" or ctx.os.arch == "x86_64"):
        return "linux"
    if ctx.os.name == "linux" and ctx.os.arch == "aarch64":
        return "linux-arm"
    fail("Unsupported platform: %s (%s)" % (ctx.os.name, ctx.os.arch))

def _doxygen_repository(ctx):
    """
    Repository rule for doxygen.

    Used to create a local repository for doxygen, containing the installed doxygen binary and all the necessary files to run the doxygen macro.

    Args:
        ctx: a [repository context](https://bazel.build/rules/lib/builtins/repository_ctx) object containing the repository's attributes
    """

    # Copy the necessary files to the repository by reading them from the current repository
    if len(ctx.attr.versions) != len(ctx.attr.sha256s) or len(ctx.attr.versions) != len(ctx.attr.platforms) or len(ctx.attr.versions) != len(ctx.attr.executables):
        fail("The number of versions, sha256s, platforms and executables must be the same")
    for platform in ctx.attr.platforms:
        if platform not in ("windows", "mac", "mac-arm", "linux", "linux-arm"):
            fail("Unsupported platform: '%s'. Available options are (windows, mac, mac-arm, linux, linux-arm)" % platform)

    ctx.file("WORKSPACE", "workspace(name = %s)\n" % repr(ctx.name))
    ctx.file("doxygen.bzl", ctx.read(ctx.attr.doxygen_bzl))
    ctx.file("BUILD.bazel", ctx.read(ctx.attr.build))
    ctx.file("Doxyfile.template", ctx.read(ctx.attr.doxyfile_template))

    for doxygen_version, sha256, platform, executable in zip(ctx.attr.versions, ctx.attr.sha256s, ctx.attr.platforms, ctx.attr.executables):
        if platform == "windows" and _get_current_platform(ctx) == platform:
            executable_destination = "windows/doxygen.exe"
        elif platform in ("mac", "mac-arm") and _get_current_platform(ctx) == platform:
            executable_destination = "mac/doxygen"
        elif platform in ("linux", "linux-arm") and _get_current_platform(ctx) == platform:
            executable_destination = "linux/doxygen"
        else:
            continue  # Skip the platform if it does not match the current platform. No operation will be performed

        # If the version is set to 0.0.0 use the installed version of doxygen from the PATH
        # No download will be performed
        # This happens only if the platform matches the current platform
        if doxygen_version == "0.0.0":
            ctx.file(executable_destination, ctx.read(ctx.which("doxygen")), legacy_utf8 = False)
            continue

        # If an executable is provided, use it instead of downloading the doxygen binary
        if executable != "":
            ctx.file(executable_destination, ctx.read(Label(executable)), legacy_utf8 = False)
            continue

        url = "https://github.com/doxygen/doxygen/releases/download/Release_%s/doxygen-%s.%s"
        doxygen_version_dash = doxygen_version.replace(".", "_")
        download_output = "doxygen-dir"

        if platform == "windows":
            # For windows, download the zip file and extract the executable and dll
            url = url % (doxygen_version_dash, doxygen_version, "windows.x64.bin.zip")
            ctx.download_and_extract(
                url = url,
                output = download_output,
                sha256 = sha256,
                type = "zip",
                canonical_id = get_default_canonical_id(ctx, [url]),
                auth = get_auth(ctx, [url]),
            )

            # Copy the doxygen executable (and dll) to the repository
            ctx.file(executable_destination, ctx.read("doxygen-dir/doxygen.exe"), legacy_utf8 = False)
            ctx.file("windows/libclang.dll", ctx.read("doxygen-dir/libclang.dll"), legacy_utf8 = False)

        elif platform in ("mac", "mac-arm"):
            # For mac, download the dmg file, mount it and copy the executable
            url = url % (doxygen_version_dash, doxygen_version, "dmg")
            download_output = "doxygen.dmg"
            ctx.download(
                url = url,
                output = download_output,
                sha256 = sha256,
                canonical_id = get_default_canonical_id(ctx, [url]),
                auth = get_auth(ctx, [url]),
            )

            # Mount the dmg file
            ctx.execute(["hdiutil", "attach", "-nobrowse", "-readonly", "-mountpoint", "doxygen-mount", download_output])

            # Copy the doxygen executable to the repository
            ctx.file(executable_destination, ctx.read("doxygen-mount/Doxygen.app/Contents/Resources/doxygen"), legacy_utf8 = False)

            # Unmount the dmg file
            ctx.execute(["hdiutil", "detach", "doxygen-mount"])

        elif platform in ("linux", "linux-arm"):
            # For linux, download the tar.gz file and extract the executable
            url = url % (doxygen_version_dash, doxygen_version, "linux.bin.tar.gz")
            ctx.download_and_extract(
                url = url,
                output = download_output,
                sha256 = sha256,
                type = "tar.gz",
                canonical_id = get_default_canonical_id(ctx, [url]),
                auth = get_auth(ctx, [url]),
                stripPrefix = "doxygen-%s" % doxygen_version,
            )

            # Copy the doxygen executable to the repository
            ctx.file(executable_destination, ctx.read("doxygen-dir/bin/doxygen"), legacy_utf8 = False)

        # Delete temporary files
        ctx.delete(download_output)

doxygen_repository = repository_rule(
    implementation = _doxygen_repository,
    doc = """
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
""",
    attrs = {
        "versions": attr.string_list(
            doc = "List of versions of doxygen to use. If set to `0.0.0`, the doxygen executable will be assumed to be available from the PATH. Must be the same length as `sha256s`, `platforms` and `executables`.",
            mandatory = True,
            allow_empty = False,
        ),
        "sha256s": attr.string_list(
            doc = "List of sha256 hashes of the doxygen archive. Must be the same length as `versions, `platforms` and `executables`.",
            mandatory = True,
            allow_empty = False,
        ),
        "platforms": attr.string_list(
            doc = "List of platforms to download the doxygen binary for. Available options are (windows, mac, mac-arm, linux, linux-arm). Must be the same length as `version`, `sha256s` and `executables`.",
            mandatory = True,
            allow_empty = False,
        ),
        "executables": attr.string_list(
            doc = "List of paths to doxygen executables to use. If set, no download will take place and the provided doxygen executable will be used. Mutually exclusive with `version`. Must be the same length as `version`, `sha256s` and `platforms`.",
            allow_empty = False,
            mandatory = True,
        ),
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
    },
)

def _doxygen_extension_impl(ctx):
    """_doxygen_module_impl

    Downloads the correct version of doxygen and make the repository available to the requesting module.

    Args:
        ctx: a [module context](https://bazel.build/rules/lib/builtins/module_ctx) object containing the module's attributes
    """
    for mod in ctx.modules:
        platforms = []
        versions = []
        sha256s = []
        executables = []

        default_configurations = {
            "windows": struct(version = "1.12.0", sha256 = "07f1c92cbbb32816689c725539c0951f92c6371d3d7f66dfa3192cbe88dd3138", executable = ""),
            "mac": struct(version = "1.12.0", sha256 = "6ace7dde967d41f4e293d034a67eb2c7edd61318491ee3131112173a77344001", executable = ""),
            "mac-arm": struct(version = "1.12.0", sha256 = "6ace7dde967d41f4e293d034a67eb2c7edd61318491ee3131112173a77344001", executable = ""),
            "linux": struct(version = "1.12.0", sha256 = "3c42c3f3fb206732b503862d9c9c11978920a8214f223a3950bbf2520be5f647", executable = ""),
            "linux-arm": struct(version = "1.12.0", sha256 = "3c42c3f3fb206732b503862d9c9c11978920a8214f223a3950bbf2520be5f647", executable = ""),
        }

        # Otherwise, add all the configurations (version and sha256) for each platform
        for attr in mod.tags.configuration:
            platform = attr.platform if attr.platform != "" else _get_current_platform(ctx)
            if attr.version != "" and attr.executable != None:
                fail("`Version` and `executable` are mutually exclusive")
            if attr.version == "" and attr.executable == None:
                fail("Exactly one between `version` and `executable` must be specified")
            if platform not in default_configurations:
                fail("Unsupported platform: '%s'. Available options are (windows, mac, mac-arm, linux, linux-arm)" % platform)
            if platform in platforms:
                fail("Doxygen configuration for platform '%s' was already specified: (version = '%s', sha256 = '%s', executable = %s)" % (platform, versions[platforms.index(platform)], sha256s[platforms.index(platform)], executables[platforms.index(platform)]))
            platforms.append(platform)
            versions.append(attr.version)
            sha256s.append(attr.sha256 if attr.sha256 != "" else "0" * 64)
            executables.append(str(attr.executable) if attr.executable != None else "")

        # If no version is specified for a platform, use the default
        for platform in default_configurations:
            if platform not in platforms:
                platforms.append(platform)
                versions.append(default_configurations[platform].version)
                sha256s.append(default_configurations[platform].sha256)
                executables.append(default_configurations[platform].executable)

        doxygen_repository(
            name = "doxygen",
            versions = versions,
            sha256s = sha256s,
            platforms = platforms,
            executables = executables,
        )

_doxygen_configuration = tag_class(attrs = {
    "version": attr.string(doc = "The version of doxygen to use. If set to `0.0.0`, the doxygen executable will be assumed to be available from the PATH. Mutually exclusive with `executable`."),
    "sha256": attr.string(doc = "The sha256 hash of the doxygen archive. If not specified, an all-zero hash will be used."),
    "platform": attr.string(doc = "The target platform for the doxygen binary. Available options are (windows, mac, mac-arm, linux, linux-arm). If not specified, it will select the platform it is currently running on."),
    "executable": attr.label(doc = "The doxygen executable to use. If set, no download will take place and the provided doxygen executable will be used. Mutually exclusive with `version`."),
})

doxygen_extension = module_extension(
    implementation = _doxygen_extension_impl,
    tag_classes = {"configuration": _doxygen_configuration},
    doc = """
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
    executable = "@my_module//path/to/doxygen:doxygen",
    platform = "mac-arm",
)
# Since no configuration has been provided, all other platforms will fallback to the default version

use_repo(doxygen_extension, "doxygen")
```
""",
)
