# Doxyfile example

A slightly more complex example where the user provided Doxyfile is used instead.
Move to the parent directory and run the following command:

```bash
bazel build //doxyfile:doxygen
```

## Template Doxyfile

While the `doxygen` rule provides a default Doxyfile, you can provide your own, as shown in this example.
Keep in mind that the file will undergo the same template processing as the default one.
Namely, the following expressions will be replaced:

- `# {{INPUT}}`: Subpackage directory in the sandbox.
- `# {{DOT_PATH}}`: Indicate to doxygen the location of the `dot_executable`
- `# {{ADDITIONAL PARAMETERS}}`: Additional parameters given in the `configurations` attribute.
- `# {{OUTPUT DIRECTORY}}`: The directory provided in the `outs` attribute.
- `{{OUTDIR}}`: The output directory where the generated documentation will be placed.
  Can be used anywhere in the Doxyfile, usually to generate additional output files, like tag files.

In this example, note how the `GENERATE_TAGFILE` value in the Doxyfile is set to `{{OUTDIR}}/html/index.tag`, which will be replaced with the actual output directory at runtime, generating the desired file.
It is highly recommended to at least use the `# {{OUTPUT DIRECTORY}}` expression at the very end of your Doxyfile, since the exact path of the output is computed at runtime by Bazel and it may differ on each platform.
