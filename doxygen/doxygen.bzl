"""Doxygen rule for Bazel."""

def _expand_make_variables(string, ctx):
    """Replace make variables in a string with their values.

    Args:
        string: The string to expand.
        ctx: The context object.
    """
    if "$(" in string:
        for variable, value in ctx.var.items():
            string = string.replace("$(%s)" % variable, value)
    return string

TransitiveSourcesInfo = provider(
    "A provider to collect source files transitively from the target and its dependencies",
    fields = {"srcs": "depset of source files collected from the target and its dependencies"},
)

def _collect_files_aspect_impl(_, ctx):
    """Collect transitive source files from dependencies.

    Args:
        _: target context. Not used in this aspect
        ctx: aspect context

    Returns:
         TransitiveSourcesInfo with a depset of transitive sources
    """
    direct_files = []
    srcs = ctx.rule.attr.srcs if hasattr(ctx.rule.attr, "srcs") else []
    hdrs = ctx.rule.attr.hdrs if hasattr(ctx.rule.attr, "hdrs") else []
    data = ctx.rule.attr.data if hasattr(ctx.rule.attr, "data") else []
    for src in srcs + hdrs + data:
        if hasattr(src, "files"):
            direct_files.extend(src.files.to_list())

    # Collect transitive files from dependencies
    transitive_files = []
    for dep in ctx.rule.attr.deps if hasattr(ctx.rule.attr, "deps") else []:
        if TransitiveSourcesInfo in dep:
            transitive_files.append(dep[TransitiveSourcesInfo].srcs)

    return [TransitiveSourcesInfo(
        srcs = depset(direct = direct_files, transitive = transitive_files),
    )]

collect_files_aspect = aspect(
    implementation = _collect_files_aspect_impl,
    attr_aspects = ["deps"],  # recursively apply on deps
    doc = "When applied to a target, this aspect collects the source files from the target and its dependencies, and makes them available in the TransitiveSourcesInfo provider.",
)

def _doxygen_impl(ctx):
    doxyfile = ctx.actions.declare_file("Doxyfile")

    output_group_info = {}
    outs = []
    for out in ctx.attr.outs:
        output_dir = ctx.actions.declare_directory(out)
        outs.append(output_dir)
        output_group_info |= {out: depset([output_dir])}

    configurations = [_expand_make_variables(conf, ctx) for conf in ctx.attr.configurations]

    if len(outs) == 0:
        fail("At least one output folder must be specified")

    deps = depset(transitive = [dep[TransitiveSourcesInfo].srcs for dep in ctx.attr.deps]).to_list()
    input_dirs = {(file.dirname or "."): None for file in ctx.files.srcs + deps}
    ctx.actions.expand_template(
        template = ctx.file.doxyfile_template,
        output = doxyfile,
        substitutions = {
            "# {{INPUT}}": "INPUT = %s" % " ".join(input_dirs.keys()),
            "# {{DOT_PATH}}": ("DOT_PATH = %s" % ctx.executable.dot_executable.dirname) if ctx.executable.dot_executable else "",
            "# {{ADDITIONAL PARAMETERS}}": "\n".join(configurations),
            "# {{OUTPUT DIRECTORY}}": "OUTPUT_DIRECTORY = %s" % doxyfile.dirname,
        },
    )

    ctx.actions.run(
        inputs = ctx.files.srcs + deps + [doxyfile],
        outputs = outs,
        arguments = [doxyfile.path] + ctx.attr.doxygen_extra_args,
        progress_message = "Running doxygen",
        executable = ctx.executable._executable,
    )

    return [
        DefaultInfo(files = depset(outs)),
        OutputGroupInfo(**output_group_info),
    ]

_doxygen = rule(
    doc = """Run the doxygen binary to generate the documentation.

It is advised to use the `doxygen` macro instead of this rule directly.

### Example

```bzl
# MODULE.bazel file
bazel_dep(name = "rules_doxygen", dev_dependency = True)
doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")
use_repo(doxygen_extension, "doxygen")
```

```bzl
# BUILD.bazel file
load("@doxygen//:doxygen.bzl", "doxygen")

doxygen(
    name = "doxygen",
    srcs = glob([
        "*.h",
        "*.cpp",
    ]),
    project_brief = "Example project for doxygen",
    project_name = "example",
)
```
""",
    implementation = _doxygen_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, doc = "List of source files to generate documentation for. Can include any file that Doxygen can parse, as well as targets that return a DefaultInfo provider (usually genrules). Since we are only considering the outputs files and not the sources, these targets **will** be built if necessary."),
        "deps": attr.label_list(aspects = [collect_files_aspect], doc = "List of dependencies targets whose files present in the 'src', 'hdrs' and 'data' attributes will be collected to generate the documentation. Transitive dependencies are also taken into account. Since we are only considering the source files and not the outputs, these targets **will not** be built"),
        "configurations": attr.string_list(doc = "Additional configuration parameters to append to the Doxyfile. For example, to set the project name, use `PROJECT_NAME = example`."),
        "outs": attr.string_list(default = ["html"], allow_empty = False, doc = """Output folders to keep. If only the html outputs is of interest, the default value will do. Otherwise, a list of folders to keep is expected (e.g. `["html", "latex"]`)."""),
        "doxyfile_template": attr.label(
            allow_single_file = True,
            default = Label(":Doxyfile.template"),
            doc = """Template file to use to generate the Doxyfile. You can provide your own or use the default one.
The following substitutions are available:
- `# {{INPUT}}`: Subpackage directory in the sandbox.
- `# {{DOT_PATH}}`: Indicate to doxygen the location of the `dot_executable`
- `# {{ADDITIONAL PARAMETERS}}`: Additional parameters given in the `configurations` attribute.
- `# {{OUTPUT DIRECTORY}}`: The directory provided in the `outs` attribute.
""",
        ),
        "dot_executable": attr.label(
            executable = True,
            cfg = "exec",
            allow_single_file = True,
            doc = "dot executable to use. Must refer to an executable file.",
        ),
        "doxygen_extra_args": attr.string_list(default = [], doc = "Extra arguments to pass to the doxygen executable."),
        "_executable": attr.label(
            executable = True,
            cfg = "exec",
            allow_single_file = True,
            default = Label(":executable"),
            doc = "doxygen executable to use. Must refer to an executable file.",
        ),
    },
)

def _add_generic_configuration(configurations, name, value):
    if value == None:  # Do not add the configuration if the value is None
        return
    if type(value) == type(True):  # Convert the boolean to a string
        value = "YES" if value else "NO"
    if type(value) == type([]):  # Convert the list to a string, but ignore empty lists
        if len(value) == 0:
            return
        value = '"%s"' % '" "'.join(value)
    configurations.append("%s = %s" % (name, value))

def doxygen(
        name,
        srcs = [],
        deps = [],
        # Bazel specific attributes
        dot_executable = None,
        configurations = None,
        doxyfile_template = None,
        doxygen_extra_args = [],
        outs = ["html"],
        # Doxygen specific attributes
        doxyfile_encoding = None,
        project_name = None,
        project_number = None,
        project_brief = None,
        project_logo = None,
        project_icon = None,
        create_subdirs = None,
        create_subdirs_level = None,
        allow_unicode_names = None,
        output_language = None,
        brief_member_desc = None,
        repeat_brief = None,
        abbreviate_brief = None,
        always_detailed_sec = None,
        inline_inherited_memb = None,
        full_path_names = None,
        strip_from_path = None,
        strip_from_inc_path = None,
        short_names = None,
        javadoc_autobrief = None,
        javadoc_banner = None,
        qt_autobrief = None,
        multiline_cpp_is_brief = None,
        python_docstring = None,
        inherit_docs = None,
        separate_member_pages = None,
        tab_size = None,
        aliases = None,
        optimize_output_for_c = None,
        optimize_output_java = None,
        optimize_for_fortran = None,
        optimize_output_vhdl = None,
        optimize_output_slice = None,
        extension_mapping = None,
        markdown_support = None,
        toc_include_headings = None,
        markdown_id_style = None,
        autolink_support = None,
        autolink_ignore_words = None,
        builtin_stl_support = None,
        cpp_cli_support = None,
        sip_support = None,
        idl_property_support = None,
        distribute_group_doc = None,
        group_nested_compounds = None,
        subgrouping = None,
        inline_grouped_classes = None,
        inline_simple_structs = None,
        typedef_hides_struct = None,
        lookup_cache_size = None,
        num_proc_threads = None,
        timestamp = None,
        extract_all = None,
        extract_private = None,
        extract_priv_virtual = None,
        extract_package = None,
        extract_static = None,
        extract_local_classes = None,
        extract_local_methods = None,
        extract_anon_nspaces = None,
        resolve_unnamed_params = None,
        hide_undoc_members = None,
        hide_undoc_classes = None,
        hide_undoc_namespaces = None,
        hide_friend_compounds = None,
        hide_in_body_docs = None,
        internal_docs = None,
        case_sense_names = None,
        hide_scope_names = None,
        hide_compound_reference = None,
        show_headerfile = None,
        show_include_files = None,
        show_grouped_memb_inc = None,
        force_local_includes = None,
        inline_info = None,
        sort_member_docs = None,
        sort_brief_docs = None,
        sort_members_ctors_1st = None,
        sort_group_names = None,
        sort_by_scope_name = None,
        strict_proto_matching = None,
        generate_todolist = None,
        generate_testlist = None,
        generate_buglist = None,
        generate_deprecatedlist = None,
        enabled_sections = None,
        max_initializer_lines = None,
        show_used_files = None,
        show_files = None,
        show_namespaces = None,
        file_version_filter = None,
        layout_file = None,
        cite_bib_files = None,
        external_tool_path = None,
        quiet = None,
        warnings = None,
        warn_if_undocumented = None,
        warn_if_doc_error = None,
        warn_if_incomplete_doc = None,
        warn_no_paramdoc = None,
        warn_if_undoc_enum_val = None,
        warn_layout_file = None,
        warn_as_error = None,
        warn_format = None,
        warn_line_format = None,
        warn_logfile = None,
        input = None,
        input_encoding = None,
        input_file_encoding = None,
        file_patterns = None,
        recursive = None,
        exclude = None,
        exclude_symlinks = None,
        exclude_patterns = None,
        exclude_symbols = None,
        example_path = None,
        example_patterns = None,
        example_recursive = None,
        image_path = None,
        input_filter = None,
        filter_patterns = None,
        filter_source_files = None,
        filter_source_patterns = None,
        use_mdfile_as_mainpage = None,
        implicit_dir_docs = None,
        fortran_comment_after = None,
        source_browser = None,
        inline_sources = None,
        strip_code_comments = None,
        referenced_by_relation = None,
        references_relation = None,
        references_link_source = None,
        source_tooltips = None,
        use_htags = None,
        verbatim_headers = None,
        clang_assisted_parsing = None,
        clang_add_inc_paths = None,
        clang_options = None,
        clang_database_path = None,
        alphabetical_index = None,
        ignore_prefix = None,
        generate_html = None,
        html_output = None,
        html_file_extension = None,
        html_header = None,
        html_footer = None,
        html_stylesheet = None,
        html_extra_stylesheet = None,
        html_extra_files = None,
        html_colorstyle = None,
        html_colorstyle_hue = None,
        html_colorstyle_sat = None,
        html_colorstyle_gamma = None,
        html_dynamic_menus = None,
        html_dynamic_sections = None,
        html_code_folding = None,
        html_copy_clipboard = None,
        html_project_cookie = None,
        html_index_num_entries = None,
        generate_docset = None,
        docset_feedname = None,
        docset_feedurl = None,
        docset_bundle_id = None,
        docset_publisher_id = None,
        docset_publisher_name = None,
        generate_htmlhelp = None,
        chm_file = None,
        hhc_location = None,
        generate_chi = None,
        chm_index_encoding = None,
        binary_toc = None,
        toc_expand = None,
        sitemap_url = None,
        generate_qhp = None,
        qch_file = None,
        qhp_namespace = None,
        qhp_virtual_folder = None,
        qhp_cust_filter_name = None,
        qhp_cust_filter_attrs = None,
        qhp_sect_filter_attrs = None,
        qhg_location = None,
        generate_eclipsehelp = None,
        eclipse_doc_id = None,
        disable_index = None,
        generate_treeview = None,
        page_outline_panel = None,
        full_sidebar = None,
        enum_values_per_line = None,
        show_enum_values = None,
        treeview_width = None,
        ext_links_in_window = None,
        obfuscate_emails = None,
        html_formula_format = None,
        formula_fontsize = None,
        formula_macrofile = None,
        use_mathjax = None,
        mathjax_version = None,
        mathjax_format = None,
        mathjax_relpath = None,
        mathjax_extensions = None,
        mathjax_codefile = None,
        searchengine = None,
        server_based_search = None,
        external_search = None,
        searchengine_url = None,
        searchdata_file = None,
        external_search_id = None,
        extra_search_mappings = None,
        generate_latex = None,
        latex_output = None,
        latex_cmd_name = None,
        makeindex_cmd_name = None,
        latex_makeindex_cmd = None,
        compact_latex = None,
        paper_type = None,
        extra_packages = None,
        latex_header = None,
        latex_footer = None,
        latex_extra_stylesheet = None,
        latex_extra_files = None,
        pdf_hyperlinks = None,
        use_pdflatex = None,
        latex_batchmode = None,
        latex_hide_indices = None,
        latex_bib_style = None,
        latex_emoji_directory = None,
        generate_rtf = None,
        rtf_output = None,
        compact_rtf = None,
        rtf_hyperlinks = None,
        rtf_stylesheet_file = None,
        rtf_extensions_file = None,
        rtf_extra_files = None,
        generate_man = None,
        man_output = None,
        man_extension = None,
        man_subdir = None,
        man_links = None,
        generate_xml = None,
        xml_output = None,
        xml_programlisting = None,
        xml_ns_memb_file_scope = None,
        generate_docbook = None,
        docbook_output = None,
        generate_autogen_def = None,
        generate_sqlite3 = None,
        sqlite3_output = None,
        sqlite3_recreate_db = None,
        generate_perlmod = None,
        perlmod_latex = None,
        perlmod_pretty = None,
        perlmod_makevar_prefix = None,
        enable_preprocessing = None,
        macro_expansion = None,
        expand_only_predef = None,
        search_includes = None,
        include_path = None,
        include_file_patterns = None,
        predefined = None,
        expand_as_defined = None,
        skip_function_macros = None,
        tagfiles = None,
        generate_tagfile = None,
        allexternals = None,
        external_groups = None,
        external_pages = None,
        hide_undoc_relations = None,
        have_dot = None,
        dot_num_threads = None,
        dot_common_attr = None,
        dot_edge_attr = None,
        dot_node_attr = None,
        dot_fontpath = None,
        dot_transparent = None,
        class_graph = None,
        collaboration_graph = None,
        group_graphs = None,
        uml_look = None,
        uml_limit_num_fields = None,
        uml_max_edge_labels = None,
        dot_uml_details = None,
        dot_wrap_threshold = None,
        template_relations = None,
        include_graph = None,
        included_by_graph = None,
        call_graph = None,
        caller_graph = None,
        graphical_hierarchy = None,
        directory_graph = None,
        dir_graph_max_depth = None,
        dot_image_format = None,
        interactive_svg = None,
        dot_path = None,
        dotfile_dirs = None,
        dia_path = None,
        diafile_dirs = None,
        plantuml_jar_path = None,
        plantuml_cfg_file = None,
        plantuml_include_path = None,
        plantumlfile_dirs = None,
        dot_graph_max_nodes = None,
        max_dot_graph_depth = None,
        dot_multi_targets = None,
        generate_legend = None,
        dot_cleanup = None,
        mscgen_tool = None,
        mscfile_dirs = None,
        **kwargs):
    """
    Generates documentation using Doxygen.

    The set of attributes the macro provides is a subset of the Doxygen configuration options.
    Depending on the type of the attribute, the macro will convert it to the appropriate string:

    - None (default): the attribute will not be included in the Doxyfile
    - bool: the value of the attribute is the string "YES" or "NO" respectively
    - list: the value of the attribute is a string with the elements separated by spaces and enclosed in double quotes
    - str: the value of the attribute is will be set to the string, unchanged. You may need to provide proper quoting if the value contains spaces

    For the complete list of Doxygen configuration options, please refer to the [Doxygen documentation](https://www.doxygen.nl/manual/config.html).

    ### Differences between `srcs` and `deps`

    The `srcs` and `deps` attributes work differently and are not interchangeable.

    `srcs` is a list of files that will be passed to Doxygen for documentation generation.
    You can use `glob` to include a collection of multiple files.
    On the other hand, if you indicate a target (e.g., `:my_genrule`), it will include all the files produced by that target.
    More precisely, the files in the DefaultInfo provider the target returns.
    Hence, when the documentation is generated, all rules in the `srcs` attribute **will** be built, and the files they output will be passed to Doxygen.

    On the other hand, `deps` is a list of targets whose sources will be included in the documentation generation.
    It will automatically include all the files in the `srcs`, `hdrs`, and `data` attributes of the target, and the same applies to all of its transitive dependencies, recursively.
    Since we are only interested in the source files, the `deps` targets **will not** be built when the documentation is generated.

    ```bzl
    # My BUILD.bazel file
    load("@doxygen//:doxygen.bzl", "doxygen")
    load("@rules_cc//cc:defs.bzl", "cc_library")

    cc_library(
        name = "lib",
        hdrs = ["add.h", "sub.h"],
        srcs = ["add.cpp", "sub.cpp"],
    )

    cc_library(
        name = "main",
        srcs = ["main.cpp"],
        deps = [":lib"],
    )


    genrule(
        name = "section",
        outs = ["Section.md"],
        cmd = \"\"\"
            echo "# Section " > $@
            echo "This is some amazing documentation with section!!  " >> $@
            echo "Incredible." >> $@
        \"\"\",
    )

    doxygen(
        name = "doxygen",
        project_name = "dependencies",

        # The output of the genrule will be included in the documentation.
        # The genrule will be executed when the documentation is generated.
        srcs = [
            "README.md",  # file
            ":section",  # genrule

            # WARNING: By adding this, the main target will be built
            # and only the output files `libmain.so` and `libmain.a`
            # will be passed to Doxygen, which is likely not what you want.
            # ":main"
        ],

        # The sources of the main target and its dependencies will be included.
        # No compilation will be performed, so compile error won't be reported.
        deps = [":main"],  # cc_library

        # Always starts at the root folder
        use_mdfile_as_mainpage = "dependencies/README.md",
    )
    ```

    ### Example

    ```bzl
    # MODULE.bazel file
    bazel_dep(name = "rules_doxygen", dev_dependency = True)
    doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")
    use_repo(doxygen_extension, "doxygen")
    ```

    ```bzl
    # BUILD.bazel file
    load("@doxygen//:doxygen.bzl", "doxygen")
    load("@rules_cc//cc:defs.bzl", "cc_library")

    cc_library(
        name = "lib",
        srcs = ["add.cpp", "sub.cpp"],
        hdrs = ["add.h", "sub.h"],
    )

    cc_library(
        name = "main",
        srcs = ["main.cpp"],
        deps = [":lib"],
    )

    doxygen(
        name = "doxygen",
        srcs = glob([
            "*.md",
        ]),
        deps = [":main"]
        aliases = [
            "licence=@par Licence:^^",
            "verb{1}=@verbatim \\\\1 @endverbatim",
        ],
        optimize_output_for_c = True,
        project_brief = "Example project for doxygen",
        project_name = "example",
    )
    ```

    Args:
        name: Name for the target.
        srcs: List of source files to generate documentation for.
            Can include any file that Doxygen can parse, as well as targets that return a DefaultInfo provider (usually genrules).
            Since we are only considering the outputs files and not the sources, these targets **will** be built if necessary.
        deps: List of dependencies targets whose files present in the 'src', 'hdrs' and 'data' attributes will be collected to generate the documentation.
            Transitive dependencies are also taken into account.
            Since we are only considering the source files and not the outputs, these targets **will not** be built.
        dot_executable: Label of the doxygen executable. Make sure it is also added to the `srcs` of the macro
        configurations: List of additional configuration parameters to pass to Doxygen.
        doxyfile_template: The template file to use to generate the Doxyfile.
            The following substitutions are available:<br>
            - `# {{INPUT}}`: Subpackage directory in the sandbox.<br>
            - `# {{ADDITIONAL PARAMETERS}}`: Additional parameters given in the `configurations` attribute.<br>
            - `# {{OUTPUT DIRECTORY}}`: The directory provided in the `outs` attribute.
        doxygen_extra_args: Extra arguments to pass to the doxygen executable.
        outs: Output folders bazel will keep. If only the html outputs is of interest, the default value will do.
             otherwise, a list of folders to keep is expected (e.g. ["html", "latex"]).
             Note that the rule will also generate an output group for each folder in the outs list having the same name.

        doxyfile_encoding: This tag specifies the encoding used for all characters in the configuration file that follow.
        project_name: The `project_name` tag is a single word (or a sequence of words surrounded by double-quotes, unless you are using Doxywizard) that should identify the project for which the documentation is generated.
        project_number: The `project_number` tag can be used to enter a project or revision number.
        project_brief: Using the `project_brief` tag one can provide an optional one line description for a project that appears at the top of each page and should give viewer a quick idea about the purpose of the project.
        project_logo: With the `project_logo` tag one can specify a logo or an icon that is included in the documentation.
        project_icon: With the `project_icon` tag one can specify an icon that is included in the tabs when the HTML document is shown.
        create_subdirs: If the `create_subdirs` tag is set to `True` then Doxygen will create up to 4096 sub-directories (in 2 levels) under the output directory of each output format and will distribute the generated files over these directories.
        create_subdirs_level: Controls the number of sub-directories that will be created when `create_subdirs` tag is set to `True`.
        allow_unicode_names: If the `allow_unicode_names` tag is set to `True`, Doxygen will allow non-ASCII characters to appear in the names of generated files.
        output_language: The `output_language` tag is used to specify the language in which all documentation generated by Doxygen is written.
        brief_member_desc: If the `brief_member_desc` tag is set to `True`, Doxygen will include brief member descriptions after the members that are listed in the file and class documentation (similar to Javadoc).
        repeat_brief: If the `repeat_brief` tag is set to `True`, Doxygen will prepend the brief description of a member or function before the detailed description Note: If both `hide_undoc_members` and `brief_member_desc` are set to `False`, the brief descriptions will be completely suppressed.
        abbreviate_brief: This tag implements a quasi-intelligent brief description abbreviator that is used to form the text in various listings.
        always_detailed_sec: If the `always_detailed_sec` and `repeat_brief` tags are both set to `True` then Doxygen will generate a detailed section even if there is only a brief description.
        inline_inherited_memb: If the `inline_inherited_memb` tag is set to `True`, Doxygen will show all inherited members of a class in the documentation of that class as if those members were ordinary class members.
        full_path_names: If the `full_path_names` tag is set to `True`, Doxygen will prepend the full path before files name in the file list and in the header files.
        strip_from_path: The `strip_from_path` tag can be used to strip a user-defined part of the path.
        strip_from_inc_path: The `strip_from_inc_path` tag can be used to strip a user-defined part of the path mentioned in the documentation of a class, which tells the reader which header file to include in order to use a class.
        short_names: If the `short_names` tag is set to `True`, Doxygen will generate much shorter (but less readable) file names.
        javadoc_autobrief: If the `javadoc_autobrief` tag is set to `True` then Doxygen will interpret the first line (until the first dot) of a Javadoc-style comment as the brief description.
        javadoc_banner: If the `javadoc_banner` tag is set to `True` then Doxygen will interpret a line such as /*************** as being the beginning of a Javadoc-style comment "banner".
        qt_autobrief: If the `qt_autobrief` tag is set to `True` then Doxygen will interpret the first line (until the first dot) of a Qt-style comment as the brief description.
        multiline_cpp_is_brief: The `multiline_cpp_is_brief` tag can be set to `True` to make Doxygen treat a multi-line C++ special comment block (i.e. a block of //! or /// comments) as a brief description.
        python_docstring: By default Python docstrings are displayed as preformatted text and Doxygen's special commands cannot be used.
        inherit_docs: If the `inherit_docs` tag is set to `True` then an undocumented member inherits the documentation from any documented member that it re-implements.
        separate_member_pages: If the `separate_member_pages` tag is set to `True` then Doxygen will produce a new page for each member.
        tab_size: The `tab_size` tag can be used to set the number of spaces in a tab.
        aliases: This tag can be used to specify a number of aliases that act as commands in the documentation.
        optimize_output_for_c: Set the `optimize_output_for_c` tag to `True` if your project consists of C sources only.
        optimize_output_java: Set the `optimize_output_java` tag to `True` if your project consists of Java or Python sources only.
        optimize_for_fortran: Set the `optimize_for_fortran` tag to `True` if your project consists of Fortran sources.
        optimize_output_vhdl: Set the `optimize_output_vhdl` tag to `True` if your project consists of VHDL sources.
        optimize_output_slice: Set the `optimize_output_slice` tag to `True` if your project consists of Slice sources only.
        extension_mapping: Doxygen selects the parser to use depending on the extension of the files it parses.
        markdown_support: If the `markdown_support` tag is enabled then Doxygen pre-processes all comments according to the Markdown format, which allows for more readable documentation.
        toc_include_headings: When the `toc_include_headings` tag is set to a non-zero value, all headings up to that level are automatically included in the table of contents, even if they do not have an id attribute.
        markdown_id_style: The `markdown_id_style` tag can be used to specify the algorithm used to generate identifiers for the Markdown headings.
        autolink_support: When enabled Doxygen tries to link words that correspond to documented classes, or namespaces to their corresponding documentation.
        autolink_ignore_words: This tag specifies a list of words that, when matching the start of a word in the documentation, will suppress auto links generation, if it is enabled via autolink_support.
        builtin_stl_support: If you use STL classes (i.e. std::string, std::vector, etc.) but do not want to include (a tag file for) the STL sources as input, then you should set this tag to `True` in order to let Doxygen match functions declarations and definitions whose arguments contain STL classes (e.g. func(std::string); versus func(std::string) {}).
        cpp_cli_support: If you use Microsoft's C++/CLI language, you should set this option to `True` to enable parsing support.
        sip_support: Set the `sip_support` tag to `True` if your project consists of sip (see: https://www.riverbankcomputing.com/software) sources only.
        idl_property_support: For Microsoft's IDL there are propget and propput attributes to indicate getter and setter methods for a property.
        distribute_group_doc: If member grouping is used in the documentation and the `distribute_group_doc` tag is set to `True` then Doxygen will reuse the documentation of the first member in the group (if any) for the other members of the group.
        group_nested_compounds: If one adds a struct or class to a group and this option is enabled, then also any nested class or struct is added to the same group.
        subgrouping: Set the `subgrouping` tag to `True` to allow class member groups of the same type (for instance a group of public functions) to be put as a subgroup of that type (e.g. under the Public Functions section).
        inline_grouped_classes: When the `inline_grouped_classes` tag is set to `True`, classes, structs and unions are shown inside the group in which they are included (e.g. using \\ingroup) instead of on a separate page (for HTML and Man pages) or section (for LaTeX and RTF).
        inline_simple_structs: When the `inline_simple_structs` tag is set to `True`, structs, classes, and unions with only public data fields or simple typedef fields will be shown inline in the documentation of the scope in which they are defined (i.e. file, namespace, or group documentation), provided this scope is documented.
        typedef_hides_struct: When `typedef_hides_struct` tag is enabled, a typedef of a struct, union, or enum is documented as struct, union, or enum with the name of the typedef.
        lookup_cache_size: The size of the symbol lookup cache can be set using `lookup_cache_size`.
        num_proc_threads: The `num_proc_threads` specifies the number of threads Doxygen is allowed to use during processing.
        timestamp: If the `timestamp` tag is set different from `False` then each generated page will contain the date or date and time when the page was generated.
        extract_all: If the `extract_all` tag is set to `True`, Doxygen will assume all entities in documentation are documented, even if no documentation was available.
        extract_private: If the `extract_private` tag is set to `True`, all private members of a class will be included in the documentation.
        extract_priv_virtual: If the `extract_priv_virtual` tag is set to `True`, documented private virtual methods of a class will be included in the documentation.
        extract_package: If the `extract_package` tag is set to `True`, all members with package or internal scope will be included in the documentation.
        extract_static: If the `extract_static` tag is set to `True`, all static members of a file will be included in the documentation.
        extract_local_classes: If the `extract_local_classes` tag is set to `True`, classes (and structs) defined locally in source files will be included in the documentation.
        extract_local_methods: This flag is only useful for Objective-C code.
        extract_anon_nspaces: If this flag is set to `True`, the members of anonymous namespaces will be extracted and appear in the documentation as a namespace called 'anonymous_namespace{file}', where file will be replaced with the base name of the file that contains the anonymous namespace.
        resolve_unnamed_params: If this flag is set to `True`, the name of an unnamed parameter in a declaration will be determined by the corresponding definition.
        hide_undoc_members: If the `hide_undoc_members` tag is set to `True`, Doxygen will hide all undocumented members inside documented classes or files.
        hide_undoc_classes: If the `hide_undoc_classes` tag is set to `True`, Doxygen will hide all undocumented classes that are normally visible in the class hierarchy.
        hide_undoc_namespaces: If the hide_undoc_namespaces tag is set to YES, Doxygen will hide all undocumented namespaces that are normally visible in the namespace hierarchy.
        hide_friend_compounds: If the `hide_friend_compounds` tag is set to `True`, Doxygen will hide all friend declarations.
        hide_in_body_docs: If the `hide_in_body_docs` tag is set to `True`, Doxygen will hide any documentation blocks found inside the body of a function.
        internal_docs: The `internal_docs` tag determines if documentation that is typed after a \\internal command is included.
        case_sense_names: With the correct setting of option `case_sense_names` Doxygen will better be able to match the capabilities of the underlying filesystem.
        hide_scope_names: If the `hide_scope_names` tag is set to `False` then Doxygen will show members with their full class and namespace scopes in the documentation.
        hide_compound_reference: If the `hide_compound_reference` tag is set to `False` (default) then Doxygen will append additional text to a page's title, such as Class Reference.
        show_headerfile: If the `show_headerfile` tag is set to `True` then the documentation for a class will show which file needs to be included to use the class.
        show_include_files: If the `show_include_files` tag is set to `True` then Doxygen will put a list of the files that are included by a file in the documentation of that file.
        show_grouped_memb_inc: If the `show_grouped_memb_inc` tag is set to `True` then Doxygen will add for each grouped member an include statement to the documentation, telling the reader which file to include in order to use the member.
        force_local_includes: If the `force_local_includes` tag is set to `True` then Doxygen will list include files with double quotes in the documentation rather than with sharp brackets.
        inline_info: If the `inline_info` tag is set to `True` then a tag [inline] is inserted in the documentation for inline members.
        sort_member_docs: If the `sort_member_docs` tag is set to `True` then Doxygen will sort the (detailed) documentation of file and class members alphabetically by member name.
        sort_brief_docs: If the `sort_brief_docs` tag is set to `True` then Doxygen will sort the brief descriptions of file, namespace and class members alphabetically by member name.
        sort_members_ctors_1st: If the `sort_members_ctors_1st` tag is set to `True` then Doxygen will sort the (brief and detailed) documentation of class members so that constructors and destructors are listed first.
        sort_group_names: If the `sort_group_names` tag is set to `True` then Doxygen will sort the hierarchy of group names into alphabetical order.
        sort_by_scope_name: If the `sort_by_scope_name` tag is set to `True`, the class list will be sorted by fully-qualified names, including namespaces.
        strict_proto_matching: If the `strict_proto_matching` option is enabled and Doxygen fails to do proper type resolution of all parameters of a function it will reject a match between the prototype and the implementation of a member function even if there is only one candidate or it is obvious which candidate to choose by doing a simple string match.
        generate_todolist: The `generate_todolist` tag can be used to enable (YES) or disable (NO) the todo list.
        generate_testlist: The `generate_testlist` tag can be used to enable (YES) or disable (NO) the test list.
        generate_buglist: The `generate_buglist` tag can be used to enable (YES) or disable (NO) the bug list.
        generate_deprecatedlist: The `generate_deprecatedlist` tag can be used to enable (YES) or disable (NO) the deprecated list.
        enabled_sections: The `enabled_sections` tag can be used to enable conditional documentation sections, marked by \\if <section_label> ... \\endif and \\cond <section_label> ... \\endcond blocks.
        max_initializer_lines: The `max_initializer_lines` tag determines the maximum number of lines that the initial value of a variable or macro / define can have for it to appear in the documentation.
        show_used_files: Set the `show_used_files` tag to `False` to disable the list of files generated at the bottom of the documentation of classes and structs.
        show_files: Set the `show_files` tag to `False` to disable the generation of the Files page.
        show_namespaces: Set the `show_namespaces` tag to `False` to disable the generation of the Namespaces page.
        file_version_filter: The `file_version_filter` tag can be used to specify a program or script that Doxygen should invoke to get the current version for each file (typically from the version control system).
        layout_file: The `layout_file` tag can be used to specify a layout file which will be parsed by Doxygen.
        cite_bib_files: The `cite_bib_files` tag can be used to specify one or more bib files containing the reference definitions.
        external_tool_path: The `external_tool_path` tag can be used to extend the search path (PATH environment variable) so that external tools such as latex and gs can be found.
        quiet: The `quiet` tag can be used to turn on/off the messages that are generated to standard output by Doxygen.
        warnings: The `warnings` tag can be used to turn on/off the warning messages that are generated to standard error (stderr) by Doxygen.
        warn_if_undocumented: If the `warn_if_undocumented` tag is set to `True` then Doxygen will generate warnings for undocumented members.
        warn_if_doc_error: If the `warn_if_doc_error` tag is set to `True`, Doxygen will generate warnings for potential errors in the documentation, such as documenting some parameters in a documented function twice, or documenting parameters that don't exist or using markup commands wrongly.
        warn_if_incomplete_doc: If `warn_if_incomplete_doc` is set to `True`, Doxygen will warn about incomplete function parameter documentation.
        warn_no_paramdoc: This `warn_no_paramdoc` option can be enabled to get warnings for functions that are documented, but have no documentation for their parameters or return value.
        warn_if_undoc_enum_val: If `warn_if_undoc_enum_val` option is set to `True`, Doxygen will warn about undocumented enumeration values.
        warn_layout_file: If warn_layout_file option is set to `True`, Doxygen will warn about issues found while parsing the user defined layout file, such as missing or wrong elements
        warn_as_error: If the `warn_as_error` tag is set to `True` then Doxygen will immediately stop when a warning is encountered.
        warn_format: The `warn_format` tag determines the format of the warning messages that Doxygen can produce.
        warn_line_format: In the $text part of the `warn_format` command it is possible that a reference to a more specific place is given.
        warn_logfile: The `warn_logfile` tag can be used to specify a file to which warning and error messages should be written.
        input: The `input` tag is used to specify the files and/or directories that contain documented source files.
        input_encoding: This tag can be used to specify the character encoding of the source files that Doxygen parses.
        input_file_encoding: This tag can be used to specify the character encoding of the source files that Doxygen parses The `input_file_encoding` tag can be used to specify character encoding on a per file pattern basis.
        file_patterns: If the value of the `input` tag contains directories, you can use the `file_patterns` tag to specify one or more wildcard patterns (like *.cpp and *.h) to filter out the source-files in the directories.
        recursive: The `recursive` tag can be used to specify whether or not subdirectories should be searched for input files as well.
        exclude: The `exclude` tag can be used to specify files and/or directories that should be excluded from the `input` source files.
        exclude_symlinks: The `exclude_symlinks` tag can be used to select whether or not files or directories that are symbolic links (a Unix file system feature) are excluded from the input.
        exclude_patterns: If the value of the `input` tag contains directories, you can use the `exclude_patterns` tag to specify one or more wildcard patterns to exclude certain files from those directories.
        exclude_symbols: The `exclude_symbols` tag can be used to specify one or more symbol names (namespaces, classes, functions, etc.) that should be excluded from the output.
        example_path: The `example_path` tag can be used to specify one or more files or directories that contain example code fragments that are included (see the \\include command).
        example_patterns: If the value of the `example_path` tag contains directories, you can use the `example_patterns` tag to specify one or more wildcard pattern (like *.cpp and *.h) to filter out the source-files in the directories.
        example_recursive: If the `example_recursive` tag is set to `True` then subdirectories will be searched for input files to be used with the \\include or \\dontinclude commands irrespective of the value of the `recursive` tag.
        image_path: The `image_path` tag can be used to specify one or more files or directories that contain images that are to be included in the documentation (see the \\image command).
        input_filter: The `input_filter` tag can be used to specify a program that Doxygen should invoke to filter for each input file.
        filter_patterns: The `filter_patterns` tag can be used to specify filters on a per file pattern basis.
        filter_source_files: If the `filter_source_files` tag is set to `True`, the input filter (if set using `input_filter`) will also be used to filter the input files that are used for producing the source files to browse (i.e. when `source_browser` is set to `True`).
        filter_source_patterns: The `filter_source_patterns` tag can be used to specify source filters per file pattern.
        use_mdfile_as_mainpage: If the `use_mdfile_as_mainpage` tag refers to the name of a markdown file that is part of the input, its contents will be placed on the main page (index.html).
        implicit_dir_docs: If the implicit_dir_docs tag is set to `True`, any README.md file found in subdirectories of the project's root, is used as the documentation for that subdirectory, except when the README.md starts with a \\dir, \\page or \\mainpage command.
        fortran_comment_after: The Fortran standard specifies that for fixed formatted Fortran code all characters from position 72 are to be considered as comment.
        source_browser: If the `source_browser` tag is set to `True` then a list of source files will be generated.
        inline_sources: Setting the `inline_sources` tag to `True` will include the body of functions, multi-line macros, enums or list initialized variables directly into the documentation.
        strip_code_comments: Setting the `strip_code_comments` tag to `True` will instruct Doxygen to hide any special comment blocks from generated source code fragments.
        referenced_by_relation: If the `referenced_by_relation` tag is set to `True` then for each documented entity all documented functions referencing it will be listed.
        references_relation: If the `references_relation` tag is set to `True` then for each documented function all documented entities called/used by that function will be listed.
        references_link_source: If the `references_link_source` tag is set to `True` and `source_browser` tag is set to `True` then the hyperlinks from functions in `references_relation` and `referenced_by_relation` lists will link to the source code.
        source_tooltips: If `source_tooltips` is enabled (the default) then hovering a hyperlink in the source code will show a tooltip with additional information such as prototype, brief description and links to the definition and documentation.
        use_htags: If the `use_htags` tag is set to `True` then the references to source code will point to the HTML generated by the htags(1) tool instead of Doxygen built-in source browser.
        verbatim_headers: If the `verbatim_headers` tag is set the `True` then Doxygen will generate a verbatim copy of the header file for each class for which an include is specified.
        clang_assisted_parsing: If the `clang_assisted_parsing` tag is set to `True` then Doxygen will use the clang parser (see: http://clang.llvm.org/) for more accurate parsing at the cost of reduced performance.
        clang_add_inc_paths: If the `clang_assisted_parsing` tag is set to `True` and the `clang_add_inc_paths` tag is set to `True` then Doxygen will add the directory of each input to the include path.
        clang_options: If clang assisted parsing is enabled you can provide the compiler with command line options that you would normally use when invoking the compiler.
        clang_database_path: If clang assisted parsing is enabled you can provide the clang parser with the path to the directory containing a file called compile_commands.json.
        alphabetical_index: If the `alphabetical_index` tag is set to `True`, an alphabetical index of all compounds will be generated.
        ignore_prefix: The `ignore_prefix` tag can be used to specify a prefix (or a list of prefixes) that should be ignored while generating the index headers.
        generate_html: If the `generate_html` tag is set to `True`, Doxygen will generate HTML output The default value is: `True`.
        html_output: The `html_output` tag is used to specify where the HTML docs will be put.
        html_file_extension: The `html_file_extension` tag can be used to specify the file extension for each generated HTML page (for example: .htm, .php, .asp).
        html_header: The `html_header` tag can be used to specify a user-defined HTML header file for each generated HTML page.
        html_footer: The `html_footer` tag can be used to specify a user-defined HTML footer for each generated HTML page.
        html_stylesheet: The `html_stylesheet` tag can be used to specify a user-defined cascading style sheet that is used by each HTML page.
        html_extra_stylesheet: The `html_extra_stylesheet` tag can be used to specify additional user-defined cascading style sheets that are included after the standard style sheets created by Doxygen.
        html_extra_files: The `html_extra_files` tag can be used to specify one or more extra images or other source files which should be copied to the HTML output directory.
        html_colorstyle: The `html_colorstyle` tag can be used to specify if the generated HTML output should be rendered with a dark or light theme.
        html_colorstyle_hue: The `html_colorstyle_hue` tag controls the color of the HTML output.
        html_colorstyle_sat: The `html_colorstyle_sat` tag controls the purity (or saturation) of the colors in the HTML output.
        html_colorstyle_gamma: The `html_colorstyle_gamma` tag controls the gamma correction applied to the luminance component of the colors in the HTML output.
        html_dynamic_menus: If the `html_dynamic_menus` tag is set to `True` then the generated HTML documentation will contain a main index with vertical navigation menus that are dynamically created via JavaScript.
        html_dynamic_sections: If the `html_dynamic_sections` tag is set to `True` then the generated HTML documentation will contain sections that can be hidden and shown after the page has loaded.
        html_code_folding: If the `html_code_folding` tag is set to `True` then classes and functions can be dynamically folded and expanded in the generated HTML source code.
        html_copy_clipboard: If the `html_copy_clipboard` tag is set to `True` then Doxygen will show an icon in the top right corner of code and text fragments that allows the user to copy its content to the clipboard.
        html_project_cookie: Doxygen stores a couple of settings persistently in the browser (via e.g. cookies).
        html_index_num_entries: With `html_index_num_entries` one can control the preferred number of entries shown in the various tree structured indices initially; the user can expand and collapse entries dynamically later on.
        generate_docset: If the `generate_docset` tag is set to `True`, additional index files will be generated that can be used as input for Apple's Xcode 3 integrated development environment (see: https://developer.apple.com/xcode/), introduced with OSX 10.5 (Leopard).
        docset_feedname: This tag determines the name of the docset feed.
        docset_feedurl: This tag determines the URL of the docset feed.
        docset_bundle_id: This tag specifies a string that should uniquely identify the documentation set bundle.
        docset_publisher_id: The `docset_publisher_id` tag specifies a string that should uniquely identify the documentation publisher.
        docset_publisher_name: The `docset_publisher_name` tag identifies the documentation publisher.
        generate_htmlhelp: If the `generate_htmlhelp` tag is set to `True` then Doxygen generates three additional HTML index files: index.hhp, index.hhc, and index.hhk.
        chm_file: The `chm_file` tag can be used to specify the file name of the resulting .chm file.
        hhc_location: The `hhc_location` tag can be used to specify the location (absolute path including file name) of the HTML help compiler (hhc.exe).
        generate_chi: The `generate_chi` flag controls if a separate .chi index file is generated (YES) or that it should be included in the main .chm file (NO).
        chm_index_encoding: The `chm_index_encoding` is used to encode HtmlHelp index (hhk), content (hhc) and project file content.
        binary_toc: The `binary_toc` flag controls whether a binary table of contents is generated (YES) or a normal table of contents (NO) in the .chm file.
        toc_expand: The `toc_expand` flag can be set to `True` to add extra items for group members to the table of contents of the HTML help documentation and to the tree view.
        sitemap_url: The `sitemap_url` tag is used to specify the full URL of the place where the generated documentation will be placed on the server by the user during the deployment of the documentation.
        generate_qhp: If the `generate_qhp` tag is set to `True` and both `qhp_namespace` and `qhp_virtual_folder` are set, an additional index file will be generated that can be used as input for Qt's qhelpgenerator to generate a Qt Compressed Help (.qch) of the generated HTML documentation.
        qch_file: If the `qhg_location` tag is specified, the `qch_file` tag can be used to specify the file name of the resulting .qch file.
        qhp_namespace: The `qhp_namespace` tag specifies the namespace to use when generating Qt Help Project output.
        qhp_virtual_folder: The `qhp_virtual_folder` tag specifies the namespace to use when generating Qt Help Project output.
        qhp_cust_filter_name: If the `qhp_cust_filter_name` tag is set, it specifies the name of a custom filter to add.
        qhp_cust_filter_attrs: The `qhp_cust_filter_attrs` tag specifies the list of the attributes of the custom filter to add.
        qhp_sect_filter_attrs: The `qhp_sect_filter_attrs` tag specifies the list of the attributes this project's filter section matches.
        qhg_location: The `qhg_location` tag can be used to specify the location (absolute path including file name) of Qt's qhelpgenerator.
        generate_eclipsehelp: If the `generate_eclipsehelp` tag is set to `True`, additional index files will be generated, together with the HTML files, they form an Eclipse help plugin.
        eclipse_doc_id: A unique identifier for the Eclipse help plugin.
        disable_index: If you want full control over the layout of the generated HTML pages it might be necessary to disable the index and replace it with your own.
        generate_treeview: The `generate_treeview` tag is used to specify whether a tree-like index structure should be generated to display hierarchical information.
        page_outline_panel: When `generate_treeview` is set to YES, the `page_outline_panel` option determines if an additional navigation panel is shown at the right hand side of the screen, displaying an outline of the contents of the main page, similar to e.g. https://developer.android.com/reference.
        full_sidebar: When `generate_treeview` is set to `True`, the `full_sidebar` option determines if the side bar is limited to only the treeview area (value `False`) or if it should extend to the full height of the window (value `True`).
        enum_values_per_line: The `enum_values_per_line` tag can be used to set the number of enum values that Doxygen will group on one line in the generated HTML documentation.
        show_enum_values: When the `show_enum_values` tag is set doxygen will show the specified enumeration values besides the enumeration mnemonics.
        treeview_width: If the treeview is enabled (see `generate_treeview`) then this tag can be used to set the initial width (in pixels) of the frame in which the tree is shown.
        ext_links_in_window: If the `ext_links_in_window` option is set to `True`, Doxygen will open links to external symbols imported via tag files in a separate window.
        obfuscate_emails: If the `obfuscate_emails` tag is set to `True`, Doxygen will obfuscate email addresses.
        html_formula_format: If the `html_formula_format` option is set to svg, Doxygen will use the pdf2svg tool (see https://github.com/dawbarton/pdf2svg) or inkscape (see https://inkscape.org) to generate formulas as SVG images instead of PNGs for the HTML output.
        formula_fontsize: Use this tag to change the font size of LaTeX formulas included as images in the HTML documentation.
        formula_macrofile: The `formula_macrofile` can contain LaTeX \\newcommand and \\renewcommand commands to create new LaTeX commands to be used in formulas as building blocks.
        use_mathjax: Enable the `use_mathjax` option to render LaTeX formulas using MathJax (see https://www.mathjax.org) which uses client side JavaScript for the rendering instead of using pre-rendered bitmaps.
        mathjax_version: With `mathjax_version` it is possible to specify the MathJax version to be used.
        mathjax_format: When MathJax is enabled you can set the default output format to be used for the MathJax output.
        mathjax_relpath: When MathJax is enabled you need to specify the location relative to the HTML output directory using the `mathjax_relpath` option.
        mathjax_extensions: The `mathjax_extensions` tag can be used to specify one or more MathJax extension names that should be enabled during MathJax rendering.
        mathjax_codefile: The `mathjax_codefile` tag can be used to specify a file with JavaScript pieces of code that will be used on startup of the MathJax code.
        searchengine: When the `searchengine` tag is enabled Doxygen will generate a search box for the HTML output.
        server_based_search: When the `server_based_search` tag is enabled the search engine will be implemented using a web server instead of a web client using JavaScript.
        external_search: When `external_search` tag is enabled Doxygen will no longer generate the PHP script for searching.
        searchengine_url: The `searchengine_url` should point to a search engine hosted by a web server which will return the search results when `external_search` is enabled.
        searchdata_file: When `server_based_search` and `external_search` are both enabled the unindexed search data is written to a file for indexing by an external tool.
        external_search_id: When `server_based_search` and `external_search` are both enabled the `external_search_id` tag can be used as an identifier for the project.
        extra_search_mappings: The `extra_search_mappings` tag can be used to enable searching through Doxygen projects other than the one defined by this configuration file, but that are all added to the same external search index.
        generate_latex: If the `generate_latex` tag is set to `True`, Doxygen will generate LaTeX output.
        latex_output: The `latex_output` tag is used to specify where the LaTeX docs will be put.
        latex_cmd_name: The `latex_cmd_name` tag can be used to specify the LaTeX command name to be invoked.
        makeindex_cmd_name: The `makeindex_cmd_name` tag can be used to specify the command name to generate index for LaTeX.
        latex_makeindex_cmd: The `latex_makeindex_cmd` tag can be used to specify the command name to generate index for LaTeX.
        compact_latex: If the `compact_latex` tag is set to `True`, Doxygen generates more compact LaTeX documents.
        paper_type: The `paper_type` tag can be used to set the paper type that is used by the printer.
        extra_packages: The `extra_packages` tag can be used to specify one or more LaTeX package names that should be included in the LaTeX output.
        latex_header: The `latex_header` tag can be used to specify a user-defined LaTeX header for the generated LaTeX document.
        latex_footer: The `latex_footer` tag can be used to specify a user-defined LaTeX footer for the generated LaTeX document.
        latex_extra_stylesheet: The `latex_extra_stylesheet` tag can be used to specify additional user-defined LaTeX style sheets that are included after the standard style sheets created by Doxygen.
        latex_extra_files: The `latex_extra_files` tag can be used to specify one or more extra images or other source files which should be copied to the `latex_output` output directory.
        pdf_hyperlinks: If the `pdf_hyperlinks` tag is set to `True`, the LaTeX that is generated is prepared for conversion to PDF (using ps2pdf or pdflatex).
        use_pdflatex: If the `use_pdflatex` tag is set to `True`, Doxygen will use the engine as specified with `latex_cmd_name` to generate the PDF file directly from the LaTeX files.
        latex_batchmode: The `latex_batchmode` tag signals the behavior of LaTeX in case of an error.
        latex_hide_indices: If the `latex_hide_indices` tag is set to `True` then Doxygen will not include the index chapters (such as File Index, Compound Index, etc.) in the output.
        latex_bib_style: The `latex_bib_style` tag can be used to specify the style to use for the bibliography, e.g. plainnat, or ieeetr.
        latex_emoji_directory: The `latex_emoji_directory` tag is used to specify the (relative or absolute) path from which the emoji images will be read.
        generate_rtf: If the `generate_rtf` tag is set to `True`, Doxygen will generate RTF output.
        rtf_output: The `rtf_output` tag is used to specify where the RTF docs will be put.
        compact_rtf: If the `compact_rtf` tag is set to `True`, Doxygen generates more compact RTF documents.
        rtf_hyperlinks: If the `rtf_hyperlinks` tag is set to `True`, the RTF that is generated will contain hyperlink fields.
        rtf_stylesheet_file: Load stylesheet definitions from file.
        rtf_extensions_file: Set optional variables used in the generation of an RTF document.
        rtf_extra_files: The `rtf_extra_files` tag can be used to specify one or more extra images or other source files which should be copied to the `rtf_output` output directory.
        generate_man: If the `generate_man` tag is set to `True`, Doxygen will generate man pages for classes and files.
        man_output: The `man_output` tag is used to specify where the man pages will be put.
        man_extension: The `man_extension` tag determines the extension that is added to the generated man pages.
        man_subdir: The `man_subdir` tag determines the name of the directory created within `man_output` in which the man pages are placed.
        man_links: If the `man_links` tag is set to `True` and Doxygen generates man output, then it will generate one additional man file for each entity documented in the real man page(s).
        generate_xml: If the `generate_xml` tag is set to `True`, Doxygen will generate an XML file that captures the structure of the code including all documentation.
        xml_output: The `xml_output` tag is used to specify where the XML pages will be put.
        xml_programlisting: If the `xml_programlisting` tag is set to `True`, Doxygen will dump the program listings (including syntax highlighting and cross-referencing information) to the XML output.
        xml_ns_memb_file_scope: If the `xml_ns_memb_file_scope` tag is set to `True`, Doxygen will include namespace members in file scope as well, matching the HTML output.
        generate_docbook: If the `generate_docbook` tag is set to `True`, Doxygen will generate Docbook files that can be used to generate PDF.
        docbook_output: The `docbook_output` tag is used to specify where the Docbook pages will be put.
        generate_autogen_def: If the `generate_autogen_def` tag is set to `True`, Doxygen will generate an AutoGen Definitions (see https://autogen.sourceforge.net/) file that captures the structure of the code including all documentation.
        generate_sqlite3: If the `generate_sqlite3` tag is set to `True` Doxygen will generate a Sqlite3 database with symbols found by Doxygen stored in tables.
        sqlite3_output: The `sqlite3_output` tag is used to specify where the Sqlite3 database will be put.
        sqlite3_recreate_db: The `sqlite3_recreate_db` tag is set to `True`, the existing doxygen_sqlite3.db database file will be recreated with each Doxygen run.
        generate_perlmod: If the `generate_perlmod` tag is set to `True`, Doxygen will generate a Perl module file that captures the structure of the code including all documentation.
        perlmod_latex: If the `perlmod_latex` tag is set to `True`, Doxygen will generate the necessary Makefile rules, Perl scripts and LaTeX code to be able to generate PDF and DVI output from the Perl module output.
        perlmod_pretty: If the `perlmod_pretty` tag is set to `True`, the Perl module output will be nicely formatted so it can be parsed by a human reader.
        perlmod_makevar_prefix: The names of the make variables in the generated doxyrules.make file are prefixed with the string contained in `perlmod_makevar_prefix`.
        enable_preprocessing: If the `enable_preprocessing` tag is set to `True`, Doxygen will evaluate all C-preprocessor directives found in the sources and include files.
        macro_expansion: If the `macro_expansion` tag is set to `True`, Doxygen will expand all macro names in the source code.
        expand_only_predef: If the `expand_only_predef` and `macro_expansion` tags are both set to `True` then the macro expansion is limited to the macros specified with the `predefined` and `expand_as_defined` tags.
        search_includes: If the `search_includes` tag is set to `True`, the include files in the `include_path` will be searched if a #include is found.
        include_path: The `include_path` tag can be used to specify one or more directories that contain include files that are not input files but should be processed by the preprocessor.
        include_file_patterns: You can use the `include_file_patterns` tag to specify one or more wildcard patterns (like *.h and *.hpp) to filter out the header-files in the directories.
        predefined: The `predefined` tag can be used to specify one or more macro names that are defined before the preprocessor is started (similar to the -D option of e.g. gcc).
        expand_as_defined: If the `macro_expansion` and `expand_only_predef` tags are set to `True` then this tag can be used to specify a list of macro names that should be expanded.
        skip_function_macros: If the `skip_function_macros` tag is set to `True` then Doxygen's preprocessor will remove all references to function-like macros that are alone on a line, have an all uppercase name, and do not end with a semicolon.
        tagfiles: The `tagfiles` tag can be used to specify one or more tag files.
        generate_tagfile: When a file name is specified after `generate_tagfile`, Doxygen will create a tag file that is based on the input files it reads.
        allexternals: If the `allexternals` tag is set to `True`, all external classes and namespaces will be listed in the class and namespace index.
        external_groups: If the `external_groups` tag is set to `True`, all external groups will be listed in the topic index.
        external_pages: If the `external_pages` tag is set to `True`, all external pages will be listed in the related pages index.
        hide_undoc_relations: If set to `True` the inheritance and collaboration graphs will hide inheritance and usage relations if the target is undocumented or is not a class.
        have_dot: If you set the `have_dot` tag to `True` then Doxygen will assume the dot tool is available from the path.
        dot_num_threads: The `dot_num_threads` specifies the number of dot invocations Doxygen is allowed to run in parallel.
        dot_common_attr: `dot_common_attr` is common attributes for nodes, edges and labels of subgraphs.
        dot_edge_attr: `dot_edge_attr` is concatenated with `dot_common_attr`.
        dot_node_attr: `dot_node_attr` is concatenated with `dot_common_attr`.
        dot_fontpath: You can set the path where dot can find font specified with fontname in `dot_common_attr` and others dot attributes.
        dot_transparent: If the `dot_transparent` tag is set to `True`, then the images generated by dot will have a transparent background.
        class_graph: If the `class_graph` tag is set to `True` or GRAPH or BUILTIN then Doxygen will generate a graph for each documented class showing the direct and indirect inheritance relations.
        collaboration_graph: If the `collaboration_graph` tag is set to `True` then Doxygen will generate a graph for each documented class showing the direct and indirect implementation dependencies (inheritance, containment, and class references variables) of the class with other documented classes.
        group_graphs: If the `group_graphs` tag is set to `True` then Doxygen will generate a graph for groups, showing the direct groups dependencies.
        uml_look: If the `uml_look` tag is set to `True`, Doxygen will generate inheritance and collaboration diagrams in a style similar to the OMG's Unified Modeling Language.
        uml_limit_num_fields: If the `uml_look` tag is enabled, the fields and methods are shown inside the class node.
        uml_max_edge_labels: If the `uml_look` tag is enabled, field labels are shown along the edge between two class nodes.
        dot_uml_details: If the `dot_uml_details` tag is set to `False`, Doxygen will show attributes and methods without types and arguments in the UML graphs.
        dot_wrap_threshold: The `dot_wrap_threshold` tag can be used to set the maximum number of characters to display on a single line.
        template_relations: If the `template_relations` tag is set to `True` then the inheritance and collaboration graphs will show the relations between templates and their instances.
        include_graph: If the `include_graph`, `enable_preprocessing` and `search_includes` tags are set to `True` then Doxygen will generate a graph for each documented file showing the direct and indirect include dependencies of the file with other documented files.
        included_by_graph: If the `included_by_graph`, `enable_preprocessing` and `search_includes` tags are set to `True` then Doxygen will generate a graph for each documented file showing the direct and indirect include dependencies of the file with other documented files.
        call_graph: If the `call_graph` tag is set to `True` then Doxygen will generate a call dependency graph for every global function or class method.
        caller_graph: If the `caller_graph` tag is set to `True` then Doxygen will generate a caller dependency graph for every global function or class method.
        graphical_hierarchy: If the `graphical_hierarchy` tag is set to `True` then Doxygen will graphical hierarchy of all classes instead of a textual one.
        directory_graph: If the `directory_graph` tag is set to `True` then Doxygen will show the dependencies a directory has on other directories in a graphical way.
        dir_graph_max_depth: The `dir_graph_max_depth` tag can be used to limit the maximum number of levels of child directories generated in directory dependency graphs by dot.
        dot_image_format: The `dot_image_format` tag can be used to set the image format of the images generated by dot.
        interactive_svg: If `dot_image_format` is set to svg, then this option can be set to `True` to enable generation of interactive SVG images that allow zooming and panning.
        dot_path: The `dot_path` tag can be used to specify the path where the dot tool can be found.
        dotfile_dirs: The `dotfile_dirs` tag can be used to specify one or more directories that contain dot files that are included in the documentation (see the \\dotfile command).
        dia_path: You can include diagrams made with dia in Doxygen documentation.
        diafile_dirs: The `diafile_dirs` tag can be used to specify one or more directories that contain dia files that are included in the documentation (see the \\diafile command).
        plantuml_jar_path: When using PlantUML, the `plantuml_jar_path` tag should be used to specify the path where java can find the plantuml.jar file or to the filename of jar file to be used.
        plantuml_cfg_file: When using PlantUML, the `plantuml_cfg_file` tag can be used to specify a configuration file for PlantUML.
        plantuml_include_path: When using PlantUML, the specified paths are searched for files specified by the !include statement in a PlantUML block.
        plantumlfile_dirs: The plantumlfile_dirs tag can be used to specify one or more directories that contain PlantUml files that are included in the documentation (see the \\plantumlfile command).
        dot_graph_max_nodes: The `dot_graph_max_nodes` tag can be used to set the maximum number of nodes that will be shown in the graph.
        max_dot_graph_depth: The `max_dot_graph_depth` tag can be used to set the maximum depth of the graphs generated by dot.
        dot_multi_targets: Set the `dot_multi_targets` tag to `True` to allow dot to generate multiple output files in one run (i.e. multiple -o and -T options on the command line).
        generate_legend: If the `generate_legend` tag is set to `True` Doxygen will generate a legend page explaining the meaning of the various boxes and arrows in the dot generated graphs.
        dot_cleanup: If the `dot_cleanup` tag is set to `True`, Doxygen will remove the intermediate files that are used to generate the various graphs.
        mscgen_tool: You can define message sequence charts within Doxygen comments using the \\msc command.
        mscfile_dirs: The `mscfile_dirs` tag can be used to specify one or more directories that contain msc files that are included in the documentation (see the \\mscfile command).

        **kwargs: Additional arguments to pass to the rule (e.g. `visibility = ["//visibility:public"], tags = ["manual"]`)
    """
    if configurations == None:
        configurations = []
    _add_generic_configuration(configurations, "DOXYFILE_ENCODING", doxyfile_encoding)
    _add_generic_configuration(configurations, "PROJECT_NAME", project_name)
    _add_generic_configuration(configurations, "PROJECT_NUMBER", project_number)
    _add_generic_configuration(configurations, "PROJECT_BRIEF", project_brief)
    _add_generic_configuration(configurations, "PROJECT_LOGO", project_logo)
    _add_generic_configuration(configurations, "PROJECT_ICON", project_icon)
    _add_generic_configuration(configurations, "CREATE_SUBDIRS", create_subdirs)
    _add_generic_configuration(configurations, "CREATE_SUBDIRS_LEVEL", create_subdirs_level)
    _add_generic_configuration(configurations, "ALLOW_UNICODE_NAMES", allow_unicode_names)
    _add_generic_configuration(configurations, "OUTPUT_LANGUAGE", output_language)
    _add_generic_configuration(configurations, "BRIEF_MEMBER_DESC", brief_member_desc)
    _add_generic_configuration(configurations, "REPEAT_BRIEF", repeat_brief)
    _add_generic_configuration(configurations, "ABBREVIATE_BRIEF", abbreviate_brief)
    _add_generic_configuration(configurations, "ALWAYS_DETAILED_SEC", always_detailed_sec)
    _add_generic_configuration(configurations, "INLINE_INHERITED_MEMB", inline_inherited_memb)
    _add_generic_configuration(configurations, "FULL_PATH_NAMES", full_path_names)
    _add_generic_configuration(configurations, "STRIP_FROM_PATH", strip_from_path)
    _add_generic_configuration(configurations, "STRIP_FROM_INC_PATH", strip_from_inc_path)
    _add_generic_configuration(configurations, "SHORT_NAMES", short_names)
    _add_generic_configuration(configurations, "JAVADOC_AUTOBRIEF", javadoc_autobrief)
    _add_generic_configuration(configurations, "JAVADOC_BANNER", javadoc_banner)
    _add_generic_configuration(configurations, "QT_AUTOBRIEF", qt_autobrief)
    _add_generic_configuration(configurations, "MULTILINE_CPP_IS_BRIEF", multiline_cpp_is_brief)
    _add_generic_configuration(configurations, "PYTHON_DOCSTRING", python_docstring)
    _add_generic_configuration(configurations, "INHERIT_DOCS", inherit_docs)
    _add_generic_configuration(configurations, "SEPARATE_MEMBER_PAGES", separate_member_pages)
    _add_generic_configuration(configurations, "TAB_SIZE", tab_size)
    _add_generic_configuration(configurations, "ALIASES", aliases)
    _add_generic_configuration(configurations, "OPTIMIZE_OUTPUT_FOR_C", optimize_output_for_c)
    _add_generic_configuration(configurations, "OPTIMIZE_OUTPUT_JAVA", optimize_output_java)
    _add_generic_configuration(configurations, "OPTIMIZE_FOR_FORTRAN", optimize_for_fortran)
    _add_generic_configuration(configurations, "OPTIMIZE_OUTPUT_VHDL", optimize_output_vhdl)
    _add_generic_configuration(configurations, "OPTIMIZE_OUTPUT_SLICE", optimize_output_slice)
    _add_generic_configuration(configurations, "EXTENSION_MAPPING", extension_mapping)
    _add_generic_configuration(configurations, "MARKDOWN_SUPPORT", markdown_support)
    _add_generic_configuration(configurations, "TOC_INCLUDE_HEADINGS", toc_include_headings)
    _add_generic_configuration(configurations, "MARKDOWN_ID_STYLE", markdown_id_style)
    _add_generic_configuration(configurations, "AUTOLINK_SUPPORT", autolink_support)
    _add_generic_configuration(configurations, "AUTOLINK_IGNORE_WORDS", autolink_ignore_words)
    _add_generic_configuration(configurations, "BUILTIN_STL_SUPPORT", builtin_stl_support)
    _add_generic_configuration(configurations, "CPP_CLI_SUPPORT", cpp_cli_support)
    _add_generic_configuration(configurations, "SIP_SUPPORT", sip_support)
    _add_generic_configuration(configurations, "IDL_PROPERTY_SUPPORT", idl_property_support)
    _add_generic_configuration(configurations, "DISTRIBUTE_GROUP_DOC", distribute_group_doc)
    _add_generic_configuration(configurations, "GROUP_NESTED_COMPOUNDS", group_nested_compounds)
    _add_generic_configuration(configurations, "SUBGROUPING", subgrouping)
    _add_generic_configuration(configurations, "INLINE_GROUPED_CLASSES", inline_grouped_classes)
    _add_generic_configuration(configurations, "INLINE_SIMPLE_STRUCTS", inline_simple_structs)
    _add_generic_configuration(configurations, "TYPEDEF_HIDES_STRUCT", typedef_hides_struct)
    _add_generic_configuration(configurations, "LOOKUP_CACHE_SIZE", lookup_cache_size)
    _add_generic_configuration(configurations, "NUM_PROC_THREADS", num_proc_threads)
    _add_generic_configuration(configurations, "TIMESTAMP", timestamp)
    _add_generic_configuration(configurations, "EXTRACT_ALL", extract_all)
    _add_generic_configuration(configurations, "EXTRACT_PRIVATE", extract_private)
    _add_generic_configuration(configurations, "EXTRACT_PRIV_VIRTUAL", extract_priv_virtual)
    _add_generic_configuration(configurations, "EXTRACT_PACKAGE", extract_package)
    _add_generic_configuration(configurations, "EXTRACT_STATIC", extract_static)
    _add_generic_configuration(configurations, "EXTRACT_LOCAL_CLASSES", extract_local_classes)
    _add_generic_configuration(configurations, "EXTRACT_LOCAL_METHODS", extract_local_methods)
    _add_generic_configuration(configurations, "EXTRACT_ANON_NSPACES", extract_anon_nspaces)
    _add_generic_configuration(configurations, "RESOLVE_UNNAMED_PARAMS", resolve_unnamed_params)
    _add_generic_configuration(configurations, "HIDE_UNDOC_MEMBERS", hide_undoc_members)
    _add_generic_configuration(configurations, "HIDE_UNDOC_CLASSES", hide_undoc_classes)
    _add_generic_configuration(configurations, "HIDE_UNDOC_NAMESPACES", hide_undoc_namespaces)
    _add_generic_configuration(configurations, "HIDE_FRIEND_COMPOUNDS", hide_friend_compounds)
    _add_generic_configuration(configurations, "HIDE_IN_BODY_DOCS", hide_in_body_docs)
    _add_generic_configuration(configurations, "INTERNAL_DOCS", internal_docs)
    _add_generic_configuration(configurations, "CASE_SENSE_NAMES", case_sense_names)
    _add_generic_configuration(configurations, "HIDE_SCOPE_NAMES", hide_scope_names)
    _add_generic_configuration(configurations, "HIDE_COMPOUND_REFERENCE", hide_compound_reference)
    _add_generic_configuration(configurations, "SHOW_HEADERFILE", show_headerfile)
    _add_generic_configuration(configurations, "SHOW_INCLUDE_FILES", show_include_files)
    _add_generic_configuration(configurations, "SHOW_GROUPED_MEMB_INC", show_grouped_memb_inc)
    _add_generic_configuration(configurations, "FORCE_LOCAL_INCLUDES", force_local_includes)
    _add_generic_configuration(configurations, "INLINE_INFO", inline_info)
    _add_generic_configuration(configurations, "SORT_MEMBER_DOCS", sort_member_docs)
    _add_generic_configuration(configurations, "SORT_BRIEF_DOCS", sort_brief_docs)
    _add_generic_configuration(configurations, "SORT_MEMBERS_CTORS_1ST", sort_members_ctors_1st)
    _add_generic_configuration(configurations, "SORT_GROUP_NAMES", sort_group_names)
    _add_generic_configuration(configurations, "SORT_BY_SCOPE_NAME", sort_by_scope_name)
    _add_generic_configuration(configurations, "STRICT_PROTO_MATCHING", strict_proto_matching)
    _add_generic_configuration(configurations, "GENERATE_TODOLIST", generate_todolist)
    _add_generic_configuration(configurations, "GENERATE_TESTLIST", generate_testlist)
    _add_generic_configuration(configurations, "GENERATE_BUGLIST", generate_buglist)
    _add_generic_configuration(configurations, "GENERATE_DEPRECATEDLIST", generate_deprecatedlist)
    _add_generic_configuration(configurations, "ENABLED_SECTIONS", enabled_sections)
    _add_generic_configuration(configurations, "MAX_INITIALIZER_LINES", max_initializer_lines)
    _add_generic_configuration(configurations, "SHOW_USED_FILES", show_used_files)
    _add_generic_configuration(configurations, "SHOW_FILES", show_files)
    _add_generic_configuration(configurations, "SHOW_NAMESPACES", show_namespaces)
    _add_generic_configuration(configurations, "FILE_VERSION_FILTER", file_version_filter)
    _add_generic_configuration(configurations, "LAYOUT_FILE", layout_file)
    _add_generic_configuration(configurations, "CITE_BIB_FILES", cite_bib_files)
    _add_generic_configuration(configurations, "EXTERNAL_TOOL_PATH", external_tool_path)
    _add_generic_configuration(configurations, "QUIET", quiet)
    _add_generic_configuration(configurations, "WARNINGS", warnings)
    _add_generic_configuration(configurations, "WARN_IF_UNDOCUMENTED", warn_if_undocumented)
    _add_generic_configuration(configurations, "WARN_IF_DOC_ERROR", warn_if_doc_error)
    _add_generic_configuration(configurations, "WARN_IF_INCOMPLETE_DOC", warn_if_incomplete_doc)
    _add_generic_configuration(configurations, "WARN_NO_PARAMDOC", warn_no_paramdoc)
    _add_generic_configuration(configurations, "WARN_IF_UNDOC_ENUM_VAL", warn_if_undoc_enum_val)
    _add_generic_configuration(configurations, "WARN_LAYOUT_FILE", warn_layout_file)
    _add_generic_configuration(configurations, "WARN_AS_ERROR", warn_as_error)
    _add_generic_configuration(configurations, "WARN_FORMAT", warn_format)
    _add_generic_configuration(configurations, "WARN_LINE_FORMAT", warn_line_format)
    _add_generic_configuration(configurations, "WARN_LOGFILE", warn_logfile)
    _add_generic_configuration(configurations, "INPUT", input)
    _add_generic_configuration(configurations, "INPUT_ENCODING", input_encoding)
    _add_generic_configuration(configurations, "INPUT_FILE_ENCODING", input_file_encoding)
    _add_generic_configuration(configurations, "FILE_PATTERNS", file_patterns)
    _add_generic_configuration(configurations, "RECURSIVE", recursive)
    _add_generic_configuration(configurations, "EXCLUDE", exclude)
    _add_generic_configuration(configurations, "EXCLUDE_SYMLINKS", exclude_symlinks)
    _add_generic_configuration(configurations, "EXCLUDE_PATTERNS", exclude_patterns)
    _add_generic_configuration(configurations, "EXCLUDE_SYMBOLS", exclude_symbols)
    _add_generic_configuration(configurations, "EXAMPLE_PATH", example_path)
    _add_generic_configuration(configurations, "EXAMPLE_PATTERNS", example_patterns)
    _add_generic_configuration(configurations, "EXAMPLE_RECURSIVE", example_recursive)
    _add_generic_configuration(configurations, "IMAGE_PATH", image_path)
    _add_generic_configuration(configurations, "INPUT_FILTER", input_filter)
    _add_generic_configuration(configurations, "FILTER_PATTERNS", filter_patterns)
    _add_generic_configuration(configurations, "FILTER_SOURCE_FILES", filter_source_files)
    _add_generic_configuration(configurations, "FILTER_SOURCE_PATTERNS", filter_source_patterns)
    _add_generic_configuration(configurations, "USE_MDFILE_AS_MAINPAGE", use_mdfile_as_mainpage)
    _add_generic_configuration(configurations, "IMPLICIT_DIR_DOCS", implicit_dir_docs)
    _add_generic_configuration(configurations, "FORTRAN_COMMENT_AFTER", fortran_comment_after)
    _add_generic_configuration(configurations, "SOURCE_BROWSER", source_browser)
    _add_generic_configuration(configurations, "INLINE_SOURCES", inline_sources)
    _add_generic_configuration(configurations, "STRIP_CODE_COMMENTS", strip_code_comments)
    _add_generic_configuration(configurations, "REFERENCED_BY_RELATION", referenced_by_relation)
    _add_generic_configuration(configurations, "REFERENCES_RELATION", references_relation)
    _add_generic_configuration(configurations, "REFERENCES_LINK_SOURCE", references_link_source)
    _add_generic_configuration(configurations, "SOURCE_TOOLTIPS", source_tooltips)
    _add_generic_configuration(configurations, "USE_HTAGS", use_htags)
    _add_generic_configuration(configurations, "VERBATIM_HEADERS", verbatim_headers)
    _add_generic_configuration(configurations, "CLANG_ASSISTED_PARSING", clang_assisted_parsing)
    _add_generic_configuration(configurations, "CLANG_ADD_INC_PATHS", clang_add_inc_paths)
    _add_generic_configuration(configurations, "CLANG_OPTIONS", clang_options)
    _add_generic_configuration(configurations, "CLANG_DATABASE_PATH", clang_database_path)
    _add_generic_configuration(configurations, "ALPHABETICAL_INDEX", alphabetical_index)
    _add_generic_configuration(configurations, "IGNORE_PREFIX", ignore_prefix)
    _add_generic_configuration(configurations, "GENERATE_HTML", generate_html)
    _add_generic_configuration(configurations, "HTML_OUTPUT", html_output)
    _add_generic_configuration(configurations, "HTML_FILE_EXTENSION", html_file_extension)
    _add_generic_configuration(configurations, "HTML_HEADER", html_header)
    _add_generic_configuration(configurations, "HTML_FOOTER", html_footer)
    _add_generic_configuration(configurations, "HTML_STYLESHEET", html_stylesheet)
    _add_generic_configuration(configurations, "HTML_EXTRA_STYLESHEET", html_extra_stylesheet)
    _add_generic_configuration(configurations, "HTML_EXTRA_FILES", html_extra_files)
    _add_generic_configuration(configurations, "HTML_COLORSTYLE", html_colorstyle)
    _add_generic_configuration(configurations, "HTML_COLORSTYLE_HUE", html_colorstyle_hue)
    _add_generic_configuration(configurations, "HTML_COLORSTYLE_SAT", html_colorstyle_sat)
    _add_generic_configuration(configurations, "HTML_COLORSTYLE_GAMMA", html_colorstyle_gamma)
    _add_generic_configuration(configurations, "HTML_DYNAMIC_MENUS", html_dynamic_menus)
    _add_generic_configuration(configurations, "HTML_DYNAMIC_SECTIONS", html_dynamic_sections)
    _add_generic_configuration(configurations, "HTML_CODE_FOLDING", html_code_folding)
    _add_generic_configuration(configurations, "HTML_COPY_CLIPBOARD", html_copy_clipboard)
    _add_generic_configuration(configurations, "HTML_PROJECT_COOKIE", html_project_cookie)
    _add_generic_configuration(configurations, "HTML_INDEX_NUM_ENTRIES", html_index_num_entries)
    _add_generic_configuration(configurations, "GENERATE_DOCSET", generate_docset)
    _add_generic_configuration(configurations, "DOCSET_FEEDNAME", docset_feedname)
    _add_generic_configuration(configurations, "DOCSET_FEEDURL", docset_feedurl)
    _add_generic_configuration(configurations, "DOCSET_BUNDLE_ID", docset_bundle_id)
    _add_generic_configuration(configurations, "DOCSET_PUBLISHER_ID", docset_publisher_id)
    _add_generic_configuration(configurations, "DOCSET_PUBLISHER_NAME", docset_publisher_name)
    _add_generic_configuration(configurations, "GENERATE_HTMLHELP", generate_htmlhelp)
    _add_generic_configuration(configurations, "CHM_FILE", chm_file)
    _add_generic_configuration(configurations, "HHC_LOCATION", hhc_location)
    _add_generic_configuration(configurations, "GENERATE_CHI", generate_chi)
    _add_generic_configuration(configurations, "CHM_INDEX_ENCODING", chm_index_encoding)
    _add_generic_configuration(configurations, "BINARY_TOC", binary_toc)
    _add_generic_configuration(configurations, "TOC_EXPAND", toc_expand)
    _add_generic_configuration(configurations, "SITEMAP_URL", sitemap_url)
    _add_generic_configuration(configurations, "GENERATE_QHP", generate_qhp)
    _add_generic_configuration(configurations, "QCH_FILE", qch_file)
    _add_generic_configuration(configurations, "QHP_NAMESPACE", qhp_namespace)
    _add_generic_configuration(configurations, "QHP_VIRTUAL_FOLDER", qhp_virtual_folder)
    _add_generic_configuration(configurations, "QHP_CUST_FILTER_NAME", qhp_cust_filter_name)
    _add_generic_configuration(configurations, "QHP_CUST_FILTER_ATTRS", qhp_cust_filter_attrs)
    _add_generic_configuration(configurations, "QHP_SECT_FILTER_ATTRS", qhp_sect_filter_attrs)
    _add_generic_configuration(configurations, "QHG_LOCATION", qhg_location)
    _add_generic_configuration(configurations, "GENERATE_ECLIPSEHELP", generate_eclipsehelp)
    _add_generic_configuration(configurations, "ECLIPSE_DOC_ID", eclipse_doc_id)
    _add_generic_configuration(configurations, "DISABLE_INDEX", disable_index)
    _add_generic_configuration(configurations, "GENERATE_TREEVIEW", generate_treeview)
    _add_generic_configuration(configurations, "PAGE_OUTLINE_PANEL", page_outline_panel)
    _add_generic_configuration(configurations, "FULL_SIDEBAR", full_sidebar)
    _add_generic_configuration(configurations, "ENUM_VALUES_PER_LINE", enum_values_per_line)
    _add_generic_configuration(configurations, "SHOW_ENUM_VALUES", show_enum_values)
    _add_generic_configuration(configurations, "TREEVIEW_WIDTH", treeview_width)
    _add_generic_configuration(configurations, "EXT_LINKS_IN_WINDOW", ext_links_in_window)
    _add_generic_configuration(configurations, "OBFUSCATE_EMAILS", obfuscate_emails)
    _add_generic_configuration(configurations, "HTML_FORMULA_FORMAT", html_formula_format)
    _add_generic_configuration(configurations, "FORMULA_FONTSIZE", formula_fontsize)
    _add_generic_configuration(configurations, "FORMULA_MACROFILE", formula_macrofile)
    _add_generic_configuration(configurations, "USE_MATHJAX", use_mathjax)
    _add_generic_configuration(configurations, "MATHJAX_VERSION", mathjax_version)
    _add_generic_configuration(configurations, "MATHJAX_FORMAT", mathjax_format)
    _add_generic_configuration(configurations, "MATHJAX_RELPATH", mathjax_relpath)
    _add_generic_configuration(configurations, "MATHJAX_EXTENSIONS", mathjax_extensions)
    _add_generic_configuration(configurations, "MATHJAX_CODEFILE", mathjax_codefile)
    _add_generic_configuration(configurations, "SEARCHENGINE", searchengine)
    _add_generic_configuration(configurations, "SERVER_BASED_SEARCH", server_based_search)
    _add_generic_configuration(configurations, "EXTERNAL_SEARCH", external_search)
    _add_generic_configuration(configurations, "SEARCHENGINE_URL", searchengine_url)
    _add_generic_configuration(configurations, "SEARCHDATA_FILE", searchdata_file)
    _add_generic_configuration(configurations, "EXTERNAL_SEARCH_ID", external_search_id)
    _add_generic_configuration(configurations, "EXTRA_SEARCH_MAPPINGS", extra_search_mappings)
    _add_generic_configuration(configurations, "GENERATE_LATEX", generate_latex)
    _add_generic_configuration(configurations, "LATEX_OUTPUT", latex_output)
    _add_generic_configuration(configurations, "LATEX_CMD_NAME", latex_cmd_name)
    _add_generic_configuration(configurations, "MAKEINDEX_CMD_NAME", makeindex_cmd_name)
    _add_generic_configuration(configurations, "LATEX_MAKEINDEX_CMD", latex_makeindex_cmd)
    _add_generic_configuration(configurations, "COMPACT_LATEX", compact_latex)
    _add_generic_configuration(configurations, "PAPER_TYPE", paper_type)
    _add_generic_configuration(configurations, "EXTRA_PACKAGES", extra_packages)
    _add_generic_configuration(configurations, "LATEX_HEADER", latex_header)
    _add_generic_configuration(configurations, "LATEX_FOOTER", latex_footer)
    _add_generic_configuration(configurations, "LATEX_EXTRA_STYLESHEET", latex_extra_stylesheet)
    _add_generic_configuration(configurations, "LATEX_EXTRA_FILES", latex_extra_files)
    _add_generic_configuration(configurations, "PDF_HYPERLINKS", pdf_hyperlinks)
    _add_generic_configuration(configurations, "USE_PDFLATEX", use_pdflatex)
    _add_generic_configuration(configurations, "LATEX_BATCHMODE", latex_batchmode)
    _add_generic_configuration(configurations, "LATEX_HIDE_INDICES", latex_hide_indices)
    _add_generic_configuration(configurations, "LATEX_BIB_STYLE", latex_bib_style)
    _add_generic_configuration(configurations, "LATEX_EMOJI_DIRECTORY", latex_emoji_directory)
    _add_generic_configuration(configurations, "GENERATE_RTF", generate_rtf)
    _add_generic_configuration(configurations, "RTF_OUTPUT", rtf_output)
    _add_generic_configuration(configurations, "COMPACT_RTF", compact_rtf)
    _add_generic_configuration(configurations, "RTF_HYPERLINKS", rtf_hyperlinks)
    _add_generic_configuration(configurations, "RTF_STYLESHEET_FILE", rtf_stylesheet_file)
    _add_generic_configuration(configurations, "RTF_EXTENSIONS_FILE", rtf_extensions_file)
    _add_generic_configuration(configurations, "RTF_EXTRA_FILES", rtf_extra_files)
    _add_generic_configuration(configurations, "GENERATE_MAN", generate_man)
    _add_generic_configuration(configurations, "MAN_OUTPUT", man_output)
    _add_generic_configuration(configurations, "MAN_EXTENSION", man_extension)
    _add_generic_configuration(configurations, "MAN_SUBDIR", man_subdir)
    _add_generic_configuration(configurations, "MAN_LINKS", man_links)
    _add_generic_configuration(configurations, "GENERATE_XML", generate_xml)
    _add_generic_configuration(configurations, "XML_OUTPUT", xml_output)
    _add_generic_configuration(configurations, "XML_PROGRAMLISTING", xml_programlisting)
    _add_generic_configuration(configurations, "XML_NS_MEMB_FILE_SCOPE", xml_ns_memb_file_scope)
    _add_generic_configuration(configurations, "GENERATE_DOCBOOK", generate_docbook)
    _add_generic_configuration(configurations, "DOCBOOK_OUTPUT", docbook_output)
    _add_generic_configuration(configurations, "GENERATE_AUTOGEN_DEF", generate_autogen_def)
    _add_generic_configuration(configurations, "GENERATE_SQLITE3", generate_sqlite3)
    _add_generic_configuration(configurations, "SQLITE3_OUTPUT", sqlite3_output)
    _add_generic_configuration(configurations, "SQLITE3_RECREATE_DB", sqlite3_recreate_db)
    _add_generic_configuration(configurations, "GENERATE_PERLMOD", generate_perlmod)
    _add_generic_configuration(configurations, "PERLMOD_LATEX", perlmod_latex)
    _add_generic_configuration(configurations, "PERLMOD_PRETTY", perlmod_pretty)
    _add_generic_configuration(configurations, "PERLMOD_MAKEVAR_PREFIX", perlmod_makevar_prefix)
    _add_generic_configuration(configurations, "ENABLE_PREPROCESSING", enable_preprocessing)
    _add_generic_configuration(configurations, "MACRO_EXPANSION", macro_expansion)
    _add_generic_configuration(configurations, "EXPAND_ONLY_PREDEF", expand_only_predef)
    _add_generic_configuration(configurations, "SEARCH_INCLUDES", search_includes)
    _add_generic_configuration(configurations, "INCLUDE_PATH", include_path)
    _add_generic_configuration(configurations, "INCLUDE_FILE_PATTERNS", include_file_patterns)
    _add_generic_configuration(configurations, "PREDEFINED", predefined)
    _add_generic_configuration(configurations, "EXPAND_AS_DEFINED", expand_as_defined)
    _add_generic_configuration(configurations, "SKIP_FUNCTION_MACROS", skip_function_macros)
    _add_generic_configuration(configurations, "TAGFILES", tagfiles)
    _add_generic_configuration(configurations, "GENERATE_TAGFILE", generate_tagfile)
    _add_generic_configuration(configurations, "ALLEXTERNALS", allexternals)
    _add_generic_configuration(configurations, "EXTERNAL_GROUPS", external_groups)
    _add_generic_configuration(configurations, "EXTERNAL_PAGES", external_pages)
    _add_generic_configuration(configurations, "HIDE_UNDOC_RELATIONS", hide_undoc_relations)
    _add_generic_configuration(configurations, "HAVE_DOT", have_dot)
    _add_generic_configuration(configurations, "DOT_NUM_THREADS", dot_num_threads)
    _add_generic_configuration(configurations, "DOT_COMMON_ATTR", dot_common_attr)
    _add_generic_configuration(configurations, "DOT_EDGE_ATTR", dot_edge_attr)
    _add_generic_configuration(configurations, "DOT_NODE_ATTR", dot_node_attr)
    _add_generic_configuration(configurations, "DOT_FONTPATH", dot_fontpath)
    _add_generic_configuration(configurations, "DOT_TRANSPARENT", dot_transparent)
    _add_generic_configuration(configurations, "CLASS_GRAPH", class_graph)
    _add_generic_configuration(configurations, "COLLABORATION_GRAPH", collaboration_graph)
    _add_generic_configuration(configurations, "GROUP_GRAPHS", group_graphs)
    _add_generic_configuration(configurations, "UML_LOOK", uml_look)
    _add_generic_configuration(configurations, "UML_LIMIT_NUM_FIELDS", uml_limit_num_fields)
    _add_generic_configuration(configurations, "UML_MAX_EDGE_LABELS", uml_max_edge_labels)
    _add_generic_configuration(configurations, "DOT_UML_DETAILS", dot_uml_details)
    _add_generic_configuration(configurations, "DOT_WRAP_THRESHOLD", dot_wrap_threshold)
    _add_generic_configuration(configurations, "TEMPLATE_RELATIONS", template_relations)
    _add_generic_configuration(configurations, "INCLUDE_GRAPH", include_graph)
    _add_generic_configuration(configurations, "INCLUDED_BY_GRAPH", included_by_graph)
    _add_generic_configuration(configurations, "CALL_GRAPH", call_graph)
    _add_generic_configuration(configurations, "CALLER_GRAPH", caller_graph)
    _add_generic_configuration(configurations, "GRAPHICAL_HIERARCHY", graphical_hierarchy)
    _add_generic_configuration(configurations, "DIRECTORY_GRAPH", directory_graph)
    _add_generic_configuration(configurations, "DIR_GRAPH_MAX_DEPTH", dir_graph_max_depth)
    _add_generic_configuration(configurations, "DOT_IMAGE_FORMAT", dot_image_format)
    _add_generic_configuration(configurations, "INTERACTIVE_SVG", interactive_svg)
    _add_generic_configuration(configurations, "DOT_PATH", dot_path)
    _add_generic_configuration(configurations, "DOTFILE_DIRS", dotfile_dirs)
    _add_generic_configuration(configurations, "DIA_PATH", dia_path)
    _add_generic_configuration(configurations, "DIAFILE_DIRS", diafile_dirs)
    _add_generic_configuration(configurations, "PLANTUML_JAR_PATH", plantuml_jar_path)
    _add_generic_configuration(configurations, "PLANTUML_CFG_FILE", plantuml_cfg_file)
    _add_generic_configuration(configurations, "PLANTUML_INCLUDE_PATH", plantuml_include_path)
    _add_generic_configuration(configurations, "PLANTUMLFILE_DIRS", plantumlfile_dirs)
    _add_generic_configuration(configurations, "DOT_GRAPH_MAX_NODES", dot_graph_max_nodes)
    _add_generic_configuration(configurations, "MAX_DOT_GRAPH_DEPTH", max_dot_graph_depth)
    _add_generic_configuration(configurations, "DOT_MULTI_TARGETS", dot_multi_targets)
    _add_generic_configuration(configurations, "GENERATE_LEGEND", generate_legend)
    _add_generic_configuration(configurations, "DOT_CLEANUP", dot_cleanup)
    _add_generic_configuration(configurations, "MSCGEN_TOOL", mscgen_tool)
    _add_generic_configuration(configurations, "MSCFILE_DIRS", mscfile_dirs)

    if doxyfile_template:
        kwargs["doxyfile_template"] = doxyfile_template

    _doxygen(
        name = name,
        srcs = srcs,
        deps = deps,
        outs = outs,
        configurations = configurations,
        doxygen_extra_args = doxygen_extra_args,
        dot_executable = dot_executable,
        **kwargs
    )
