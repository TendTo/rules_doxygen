load("@doxygen//:doxygen.bzl", "collect_files_aspect_factory", "doxygen_rule_factory")

collect_ext_and_gen_files_aspect = collect_files_aspect_factory(
    collect_external = True,  # We want to include external dependencies in our doxygen documentation.
    collect_generated = True,  # We want to include generated files in our doxygen documentation.
)

# Define and expose a custom doxygen rule that uses the above aspect to collect external and generated files.
ext_and_gen_doxygen_rule = doxygen_rule_factory(
    collect_files_aspect = collect_ext_and_gen_files_aspect,
)
