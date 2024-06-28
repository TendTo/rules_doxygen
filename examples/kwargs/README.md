# Keyword Arguments

This is a simple example showing how the `doxygen` macro supports keyword arguments.
Those will be passed to the underlying `_doxygen` rule invocation, making it more flexible.
Move to the parent directory and run the following command:

```bash
bazel build --build_tag_filters="doxytag" //kwargs/...
```
