#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Argument provided by reusable workflow caller, see
# https://github.com/bazel-contrib/.github/blob/d197a6427c5435ac22e56e33340dff912bc9334e/.github/workflows/release_ruleset.yaml#L72
TAG=$1
# The prefix is chosen to match what GitHub generates for source archives
PREFIX="rules_doxygen-${TAG}"
ARCHIVE="rules_doxygen-$TAG.tar.gz"
git archive --format=tar --prefix="${PREFIX}/" "${TAG}" | gzip > "$ARCHIVE"
SHA=$(shasum -a 256 "$ARCHIVE" | awk '{print $1}')

cat << EOF
## Using Bzlmod with Bazel 7 or greater

\`\`\`starlark
# MODULE.bazel

bazel_dep(name = "rules_doxygen", version = "${TAG}", dev_dependency = True)

doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")

# Specify the desired version of Doxygen to use
# ...

use_repo(doxygen_extension, "doxygen")
\`\`\`

## Changelog

$(awk -v ver=$TAG '
 /^#+ \[/ { if (p) { exit }; if ($2 == "["ver"]") { p=1; next} } p && NF
' CHANGELOG.md)

EOF
