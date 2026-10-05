load("@doxygen//:doxygen.bzl", "collect_files_aspect_factory", "doxygen_rule_factory")

collect_ext_and_gen_files_aspect = collect_files_aspect_factory(
    collect_external=True,
    collect_generated=True,
)

ext_and_gen_doxygen_rule = doxygen_rule_factory(
    collect_files_aspect=collect_ext_and_gen_files_aspect,
)
