# Awesome example

A slightly more complex example where we choose to use the [Doxygen awesome](https://github.com/jothepro/doxygen-awesome-css) documentation theme.

```bash
bazel build //awesome:doxygen
```

## Showcase

You can add equations:

$$
\int_{-\infty}^{\infty} e^{-x^2} \, dx = \sqrt{\pi}
$$

Code snippets:

```cpp
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
```

And even mermaid diagrams:

<pre class="mermaid">
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
</pre>
