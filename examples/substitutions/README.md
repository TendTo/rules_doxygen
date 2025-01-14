# Basic usage example

This is a basic example of how to use the doxygen rule with make variable substitutions.
The advantage of using make variable substitutions instead of directly working over the values passed to the doxygen rule is that you can access informations from other rules and toolchains and use them in the documentation.
Move to the parent directory and run the following command:

```bash
# Version: _empty_ , Description: "no stamp"
bazel build //substitutions:doxygen
# or
# Version: _empty_ , Description: "stamp fallback"
bazel build //substitutions:doxygen --stamp
# or
# Version: 1.0.0 , Description: "MyBuildDescription"
bazel build //substitutions:doxygen --stamp --//substitutions:build_description="MyBuildDescription" --embed_label=1.0.0
```

> [!NOTE]  
> If `--stamp` is not passed, the version will be undetermined, usually an empty string or the last stamped value.

## Custom substitutions

We are reading variables from three sources:

- Hardcoded constant strings in the `BUILD.bazel` file (e.g. `NAME`).
- String flags passed through the command line (e.g. `--substitutions:build_description=MyBuildDescription`).
- The `stamp` information stored in the `bazel-out/stable-status.txt` file.

### Make variables

For the first two kind of substitution we need to define a simple rule that will apply the make variable substitutions.
Let's say we want to pass a version number to the doxygen rule from a command line flag, but only if the build is stamped.
So, first we use `skylib` to define a string flag.

```bzl
# BUILD.bazel

load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

string_flag(
    name = "build_description",
    build_setting_default = "stamp fallback",
)
```

> [!TIP]  
> You can define an alias for the flag to make it easier to use in the command line.
> Create a `.bazelrc` file in the root of your workspace with the following content:
>
> ```bash
> build --flag_alias=build_description=//substitutions:build_description
> ```
>
> Now you can use `--build_description=MyBuildDescription` instead of `--//substitutions:build_description=MyBuildDescription`.

Then we create a substitution rule.

```bzl
# make_var_substitution.bzl

load("@aspect_bazel_lib//lib:stamping.bzl", "STAMP_ATTRS", "maybe_stamp")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

def _make_var_substitution_impl(ctx):
    vars = dict(ctx.attr.variables)
    stamp = maybe_stamp(ctx)
    if stamp:  # If the build is stamped, use the value from --//substitutions:build_description as the build version.
        vars["BUILD_DESCRIPTION"] = ctx.attr._build_description[BuildSettingInfo].value
    else:  # Otherwise use the hardcoded value.
        vars["BUILD_DESCRIPTION"] = "0.0.0"
    return [platform_common.TemplateVariableInfo(vars)]

make_var_substitution = rule(
    implementation = _make_var_substitution_impl,
    attrs = dict({
        "variables": attr.string_dict(),
        "_build_description": attr.label(default = "//substitutions:build_description"),
    }, **STAMP_ATTRS),
)
```

Finally, the substitution rule can be used as a toolchain in the doxygen rule.

All configurations using the make variable syntax will be replaced with the values defined in the make_var_substitution rule.

### Stamp information

To retrieve the stamp information from the `bazel-out/stable-status.txt` file, we have to define a genrule that reads the file and extracts the `BUILD_EMBED_LABEL` .
That information will be used to modify our custom `Doxyfile.template` file we will provide to the doxygen rule.

```bzl
# BUILD.bazel

# Use a shell script to read the version from the stable-status.txt file
# It will replace the pattern {{PROJECT_NUMBER}} in the Doxyfile.template file
genrule(
    name = "doxyfile_template",
    srcs = ["Doxyfile.template"],
    outs = ["NewDoxyfile"],
    cmd = "sed s/{{PROJECT_NUMBER}}/$(grep -oP '(?<=BUILD_EMBED_LABEL ).+' bazel-out/stable-status.txt)/ $(SRCS) > $@",
    cmd_ps = "Get-content $(SRCS) | ForEach-Object { $$_ -replace '{{PROJECT_NUMBER}}', (Select-String -Pattern '(?<=BUILD_EMBED_LABEL +)(.+)' bazel-out/stable-status.txt -AllMatches | Select-Object -Expand Matches | Select-Object -Expand Value) } > $@",
    stamp = -1, # Only update if --stamp is passed
)
```

### Final result

```bzl
# BUILD.bazel

load("@doxygen//:doxygen.bzl", "doxygen")
load("//substitutions:make_var_substitution.bzl", "make_var_substitution")

# Use a shell script to read the version from the stable-status.txt file
# It will replace the pattern {{PROJECT_NUMBER}} in the Doxyfile.template file
genrule(
    name = "doxyfile_template",
    srcs = ["Doxyfile.template"],
    outs = ["NewDoxyfile"],
    cmd = "sed s/{{PROJECT_NUMBER}}/$(grep -oP '(?<=BUILD_EMBED_LABEL ).+' bazel-out/stable-status.txt)/ $(SRCS) > $@",
    cmd_ps = "Get-content $(SRCS) | ForEach-Object { $$_ -replace '{{PROJECT_NUMBER}}', (Select-String -Pattern '(?<=BUILD_EMBED_LABEL +)(.+)' bazel-out/stable-status.txt -AllMatches | Select-Object -Expand Matches | Select-Object -Expand Value) } > $@",
    stamp = -1, # Only update if --stamp is passed
)

# Use the make_var_substitution rule to define some other custom substitutions
make_var_substitution(
    name = "make_var_substitution",
    variables = {
        "NAME": "substitutions",
    },
)

doxygen(
    name = "doxygen",
    srcs = glob([
        "*.h",
        "*.cpp",
    ]),
    project_brief = "$(DESCRIPTION)", # => "no stamp" or "//substitutions:build_description" if the build is stamped
    project_name = "$(NAME)", # => "substitutions"
    doxyfile_template = ":doxyfile_template",
    toolchains = [":make_var_substitution"],
)
```
