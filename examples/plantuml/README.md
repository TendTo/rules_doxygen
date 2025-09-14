# Plantuml example

This is an example of how to use the `doxygen` alongside `plantuml` to generate UML diagrams for C++ classes.
You will need to provide the `plantuml.jar` file to the rule, as well as the `java` executable.

The JAR can be downloaded from the [plantuml releases page](https://github.com/plantuml/plantuml/releases).

```bzl
# We will use the Java toolchain from rules_java to run the JAR
bazel_dep(name = "rules_java", version = "8.15.1")


http_file = use_repo_rule("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
http_file(
    name = "plantuml_file",
    urls = ["https://github.com/plantuml/plantuml/releases/download/v1.2025.4/plantuml-1.2025.4.jar"],
    sha256 = "26518e14a3a04100cd76c0d96cab2d1171f36152215edd9790a28d20268200c1",
    downloaded_file_path = "plantuml.jar",
)
```

## Using the JAR

Since the location of the JAR can be difficult to determine, we recommend copying it to the `OUTDIR` folder using the `copy_file` rule from `aspect_bazel_lib`.

```bzl
load("@aspect_bazel_lib//lib:copy_file.bzl", "copy_file")

# This is highly advised to avoid chasing the jar file who knows where
# Instead, we copy it in the OUTDIR folder
copy_file(
    name = "plantuml",
    src = "@plantuml_file//file",
    out = "plantuml.jar",
    allow_symlink = False,
    is_executable = False,
)
```

Lastly, you can use the `doxygen` rule as follows:

```bzl
load("@doxygen//:doxygen.bzl", "doxygen")

doxygen(
    name = "doxygen",
    srcs = [
        "lib.h",
        ":plantuml",
    ],
    plantuml_jar_path = "$(OUTDIR)",
    project_brief = "Example project for doxygen",
    project_name = "Plantuml example",
    tools = [
        # Using the java executable from `rules_java`
        "@rules_java//toolchains:current_java_runtime",
    ],
)
```
