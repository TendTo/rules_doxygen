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
- `# {{ADDITIONAL PARAMETERS}}`: Additional parameters given in the `configurations` attribute.
- `# {{OUTPUT DIRECTORY}}`: The directory provided in the `outs` attribute.

It is highly recommended to at least use the `# {{OUTPUT DIRECTORY}}` expression at the very end of your doxyfile, since the exact path of the output is computed at runtime by Bazel and may be different on different platforms.
