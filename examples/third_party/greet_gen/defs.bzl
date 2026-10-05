load("@rules_cc//cc:defs.bzl", "cc_library")

def _generate_greeting_impl(ctx):
    out_src_filename = ctx.attr.name + ".cpp"
    out_src_file = ctx.actions.declare_file(out_src_filename)

    greeting_content = """/// @file {}
/// @author Generated
#include "greet.h"
#include <string>
namespace greet {{
std::string generated_greeting() {{
    return "{}";
}}
}} // namespace greet
""".format(
        out_src_filename,
        ctx.attr.greeting,
    )

    ctx.actions.write(
        output = out_src_file,
        content = greeting_content,
    )

    out_hdr_filename = ctx.attr.name + ".h"
    out_hdr_file = ctx.actions.declare_file(out_hdr_filename)

    greeting_version = """/// @file {}
/// @author Generated
#pragma once
namespace greet {{
static const int greeting_version = {};
}} // namespace greet
""".format(
        out_hdr_filename,
        ctx.attr.greeting_version,
    )

    ctx.actions.write(
        output = out_hdr_file,
        content = greeting_version,
    )

    # Return the file wrapped in DefaultInfo so other targets or command-line requests can find it
    return [
        DefaultInfo(files = depset([out_src_file, out_hdr_file])),
    ]

# Define the custom rule schema
_generate_greeting = rule(
    implementation = _generate_greeting_impl,
    attrs = {
        "greeting": attr.string(mandatory = True, doc = "The text of the custom greeting."),
        "greeting_version": attr.int(
            mandatory = True,
            doc = "The version of the custom greeting.",
        ),
    },
)

def generate_greeting(name, greeting, greeting_version, **kwargs):
    _generate_greeting(
        name = name + "_gen",
        greeting = greeting,
        greeting_version = greeting_version,
        visibility = ["//visibility:private"],
    )
    cc_library(
        name = name,
        srcs = [name + "_gen"],
        hdrs = [name + "_gen"],
        deps = ["@greet_generator//:greet_api"],
        **kwargs
    )
