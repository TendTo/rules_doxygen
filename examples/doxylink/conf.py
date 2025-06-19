#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os

project = "rules_doxygen"
author = "TendTo"
copyright = "2025, TendTo"
release = "0.0.0"
exclude_patterns = ["**/*bazel*"]
pygments_style = "sphinx"

extensions = ["sphinxcontrib.doxylink"]

doxylink = {
    "lib": (
        os.path.abspath("doxygen/tags/lib.tag"),  # Path to the Doxygen tag file
        "../../../html",  # Path to the Doxygen html output files.
        # Should be correct with respect to the hosted Sphinx documentation
    ),
}
doxylink_parse_error_ignore_regexes = [r"DEFINE.*"]

# master_doc = 'index'
