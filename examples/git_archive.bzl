"""Repository rules for downloading archives from GitHub and GitLab"""

def workspace_and_buildfile(ctx):
    """Utility function for writing WORKSPACE and, if requested, a BUILD file.

    This rule is intended to be used in the implementation function of a
    repository rule.
    It assumes the parameters `name`, `build_file`, `build_file_content`,
    `workspace_file`, and `workspace_file_content` to be
    present in `ctx.attr`; the latter four possibly with value None.

    Args:
      ctx: The repository context of the repository rule calling this utility
        function.
    """
    if ctx.attr.build_file and ctx.attr.build_file_content:
        ctx.fail("Only one of build_file and build_file_content can be provided.")

    if ctx.attr.workspace_file and ctx.attr.workspace_file_content:
        ctx.fail("Only one of workspace_file and workspace_file_content can be provided.")

    if ctx.attr.workspace_file:
        ctx.file("WORKSPACE", ctx.read(ctx.attr.workspace_file))
    elif ctx.attr.workspace_file_content:
        ctx.file("WORKSPACE", ctx.attr.workspace_file_content)
    else:
        ctx.file("WORKSPACE", "workspace(name = \"{name}\")\n".format(name = ctx.name))

    if ctx.attr.build_file:
        ctx.file("BUILD.bazel", ctx.read(ctx.attr.build_file))
    elif ctx.attr.build_file_content:
        ctx.file("BUILD.bazel", ctx.attr.build_file_content)

def _github_archive_impl(repository_ctx):
    """A rule to be called in the WORKSPACE that adds an external from github using a workspace rule.

    The required name= is the rule name and so is used for @name//... labels when referring to this archive from BUILD files.

    The required commit= is the git hash to download.
    When the git project is also a git submodule in CMake, this should be kept in sync with the git submodule commit used there.
    This can also be a tag.

    The required sha256= is the checksum of the downloaded archive.
    When unsure, you can omit this argument (or comment it out) and then the checksum-mismatch error message message will offer a suggestion.

    The optional build_file= is the BUILD file label to use for building this external.
    When omitted, the BUILD file(s) within the archive will be used.

    The optional local_repository_override= can be used for temporary local testing;
    instead of retrieving the code from github, the code is retrieved from the local filesystem path given in the argument.

    Args:
        repository_ctx: The context object for the repository rule.
    """
    if repository_ctx.attr.build_file and repository_ctx.attr.build_file_content:
        fail("Only one of build_file and build_file_content can be provided.")
    if repository_ctx.attr.workspace_file and repository_ctx.attr.workspace_file_content:
        fail("Only one of workspace_file and workspace_file_content can be provided.")

    repository = repository_ctx.attr.repository
    commit = repository_ctx.attr.commit

    urls = ["https://github.com/%s/archive/%s.tar.gz" % (repository, commit)]

    repository_split = repository.split("/")
    if len(repository_split) != 2:
        fail("The repository must be formatted as 'organization/project'. Got: %s" % repository)
    _, project = repository_split

    # Github archives omit the "v" in version tags, for some reason.
    strip_commit = commit.removeprefix("v")
    strip_prefix = project + "-" + strip_commit

    repository_ctx.download_and_extract(
        urls,
        sha256 = repository_ctx.attr.sha256,
        stripPrefix = strip_prefix,
    )
    workspace_and_buildfile(repository_ctx)

github_archive = repository_rule(
    implementation = _github_archive_impl,
    local = True,
    attrs = {
        "repository": attr.string(mandatory = True, doc = "The github repository to download from."),
        "commit": attr.string(mandatory = True, doc = "The git commit hash to download."),
        "sha256": attr.string(default = "0" * 64, doc = "The sha256 checksum of the downloaded archive."),
        "build_file": attr.label(doc = "The BUILD file label to use for building this external."),
        "build_file_content": attr.string(doc = "The content for the BUILD file for this repository."),
        "workspace_file": attr.label(doc = "The file to use as the `WORKSPACE` file for this repository."),
        "workspace_file_content": attr.string(doc = "The content for the WORKSPACE file for this repository."),
    },
)
