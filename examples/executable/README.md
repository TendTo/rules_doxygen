# Executable example

Instead of using one of the official `Doxygen` executables from the [releases page](https://github.com/doxygen/doxygen/releases), you can also provide your own.
There are no restrictions, as long as it can run on the build platform.

In this example, we showcase a self-documenting C++ program that generates its own documentation.
Not particularly useful, as we ignore the `Doxyfile` and the source inputs, but it serves as a simple demonstration.

```bash
bazel build //executable:doxygen
```
