<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Doxygen rule for Bazel.

<a id="doxygen"></a>

## doxygen

<pre>
load("@doxygen//:doxygen.bzl", "doxygen")

doxygen(<a href="#doxygen-name">name</a>, <a href="#doxygen-srcs">srcs</a>, <a href="#doxygen-dot_executable">dot_executable</a>, <a href="#doxygen-configurations">configurations</a>, <a href="#doxygen-doxyfile_template">doxyfile_template</a>, <a href="#doxygen-doxygen_extra_args">doxygen_extra_args</a>, <a href="#doxygen-outs">outs</a>,
        <a href="#doxygen-doxyfile_encoding">doxyfile_encoding</a>, <a href="#doxygen-project_name">project_name</a>, <a href="#doxygen-project_number">project_number</a>, <a href="#doxygen-project_brief">project_brief</a>, <a href="#doxygen-project_logo">project_logo</a>, <a href="#doxygen-project_icon">project_icon</a>,
        <a href="#doxygen-create_subdirs">create_subdirs</a>, <a href="#doxygen-create_subdirs_level">create_subdirs_level</a>, <a href="#doxygen-allow_unicode_names">allow_unicode_names</a>, <a href="#doxygen-output_language">output_language</a>, <a href="#doxygen-brief_member_desc">brief_member_desc</a>,
        <a href="#doxygen-repeat_brief">repeat_brief</a>, <a href="#doxygen-abbreviate_brief">abbreviate_brief</a>, <a href="#doxygen-always_detailed_sec">always_detailed_sec</a>, <a href="#doxygen-inline_inherited_memb">inline_inherited_memb</a>, <a href="#doxygen-full_path_names">full_path_names</a>,
        <a href="#doxygen-strip_from_path">strip_from_path</a>, <a href="#doxygen-strip_from_inc_path">strip_from_inc_path</a>, <a href="#doxygen-short_names">short_names</a>, <a href="#doxygen-javadoc_autobrief">javadoc_autobrief</a>, <a href="#doxygen-javadoc_banner">javadoc_banner</a>,
        <a href="#doxygen-qt_autobrief">qt_autobrief</a>, <a href="#doxygen-multiline_cpp_is_brief">multiline_cpp_is_brief</a>, <a href="#doxygen-python_docstring">python_docstring</a>, <a href="#doxygen-inherit_docs">inherit_docs</a>, <a href="#doxygen-separate_member_pages">separate_member_pages</a>,
        <a href="#doxygen-tab_size">tab_size</a>, <a href="#doxygen-aliases">aliases</a>, <a href="#doxygen-optimize_output_for_c">optimize_output_for_c</a>, <a href="#doxygen-optimize_output_java">optimize_output_java</a>, <a href="#doxygen-optimize_for_fortran">optimize_for_fortran</a>,
        <a href="#doxygen-optimize_output_vhdl">optimize_output_vhdl</a>, <a href="#doxygen-optimize_output_slice">optimize_output_slice</a>, <a href="#doxygen-extension_mapping">extension_mapping</a>, <a href="#doxygen-markdown_support">markdown_support</a>,
        <a href="#doxygen-toc_include_headings">toc_include_headings</a>, <a href="#doxygen-markdown_id_style">markdown_id_style</a>, <a href="#doxygen-autolink_support">autolink_support</a>, <a href="#doxygen-builtin_stl_support">builtin_stl_support</a>,
        <a href="#doxygen-cpp_cli_support">cpp_cli_support</a>, <a href="#doxygen-sip_support">sip_support</a>, <a href="#doxygen-idl_property_support">idl_property_support</a>, <a href="#doxygen-distribute_group_doc">distribute_group_doc</a>,
        <a href="#doxygen-group_nested_compounds">group_nested_compounds</a>, <a href="#doxygen-subgrouping">subgrouping</a>, <a href="#doxygen-inline_grouped_classes">inline_grouped_classes</a>, <a href="#doxygen-inline_simple_structs">inline_simple_structs</a>,
        <a href="#doxygen-typedef_hides_struct">typedef_hides_struct</a>, <a href="#doxygen-lookup_cache_size">lookup_cache_size</a>, <a href="#doxygen-num_proc_threads">num_proc_threads</a>, <a href="#doxygen-timestamp">timestamp</a>, <a href="#doxygen-extract_all">extract_all</a>,
        <a href="#doxygen-extract_private">extract_private</a>, <a href="#doxygen-extract_priv_virtual">extract_priv_virtual</a>, <a href="#doxygen-extract_package">extract_package</a>, <a href="#doxygen-extract_static">extract_static</a>, <a href="#doxygen-extract_local_classes">extract_local_classes</a>,
        <a href="#doxygen-extract_local_methods">extract_local_methods</a>, <a href="#doxygen-extract_anon_nspaces">extract_anon_nspaces</a>, <a href="#doxygen-resolve_unnamed_params">resolve_unnamed_params</a>, <a href="#doxygen-hide_undoc_members">hide_undoc_members</a>,
        <a href="#doxygen-hide_undoc_classes">hide_undoc_classes</a>, <a href="#doxygen-hide_friend_compounds">hide_friend_compounds</a>, <a href="#doxygen-hide_in_body_docs">hide_in_body_docs</a>, <a href="#doxygen-internal_docs">internal_docs</a>, <a href="#doxygen-case_sense_names">case_sense_names</a>,
        <a href="#doxygen-hide_scope_names">hide_scope_names</a>, <a href="#doxygen-hide_compound_reference">hide_compound_reference</a>, <a href="#doxygen-show_headerfile">show_headerfile</a>, <a href="#doxygen-show_include_files">show_include_files</a>,
        <a href="#doxygen-show_grouped_memb_inc">show_grouped_memb_inc</a>, <a href="#doxygen-force_local_includes">force_local_includes</a>, <a href="#doxygen-inline_info">inline_info</a>, <a href="#doxygen-sort_member_docs">sort_member_docs</a>, <a href="#doxygen-sort_brief_docs">sort_brief_docs</a>,
        <a href="#doxygen-sort_members_ctors_1st">sort_members_ctors_1st</a>, <a href="#doxygen-sort_group_names">sort_group_names</a>, <a href="#doxygen-sort_by_scope_name">sort_by_scope_name</a>, <a href="#doxygen-strict_proto_matching">strict_proto_matching</a>,
        <a href="#doxygen-generate_todolist">generate_todolist</a>, <a href="#doxygen-generate_testlist">generate_testlist</a>, <a href="#doxygen-generate_buglist">generate_buglist</a>, <a href="#doxygen-generate_deprecatedlist">generate_deprecatedlist</a>,
        <a href="#doxygen-enabled_sections">enabled_sections</a>, <a href="#doxygen-max_initializer_lines">max_initializer_lines</a>, <a href="#doxygen-show_used_files">show_used_files</a>, <a href="#doxygen-show_files">show_files</a>, <a href="#doxygen-show_namespaces">show_namespaces</a>,
        <a href="#doxygen-file_version_filter">file_version_filter</a>, <a href="#doxygen-layout_file">layout_file</a>, <a href="#doxygen-cite_bib_files">cite_bib_files</a>, <a href="#doxygen-external_tool_path">external_tool_path</a>, <a href="#doxygen-quiet">quiet</a>, <a href="#doxygen-warnings">warnings</a>,
        <a href="#doxygen-warn_if_undocumented">warn_if_undocumented</a>, <a href="#doxygen-warn_if_doc_error">warn_if_doc_error</a>, <a href="#doxygen-warn_if_incomplete_doc">warn_if_incomplete_doc</a>, <a href="#doxygen-warn_no_paramdoc">warn_no_paramdoc</a>,
        <a href="#doxygen-warn_if_undoc_enum_val">warn_if_undoc_enum_val</a>, <a href="#doxygen-warn_as_error">warn_as_error</a>, <a href="#doxygen-warn_format">warn_format</a>, <a href="#doxygen-warn_line_format">warn_line_format</a>, <a href="#doxygen-warn_logfile">warn_logfile</a>, <a href="#doxygen-input">input</a>,
        <a href="#doxygen-input_encoding">input_encoding</a>, <a href="#doxygen-input_file_encoding">input_file_encoding</a>, <a href="#doxygen-file_patterns">file_patterns</a>, <a href="#doxygen-recursive">recursive</a>, <a href="#doxygen-exclude">exclude</a>, <a href="#doxygen-exclude_symlinks">exclude_symlinks</a>,
        <a href="#doxygen-exclude_patterns">exclude_patterns</a>, <a href="#doxygen-exclude_symbols">exclude_symbols</a>, <a href="#doxygen-example_path">example_path</a>, <a href="#doxygen-example_patterns">example_patterns</a>, <a href="#doxygen-example_recursive">example_recursive</a>,
        <a href="#doxygen-image_path">image_path</a>, <a href="#doxygen-input_filter">input_filter</a>, <a href="#doxygen-filter_patterns">filter_patterns</a>, <a href="#doxygen-filter_source_files">filter_source_files</a>, <a href="#doxygen-filter_source_patterns">filter_source_patterns</a>,
        <a href="#doxygen-use_mdfile_as_mainpage">use_mdfile_as_mainpage</a>, <a href="#doxygen-fortran_comment_after">fortran_comment_after</a>, <a href="#doxygen-source_browser">source_browser</a>, <a href="#doxygen-inline_sources">inline_sources</a>,
        <a href="#doxygen-strip_code_comments">strip_code_comments</a>, <a href="#doxygen-referenced_by_relation">referenced_by_relation</a>, <a href="#doxygen-references_relation">references_relation</a>, <a href="#doxygen-references_link_source">references_link_source</a>,
        <a href="#doxygen-source_tooltips">source_tooltips</a>, <a href="#doxygen-use_htags">use_htags</a>, <a href="#doxygen-verbatim_headers">verbatim_headers</a>, <a href="#doxygen-clang_assisted_parsing">clang_assisted_parsing</a>, <a href="#doxygen-clang_add_inc_paths">clang_add_inc_paths</a>,
        <a href="#doxygen-clang_options">clang_options</a>, <a href="#doxygen-clang_database_path">clang_database_path</a>, <a href="#doxygen-alphabetical_index">alphabetical_index</a>, <a href="#doxygen-ignore_prefix">ignore_prefix</a>, <a href="#doxygen-generate_html">generate_html</a>,
        <a href="#doxygen-html_output">html_output</a>, <a href="#doxygen-html_file_extension">html_file_extension</a>, <a href="#doxygen-html_header">html_header</a>, <a href="#doxygen-html_footer">html_footer</a>, <a href="#doxygen-html_stylesheet">html_stylesheet</a>,
        <a href="#doxygen-html_extra_stylesheet">html_extra_stylesheet</a>, <a href="#doxygen-html_extra_files">html_extra_files</a>, <a href="#doxygen-html_colorstyle">html_colorstyle</a>, <a href="#doxygen-html_colorstyle_hue">html_colorstyle_hue</a>,
        <a href="#doxygen-html_colorstyle_sat">html_colorstyle_sat</a>, <a href="#doxygen-html_colorstyle_gamma">html_colorstyle_gamma</a>, <a href="#doxygen-html_dynamic_menus">html_dynamic_menus</a>, <a href="#doxygen-html_dynamic_sections">html_dynamic_sections</a>,
        <a href="#doxygen-html_code_folding">html_code_folding</a>, <a href="#doxygen-html_copy_clipboard">html_copy_clipboard</a>, <a href="#doxygen-html_project_cookie">html_project_cookie</a>, <a href="#doxygen-html_index_num_entries">html_index_num_entries</a>,
        <a href="#doxygen-generate_docset">generate_docset</a>, <a href="#doxygen-docset_feedname">docset_feedname</a>, <a href="#doxygen-docset_feedurl">docset_feedurl</a>, <a href="#doxygen-docset_bundle_id">docset_bundle_id</a>, <a href="#doxygen-docset_publisher_id">docset_publisher_id</a>,
        <a href="#doxygen-docset_publisher_name">docset_publisher_name</a>, <a href="#doxygen-generate_htmlhelp">generate_htmlhelp</a>, <a href="#doxygen-chm_file">chm_file</a>, <a href="#doxygen-hhc_location">hhc_location</a>, <a href="#doxygen-generate_chi">generate_chi</a>,
        <a href="#doxygen-chm_index_encoding">chm_index_encoding</a>, <a href="#doxygen-binary_toc">binary_toc</a>, <a href="#doxygen-toc_expand">toc_expand</a>, <a href="#doxygen-sitemap_url">sitemap_url</a>, <a href="#doxygen-generate_qhp">generate_qhp</a>, <a href="#doxygen-qch_file">qch_file</a>,
        <a href="#doxygen-qhp_namespace">qhp_namespace</a>, <a href="#doxygen-qhp_virtual_folder">qhp_virtual_folder</a>, <a href="#doxygen-qhp_cust_filter_name">qhp_cust_filter_name</a>, <a href="#doxygen-qhp_cust_filter_attrs">qhp_cust_filter_attrs</a>,
        <a href="#doxygen-qhp_sect_filter_attrs">qhp_sect_filter_attrs</a>, <a href="#doxygen-qhg_location">qhg_location</a>, <a href="#doxygen-generate_eclipsehelp">generate_eclipsehelp</a>, <a href="#doxygen-eclipse_doc_id">eclipse_doc_id</a>, <a href="#doxygen-disable_index">disable_index</a>,
        <a href="#doxygen-generate_treeview">generate_treeview</a>, <a href="#doxygen-full_sidebar">full_sidebar</a>, <a href="#doxygen-enum_values_per_line">enum_values_per_line</a>, <a href="#doxygen-show_enum_values">show_enum_values</a>, <a href="#doxygen-treeview_width">treeview_width</a>,
        <a href="#doxygen-ext_links_in_window">ext_links_in_window</a>, <a href="#doxygen-obfuscate_emails">obfuscate_emails</a>, <a href="#doxygen-html_formula_format">html_formula_format</a>, <a href="#doxygen-formula_fontsize">formula_fontsize</a>,
        <a href="#doxygen-formula_macrofile">formula_macrofile</a>, <a href="#doxygen-use_mathjax">use_mathjax</a>, <a href="#doxygen-mathjax_version">mathjax_version</a>, <a href="#doxygen-mathjax_format">mathjax_format</a>, <a href="#doxygen-mathjax_relpath">mathjax_relpath</a>,
        <a href="#doxygen-mathjax_extensions">mathjax_extensions</a>, <a href="#doxygen-mathjax_codefile">mathjax_codefile</a>, <a href="#doxygen-searchengine">searchengine</a>, <a href="#doxygen-server_based_search">server_based_search</a>, <a href="#doxygen-external_search">external_search</a>,
        <a href="#doxygen-searchengine_url">searchengine_url</a>, <a href="#doxygen-searchdata_file">searchdata_file</a>, <a href="#doxygen-external_search_id">external_search_id</a>, <a href="#doxygen-extra_search_mappings">extra_search_mappings</a>, <a href="#doxygen-generate_latex">generate_latex</a>,
        <a href="#doxygen-latex_output">latex_output</a>, <a href="#doxygen-latex_cmd_name">latex_cmd_name</a>, <a href="#doxygen-makeindex_cmd_name">makeindex_cmd_name</a>, <a href="#doxygen-latex_makeindex_cmd">latex_makeindex_cmd</a>, <a href="#doxygen-compact_latex">compact_latex</a>,
        <a href="#doxygen-paper_type">paper_type</a>, <a href="#doxygen-extra_packages">extra_packages</a>, <a href="#doxygen-latex_header">latex_header</a>, <a href="#doxygen-latex_footer">latex_footer</a>, <a href="#doxygen-latex_extra_stylesheet">latex_extra_stylesheet</a>,
        <a href="#doxygen-latex_extra_files">latex_extra_files</a>, <a href="#doxygen-pdf_hyperlinks">pdf_hyperlinks</a>, <a href="#doxygen-use_pdflatex">use_pdflatex</a>, <a href="#doxygen-latex_batchmode">latex_batchmode</a>, <a href="#doxygen-latex_hide_indices">latex_hide_indices</a>,
        <a href="#doxygen-latex_bib_style">latex_bib_style</a>, <a href="#doxygen-latex_emoji_directory">latex_emoji_directory</a>, <a href="#doxygen-generate_rtf">generate_rtf</a>, <a href="#doxygen-rtf_output">rtf_output</a>, <a href="#doxygen-compact_rtf">compact_rtf</a>, <a href="#doxygen-rtf_hyperlinks">rtf_hyperlinks</a>,
        <a href="#doxygen-rtf_stylesheet_file">rtf_stylesheet_file</a>, <a href="#doxygen-rtf_extensions_file">rtf_extensions_file</a>, <a href="#doxygen-rtf_extra_files">rtf_extra_files</a>, <a href="#doxygen-generate_man">generate_man</a>, <a href="#doxygen-man_output">man_output</a>,
        <a href="#doxygen-man_extension">man_extension</a>, <a href="#doxygen-man_subdir">man_subdir</a>, <a href="#doxygen-man_links">man_links</a>, <a href="#doxygen-generate_xml">generate_xml</a>, <a href="#doxygen-xml_output">xml_output</a>, <a href="#doxygen-xml_programlisting">xml_programlisting</a>,
        <a href="#doxygen-xml_ns_memb_file_scope">xml_ns_memb_file_scope</a>, <a href="#doxygen-generate_docbook">generate_docbook</a>, <a href="#doxygen-docbook_output">docbook_output</a>, <a href="#doxygen-generate_autogen_def">generate_autogen_def</a>,
        <a href="#doxygen-generate_sqlite3">generate_sqlite3</a>, <a href="#doxygen-sqlite3_output">sqlite3_output</a>, <a href="#doxygen-sqlite3_recreate_db">sqlite3_recreate_db</a>, <a href="#doxygen-generate_perlmod">generate_perlmod</a>, <a href="#doxygen-perlmod_latex">perlmod_latex</a>,
        <a href="#doxygen-perlmod_pretty">perlmod_pretty</a>, <a href="#doxygen-perlmod_makevar_prefix">perlmod_makevar_prefix</a>, <a href="#doxygen-enable_preprocessing">enable_preprocessing</a>, <a href="#doxygen-macro_expansion">macro_expansion</a>,
        <a href="#doxygen-expand_only_predef">expand_only_predef</a>, <a href="#doxygen-search_includes">search_includes</a>, <a href="#doxygen-include_path">include_path</a>, <a href="#doxygen-include_file_patterns">include_file_patterns</a>, <a href="#doxygen-predefined">predefined</a>,
        <a href="#doxygen-expand_as_defined">expand_as_defined</a>, <a href="#doxygen-skip_function_macros">skip_function_macros</a>, <a href="#doxygen-tagfiles">tagfiles</a>, <a href="#doxygen-generate_tagfile">generate_tagfile</a>, <a href="#doxygen-allexternals">allexternals</a>,
        <a href="#doxygen-external_groups">external_groups</a>, <a href="#doxygen-external_pages">external_pages</a>, <a href="#doxygen-hide_undoc_relations">hide_undoc_relations</a>, <a href="#doxygen-have_dot">have_dot</a>, <a href="#doxygen-dot_num_threads">dot_num_threads</a>,
        <a href="#doxygen-dot_common_attr">dot_common_attr</a>, <a href="#doxygen-dot_edge_attr">dot_edge_attr</a>, <a href="#doxygen-dot_node_attr">dot_node_attr</a>, <a href="#doxygen-dot_fontpath">dot_fontpath</a>, <a href="#doxygen-dot_transparent">dot_transparent</a>, <a href="#doxygen-class_graph">class_graph</a>,
        <a href="#doxygen-collaboration_graph">collaboration_graph</a>, <a href="#doxygen-group_graphs">group_graphs</a>, <a href="#doxygen-uml_look">uml_look</a>, <a href="#doxygen-uml_limit_num_fields">uml_limit_num_fields</a>, <a href="#doxygen-dot_uml_details">dot_uml_details</a>,
        <a href="#doxygen-dot_wrap_threshold">dot_wrap_threshold</a>, <a href="#doxygen-template_relations">template_relations</a>, <a href="#doxygen-include_graph">include_graph</a>, <a href="#doxygen-included_by_graph">included_by_graph</a>, <a href="#doxygen-call_graph">call_graph</a>,
        <a href="#doxygen-caller_graph">caller_graph</a>, <a href="#doxygen-graphical_hierarchy">graphical_hierarchy</a>, <a href="#doxygen-directory_graph">directory_graph</a>, <a href="#doxygen-dir_graph_max_depth">dir_graph_max_depth</a>, <a href="#doxygen-dot_image_format">dot_image_format</a>,
        <a href="#doxygen-interactive_svg">interactive_svg</a>, <a href="#doxygen-dot_path">dot_path</a>, <a href="#doxygen-dotfile_dirs">dotfile_dirs</a>, <a href="#doxygen-dia_path">dia_path</a>, <a href="#doxygen-diafile_dirs">diafile_dirs</a>, <a href="#doxygen-plantuml_jar_path">plantuml_jar_path</a>,
        <a href="#doxygen-plantuml_cfg_file">plantuml_cfg_file</a>, <a href="#doxygen-plantuml_include_path">plantuml_include_path</a>, <a href="#doxygen-dot_graph_max_nodes">dot_graph_max_nodes</a>, <a href="#doxygen-max_dot_graph_depth">max_dot_graph_depth</a>,
        <a href="#doxygen-dot_multi_targets">dot_multi_targets</a>, <a href="#doxygen-generate_legend">generate_legend</a>, <a href="#doxygen-dot_cleanup">dot_cleanup</a>, <a href="#doxygen-mscgen_tool">mscgen_tool</a>, <a href="#doxygen-mscfile_dirs">mscfile_dirs</a>, <a href="#doxygen-kwargs">**kwargs</a>)
</pre>

Generates documentation using Doxygen.

The set of attributes the macro provides is a subset of the Doxygen configuration options.
Depending on the type of the attribute, the macro will convert it to the appropriate string:

- None (default): the attribute will not be included in the Doxyfile
- bool: the value of the attribute is the string "YES" or "NO" respectively
- list: the value of the attribute is a string with the elements separated by spaces and enclosed in double quotes
- str: the value of the attribute is will be set to the string, unchanged. You may need to provide proper quoting if the value contains spaces

### Example

```starlark
# MODULE.bazel file
bazel_dep(name = "rules_doxygen", dev_dependency = True)
doxygen_extension = use_extension("@rules_doxygen//:extensions.bzl", "doxygen_extension")
use_repo(doxygen_extension, "doxygen")
```

```starlark
# BUILD.bazel file
load("@doxygen//:doxygen.bzl", "doxygen")

doxygen(
    name = "doxygen",
    srcs = glob([
        "*.h",
        "*.cpp",
    ]),
    aliases = [
        "licence=@par Licence:^^",
        "verb{1}=@verbatim \\1 @endverbatim",
    ],
    optimize_output_for_c = True,
    project_brief = "Example project for doxygen",
    project_name = "example",
)
```


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="doxygen-name"></a>name |  A name for the target.   |  none |
| <a id="doxygen-srcs"></a>srcs |  A list of source files to generate documentation for.   |  none |
| <a id="doxygen-dot_executable"></a>dot_executable |  Label of the doxygen executable. Make sure it is also added to the `srcs` of the macro   |  `None` |
| <a id="doxygen-configurations"></a>configurations |  A list of additional configuration parameters to pass to Doxygen.   |  `None` |
| <a id="doxygen-doxyfile_template"></a>doxyfile_template |  The template file to use to generate the Doxyfile. The following substitutions are available:<br> - `# {{INPUT}}`: Subpackage directory in the sandbox.<br> - `# {{ADDITIONAL PARAMETERS}}`: Additional parameters given in the `configurations` attribute.<br> - `# {{OUTPUT DIRECTORY}}`: The directory provided in the `outs` attribute.   |  `None` |
| <a id="doxygen-doxygen_extra_args"></a>doxygen_extra_args |  Extra arguments to pass to the doxygen executable.   |  `[]` |
| <a id="doxygen-outs"></a>outs |  The output folders bazel will keep. If only the html outputs is of interest, the default value will do. otherwise, a list of folders to keep is expected (e.g. ["html", "latex"]).   |  `["html"]` |
| <a id="doxygen-doxyfile_encoding"></a>doxyfile_encoding |  This tag specifies the encoding used for all characters in the configuration file that follow.   |  `None` |
| <a id="doxygen-project_name"></a>project_name |  The `project_name` tag is a single word (or a sequence of words surrounded by double-quotes, unless you are using Doxywizard) that should identify the project for which the documentation is generated.   |  `None` |
| <a id="doxygen-project_number"></a>project_number |  The `project_number` tag can be used to enter a project or revision number.   |  `None` |
| <a id="doxygen-project_brief"></a>project_brief |  Using the `project_brief` tag one can provide an optional one line description for a project that appears at the top of each page and should give viewer a quick idea about the purpose of the project.   |  `None` |
| <a id="doxygen-project_logo"></a>project_logo |  With the `project_logo` tag one can specify a logo or an icon that is included in the documentation.   |  `None` |
| <a id="doxygen-project_icon"></a>project_icon |  With the `project_icon` tag one can specify an icon that is included in the tabs when the HTML document is shown.   |  `None` |
| <a id="doxygen-create_subdirs"></a>create_subdirs |  If the `create_subdirs` tag is set to `True` then Doxygen will create up to 4096 sub-directories (in 2 levels) under the output directory of each output format and will distribute the generated files over these directories.   |  `None` |
| <a id="doxygen-create_subdirs_level"></a>create_subdirs_level |  Controls the number of sub-directories that will be created when `create_subdirs` tag is set to `True`.   |  `None` |
| <a id="doxygen-allow_unicode_names"></a>allow_unicode_names |  If the `allow_unicode_names` tag is set to `True`, Doxygen will allow non-ASCII characters to appear in the names of generated files.   |  `None` |
| <a id="doxygen-output_language"></a>output_language |  The `output_language` tag is used to specify the language in which all documentation generated by Doxygen is written.   |  `None` |
| <a id="doxygen-brief_member_desc"></a>brief_member_desc |  If the `brief_member_desc` tag is set to `True`, Doxygen will include brief member descriptions after the members that are listed in the file and class documentation (similar to Javadoc).   |  `None` |
| <a id="doxygen-repeat_brief"></a>repeat_brief |  If the `repeat_brief` tag is set to `True`, Doxygen will prepend the brief description of a member or function before the detailed description Note: If both `hide_undoc_members` and `brief_member_desc` are set to `False`, the brief descriptions will be completely suppressed.   |  `None` |
| <a id="doxygen-abbreviate_brief"></a>abbreviate_brief |  This tag implements a quasi-intelligent brief description abbreviator that is used to form the text in various listings.   |  `None` |
| <a id="doxygen-always_detailed_sec"></a>always_detailed_sec |  If the `always_detailed_sec` and `repeat_brief` tags are both set to `True` then Doxygen will generate a detailed section even if there is only a brief description.   |  `None` |
| <a id="doxygen-inline_inherited_memb"></a>inline_inherited_memb |  If the `inline_inherited_memb` tag is set to `True`, Doxygen will show all inherited members of a class in the documentation of that class as if those members were ordinary class members.   |  `None` |
| <a id="doxygen-full_path_names"></a>full_path_names |  If the `full_path_names` tag is set to `True`, Doxygen will prepend the full path before files name in the file list and in the header files.   |  `None` |
| <a id="doxygen-strip_from_path"></a>strip_from_path |  The `strip_from_path` tag can be used to strip a user-defined part of the path.   |  `None` |
| <a id="doxygen-strip_from_inc_path"></a>strip_from_inc_path |  The `strip_from_inc_path` tag can be used to strip a user-defined part of the path mentioned in the documentation of a class, which tells the reader which header file to include in order to use a class.   |  `None` |
| <a id="doxygen-short_names"></a>short_names |  If the `short_names` tag is set to `True`, Doxygen will generate much shorter (but less readable) file names.   |  `None` |
| <a id="doxygen-javadoc_autobrief"></a>javadoc_autobrief |  If the `javadoc_autobrief` tag is set to `True` then Doxygen will interpret the first line (until the first dot) of a Javadoc-style comment as the brief description.   |  `None` |
| <a id="doxygen-javadoc_banner"></a>javadoc_banner |  If the `javadoc_banner` tag is set to `True` then Doxygen will interpret a line such as /*************** as being the beginning of a Javadoc-style comment "banner".   |  `None` |
| <a id="doxygen-qt_autobrief"></a>qt_autobrief |  If the `qt_autobrief` tag is set to `True` then Doxygen will interpret the first line (until the first dot) of a Qt-style comment as the brief description.   |  `None` |
| <a id="doxygen-multiline_cpp_is_brief"></a>multiline_cpp_is_brief |  The `multiline_cpp_is_brief` tag can be set to `True` to make Doxygen treat a multi-line C++ special comment block (i.e. a block of //! or /// comments) as a brief description.   |  `None` |
| <a id="doxygen-python_docstring"></a>python_docstring |  By default Python docstrings are displayed as preformatted text and Doxygen's special commands cannot be used.   |  `None` |
| <a id="doxygen-inherit_docs"></a>inherit_docs |  If the `inherit_docs` tag is set to `True` then an undocumented member inherits the documentation from any documented member that it re-implements.   |  `None` |
| <a id="doxygen-separate_member_pages"></a>separate_member_pages |  If the `separate_member_pages` tag is set to `True` then Doxygen will produce a new page for each member.   |  `None` |
| <a id="doxygen-tab_size"></a>tab_size |  The `tab_size` tag can be used to set the number of spaces in a tab.   |  `None` |
| <a id="doxygen-aliases"></a>aliases |  This tag can be used to specify a number of aliases that act as commands in the documentation.   |  `None` |
| <a id="doxygen-optimize_output_for_c"></a>optimize_output_for_c |  Set the `optimize_output_for_c` tag to `True` if your project consists of C sources only.   |  `None` |
| <a id="doxygen-optimize_output_java"></a>optimize_output_java |  Set the `optimize_output_java` tag to `True` if your project consists of Java or Python sources only.   |  `None` |
| <a id="doxygen-optimize_for_fortran"></a>optimize_for_fortran |  Set the `optimize_for_fortran` tag to `True` if your project consists of Fortran sources.   |  `None` |
| <a id="doxygen-optimize_output_vhdl"></a>optimize_output_vhdl |  Set the `optimize_output_vhdl` tag to `True` if your project consists of VHDL sources.   |  `None` |
| <a id="doxygen-optimize_output_slice"></a>optimize_output_slice |  Set the `optimize_output_slice` tag to `True` if your project consists of Slice sources only.   |  `None` |
| <a id="doxygen-extension_mapping"></a>extension_mapping |  Doxygen selects the parser to use depending on the extension of the files it parses.   |  `None` |
| <a id="doxygen-markdown_support"></a>markdown_support |  If the `markdown_support` tag is enabled then Doxygen pre-processes all comments according to the Markdown format, which allows for more readable documentation.   |  `None` |
| <a id="doxygen-toc_include_headings"></a>toc_include_headings |  When the `toc_include_headings` tag is set to a non-zero value, all headings up to that level are automatically included in the table of contents, even if they do not have an id attribute.   |  `None` |
| <a id="doxygen-markdown_id_style"></a>markdown_id_style |  The `markdown_id_style` tag can be used to specify the algorithm used to generate identifiers for the Markdown headings.   |  `None` |
| <a id="doxygen-autolink_support"></a>autolink_support |  When enabled Doxygen tries to link words that correspond to documented classes, or namespaces to their corresponding documentation.   |  `None` |
| <a id="doxygen-builtin_stl_support"></a>builtin_stl_support |  If you use STL classes (i.e. std::string, std::vector, etc.) but do not want to include (a tag file for) the STL sources as input, then you should set this tag to `True` in order to let Doxygen match functions declarations and definitions whose arguments contain STL classes (e.g. func(std::string); versus func(std::string) {}).   |  `None` |
| <a id="doxygen-cpp_cli_support"></a>cpp_cli_support |  If you use Microsoft's C++/CLI language, you should set this option to `True` to enable parsing support.   |  `None` |
| <a id="doxygen-sip_support"></a>sip_support |  Set the `sip_support` tag to `True` if your project consists of sip (see: https://www.riverbankcomputing.com/software) sources only.   |  `None` |
| <a id="doxygen-idl_property_support"></a>idl_property_support |  For Microsoft's IDL there are propget and propput attributes to indicate getter and setter methods for a property.   |  `None` |
| <a id="doxygen-distribute_group_doc"></a>distribute_group_doc |  If member grouping is used in the documentation and the `distribute_group_doc` tag is set to `True` then Doxygen will reuse the documentation of the first member in the group (if any) for the other members of the group.   |  `None` |
| <a id="doxygen-group_nested_compounds"></a>group_nested_compounds |  If one adds a struct or class to a group and this option is enabled, then also any nested class or struct is added to the same group.   |  `None` |
| <a id="doxygen-subgrouping"></a>subgrouping |  Set the `subgrouping` tag to `True` to allow class member groups of the same type (for instance a group of public functions) to be put as a subgroup of that type (e.g. under the Public Functions section).   |  `None` |
| <a id="doxygen-inline_grouped_classes"></a>inline_grouped_classes |  When the `inline_grouped_classes` tag is set to `True`, classes, structs and unions are shown inside the group in which they are included (e.g. using \ingroup) instead of on a separate page (for HTML and Man pages) or section (for LaTeX and RTF).   |  `None` |
| <a id="doxygen-inline_simple_structs"></a>inline_simple_structs |  When the `inline_simple_structs` tag is set to `True`, structs, classes, and unions with only public data fields or simple typedef fields will be shown inline in the documentation of the scope in which they are defined (i.e. file, namespace, or group documentation), provided this scope is documented.   |  `None` |
| <a id="doxygen-typedef_hides_struct"></a>typedef_hides_struct |  When `typedef_hides_struct` tag is enabled, a typedef of a struct, union, or enum is documented as struct, union, or enum with the name of the typedef.   |  `None` |
| <a id="doxygen-lookup_cache_size"></a>lookup_cache_size |  The size of the symbol lookup cache can be set using `lookup_cache_size`.   |  `None` |
| <a id="doxygen-num_proc_threads"></a>num_proc_threads |  The `num_proc_threads` specifies the number of threads Doxygen is allowed to use during processing.   |  `None` |
| <a id="doxygen-timestamp"></a>timestamp |  If the `timestamp` tag is set different from `False` then each generated page will contain the date or date and time when the page was generated.   |  `None` |
| <a id="doxygen-extract_all"></a>extract_all |  If the `extract_all` tag is set to `True`, Doxygen will assume all entities in documentation are documented, even if no documentation was available.   |  `None` |
| <a id="doxygen-extract_private"></a>extract_private |  If the `extract_private` tag is set to `True`, all private members of a class will be included in the documentation.   |  `None` |
| <a id="doxygen-extract_priv_virtual"></a>extract_priv_virtual |  If the `extract_priv_virtual` tag is set to `True`, documented private virtual methods of a class will be included in the documentation.   |  `None` |
| <a id="doxygen-extract_package"></a>extract_package |  If the `extract_package` tag is set to `True`, all members with package or internal scope will be included in the documentation.   |  `None` |
| <a id="doxygen-extract_static"></a>extract_static |  If the `extract_static` tag is set to `True`, all static members of a file will be included in the documentation.   |  `None` |
| <a id="doxygen-extract_local_classes"></a>extract_local_classes |  If the `extract_local_classes` tag is set to `True`, classes (and structs) defined locally in source files will be included in the documentation.   |  `None` |
| <a id="doxygen-extract_local_methods"></a>extract_local_methods |  This flag is only useful for Objective-C code.   |  `None` |
| <a id="doxygen-extract_anon_nspaces"></a>extract_anon_nspaces |  If this flag is set to `True`, the members of anonymous namespaces will be extracted and appear in the documentation as a namespace called 'anonymous_namespace{file}', where file will be replaced with the base name of the file that contains the anonymous namespace.   |  `None` |
| <a id="doxygen-resolve_unnamed_params"></a>resolve_unnamed_params |  If this flag is set to `True`, the name of an unnamed parameter in a declaration will be determined by the corresponding definition.   |  `None` |
| <a id="doxygen-hide_undoc_members"></a>hide_undoc_members |  If the `hide_undoc_members` tag is set to `True`, Doxygen will hide all undocumented members inside documented classes or files.   |  `None` |
| <a id="doxygen-hide_undoc_classes"></a>hide_undoc_classes |  If the `hide_undoc_classes` tag is set to `True`, Doxygen will hide all undocumented classes that are normally visible in the class hierarchy.   |  `None` |
| <a id="doxygen-hide_friend_compounds"></a>hide_friend_compounds |  If the `hide_friend_compounds` tag is set to `True`, Doxygen will hide all friend declarations.   |  `None` |
| <a id="doxygen-hide_in_body_docs"></a>hide_in_body_docs |  If the `hide_in_body_docs` tag is set to `True`, Doxygen will hide any documentation blocks found inside the body of a function.   |  `None` |
| <a id="doxygen-internal_docs"></a>internal_docs |  The `internal_docs` tag determines if documentation that is typed after a \internal command is included.   |  `None` |
| <a id="doxygen-case_sense_names"></a>case_sense_names |  With the correct setting of option `case_sense_names` Doxygen will better be able to match the capabilities of the underlying filesystem.   |  `None` |
| <a id="doxygen-hide_scope_names"></a>hide_scope_names |  If the `hide_scope_names` tag is set to `False` then Doxygen will show members with their full class and namespace scopes in the documentation.   |  `None` |
| <a id="doxygen-hide_compound_reference"></a>hide_compound_reference |  If the `hide_compound_reference` tag is set to `False` (default) then Doxygen will append additional text to a page's title, such as Class Reference.   |  `None` |
| <a id="doxygen-show_headerfile"></a>show_headerfile |  If the `show_headerfile` tag is set to `True` then the documentation for a class will show which file needs to be included to use the class.   |  `None` |
| <a id="doxygen-show_include_files"></a>show_include_files |  If the `show_include_files` tag is set to `True` then Doxygen will put a list of the files that are included by a file in the documentation of that file.   |  `None` |
| <a id="doxygen-show_grouped_memb_inc"></a>show_grouped_memb_inc |  If the `show_grouped_memb_inc` tag is set to `True` then Doxygen will add for each grouped member an include statement to the documentation, telling the reader which file to include in order to use the member.   |  `None` |
| <a id="doxygen-force_local_includes"></a>force_local_includes |  If the `force_local_includes` tag is set to `True` then Doxygen will list include files with double quotes in the documentation rather than with sharp brackets.   |  `None` |
| <a id="doxygen-inline_info"></a>inline_info |  If the `inline_info` tag is set to `True` then a tag [inline] is inserted in the documentation for inline members.   |  `None` |
| <a id="doxygen-sort_member_docs"></a>sort_member_docs |  If the `sort_member_docs` tag is set to `True` then Doxygen will sort the (detailed) documentation of file and class members alphabetically by member name.   |  `None` |
| <a id="doxygen-sort_brief_docs"></a>sort_brief_docs |  If the `sort_brief_docs` tag is set to `True` then Doxygen will sort the brief descriptions of file, namespace and class members alphabetically by member name.   |  `None` |
| <a id="doxygen-sort_members_ctors_1st"></a>sort_members_ctors_1st |  If the `sort_members_ctors_1st` tag is set to `True` then Doxygen will sort the (brief and detailed) documentation of class members so that constructors and destructors are listed first.   |  `None` |
| <a id="doxygen-sort_group_names"></a>sort_group_names |  If the `sort_group_names` tag is set to `True` then Doxygen will sort the hierarchy of group names into alphabetical order.   |  `None` |
| <a id="doxygen-sort_by_scope_name"></a>sort_by_scope_name |  If the `sort_by_scope_name` tag is set to `True`, the class list will be sorted by fully-qualified names, including namespaces.   |  `None` |
| <a id="doxygen-strict_proto_matching"></a>strict_proto_matching |  If the `strict_proto_matching` option is enabled and Doxygen fails to do proper type resolution of all parameters of a function it will reject a match between the prototype and the implementation of a member function even if there is only one candidate or it is obvious which candidate to choose by doing a simple string match.   |  `None` |
| <a id="doxygen-generate_todolist"></a>generate_todolist |  The `generate_todolist` tag can be used to enable (YES) or disable (NO) the todo list.   |  `None` |
| <a id="doxygen-generate_testlist"></a>generate_testlist |  The `generate_testlist` tag can be used to enable (YES) or disable (NO) the test list.   |  `None` |
| <a id="doxygen-generate_buglist"></a>generate_buglist |  The `generate_buglist` tag can be used to enable (YES) or disable (NO) the bug list.   |  `None` |
| <a id="doxygen-generate_deprecatedlist"></a>generate_deprecatedlist |  The `generate_deprecatedlist` tag can be used to enable (YES) or disable (NO) the deprecated list.   |  `None` |
| <a id="doxygen-enabled_sections"></a>enabled_sections |  The `enabled_sections` tag can be used to enable conditional documentation sections, marked by \if <section_label> ... \endif and \cond <section_label> ... \endcond blocks.   |  `None` |
| <a id="doxygen-max_initializer_lines"></a>max_initializer_lines |  The `max_initializer_lines` tag determines the maximum number of lines that the initial value of a variable or macro / define can have for it to appear in the documentation.   |  `None` |
| <a id="doxygen-show_used_files"></a>show_used_files |  Set the `show_used_files` tag to `False` to disable the list of files generated at the bottom of the documentation of classes and structs.   |  `None` |
| <a id="doxygen-show_files"></a>show_files |  Set the `show_files` tag to `False` to disable the generation of the Files page.   |  `None` |
| <a id="doxygen-show_namespaces"></a>show_namespaces |  Set the `show_namespaces` tag to `False` to disable the generation of the Namespaces page.   |  `None` |
| <a id="doxygen-file_version_filter"></a>file_version_filter |  The `file_version_filter` tag can be used to specify a program or script that Doxygen should invoke to get the current version for each file (typically from the version control system).   |  `None` |
| <a id="doxygen-layout_file"></a>layout_file |  The `layout_file` tag can be used to specify a layout file which will be parsed by Doxygen.   |  `None` |
| <a id="doxygen-cite_bib_files"></a>cite_bib_files |  The `cite_bib_files` tag can be used to specify one or more bib files containing the reference definitions.   |  `None` |
| <a id="doxygen-external_tool_path"></a>external_tool_path |  The `external_tool_path` tag can be used to extend the search path (PATH environment variable) so that external tools such as latex and gs can be found.   |  `None` |
| <a id="doxygen-quiet"></a>quiet |  The `quiet` tag can be used to turn on/off the messages that are generated to standard output by Doxygen.   |  `None` |
| <a id="doxygen-warnings"></a>warnings |  The `warnings` tag can be used to turn on/off the warning messages that are generated to standard error (stderr) by Doxygen.   |  `None` |
| <a id="doxygen-warn_if_undocumented"></a>warn_if_undocumented |  If the `warn_if_undocumented` tag is set to `True` then Doxygen will generate warnings for undocumented members.   |  `None` |
| <a id="doxygen-warn_if_doc_error"></a>warn_if_doc_error |  If the `warn_if_doc_error` tag is set to `True`, Doxygen will generate warnings for potential errors in the documentation, such as documenting some parameters in a documented function twice, or documenting parameters that don't exist or using markup commands wrongly.   |  `None` |
| <a id="doxygen-warn_if_incomplete_doc"></a>warn_if_incomplete_doc |  If `warn_if_incomplete_doc` is set to `True`, Doxygen will warn about incomplete function parameter documentation.   |  `None` |
| <a id="doxygen-warn_no_paramdoc"></a>warn_no_paramdoc |  This `warn_no_paramdoc` option can be enabled to get warnings for functions that are documented, but have no documentation for their parameters or return value.   |  `None` |
| <a id="doxygen-warn_if_undoc_enum_val"></a>warn_if_undoc_enum_val |  If `warn_if_undoc_enum_val` option is set to `True`, Doxygen will warn about undocumented enumeration values.   |  `None` |
| <a id="doxygen-warn_as_error"></a>warn_as_error |  If the `warn_as_error` tag is set to `True` then Doxygen will immediately stop when a warning is encountered.   |  `None` |
| <a id="doxygen-warn_format"></a>warn_format |  The `warn_format` tag determines the format of the warning messages that Doxygen can produce.   |  `None` |
| <a id="doxygen-warn_line_format"></a>warn_line_format |  In the $text part of the `warn_format` command it is possible that a reference to a more specific place is given.   |  `None` |
| <a id="doxygen-warn_logfile"></a>warn_logfile |  The `warn_logfile` tag can be used to specify a file to which warning and error messages should be written.   |  `None` |
| <a id="doxygen-input"></a>input |  The `input` tag is used to specify the files and/or directories that contain documented source files.   |  `None` |
| <a id="doxygen-input_encoding"></a>input_encoding |  This tag can be used to specify the character encoding of the source files that Doxygen parses.   |  `None` |
| <a id="doxygen-input_file_encoding"></a>input_file_encoding |  This tag can be used to specify the character encoding of the source files that Doxygen parses The `input_file_encoding` tag can be used to specify character encoding on a per file pattern basis.   |  `None` |
| <a id="doxygen-file_patterns"></a>file_patterns |  If the value of the `input` tag contains directories, you can use the `file_patterns` tag to specify one or more wildcard patterns (like *.cpp and *.h) to filter out the source-files in the directories.   |  `None` |
| <a id="doxygen-recursive"></a>recursive |  The `recursive` tag can be used to specify whether or not subdirectories should be searched for input files as well.   |  `None` |
| <a id="doxygen-exclude"></a>exclude |  The `exclude` tag can be used to specify files and/or directories that should be excluded from the `input` source files.   |  `None` |
| <a id="doxygen-exclude_symlinks"></a>exclude_symlinks |  The `exclude_symlinks` tag can be used to select whether or not files or directories that are symbolic links (a Unix file system feature) are excluded from the input.   |  `None` |
| <a id="doxygen-exclude_patterns"></a>exclude_patterns |  If the value of the `input` tag contains directories, you can use the `exclude_patterns` tag to specify one or more wildcard patterns to exclude certain files from those directories.   |  `None` |
| <a id="doxygen-exclude_symbols"></a>exclude_symbols |  The `exclude_symbols` tag can be used to specify one or more symbol names (namespaces, classes, functions, etc.) that should be excluded from the output.   |  `None` |
| <a id="doxygen-example_path"></a>example_path |  The `example_path` tag can be used to specify one or more files or directories that contain example code fragments that are included (see the \include command).   |  `None` |
| <a id="doxygen-example_patterns"></a>example_patterns |  If the value of the `example_path` tag contains directories, you can use the `example_patterns` tag to specify one or more wildcard pattern (like *.cpp and *.h) to filter out the source-files in the directories.   |  `None` |
| <a id="doxygen-example_recursive"></a>example_recursive |  If the `example_recursive` tag is set to `True` then subdirectories will be searched for input files to be used with the \include or \dontinclude commands irrespective of the value of the `recursive` tag.   |  `None` |
| <a id="doxygen-image_path"></a>image_path |  The `image_path` tag can be used to specify one or more files or directories that contain images that are to be included in the documentation (see the \image command).   |  `None` |
| <a id="doxygen-input_filter"></a>input_filter |  The `input_filter` tag can be used to specify a program that Doxygen should invoke to filter for each input file.   |  `None` |
| <a id="doxygen-filter_patterns"></a>filter_patterns |  The `filter_patterns` tag can be used to specify filters on a per file pattern basis.   |  `None` |
| <a id="doxygen-filter_source_files"></a>filter_source_files |  If the `filter_source_files` tag is set to `True`, the input filter (if set using `input_filter`) will also be used to filter the input files that are used for producing the source files to browse (i.e. when `source_browser` is set to `True`).   |  `None` |
| <a id="doxygen-filter_source_patterns"></a>filter_source_patterns |  The `filter_source_patterns` tag can be used to specify source filters per file pattern.   |  `None` |
| <a id="doxygen-use_mdfile_as_mainpage"></a>use_mdfile_as_mainpage |  If the `use_mdfile_as_mainpage` tag refers to the name of a markdown file that is part of the input, its contents will be placed on the main page (index.html).   |  `None` |
| <a id="doxygen-fortran_comment_after"></a>fortran_comment_after |  The Fortran standard specifies that for fixed formatted Fortran code all characters from position 72 are to be considered as comment.   |  `None` |
| <a id="doxygen-source_browser"></a>source_browser |  If the `source_browser` tag is set to `True` then a list of source files will be generated.   |  `None` |
| <a id="doxygen-inline_sources"></a>inline_sources |  Setting the `inline_sources` tag to `True` will include the body of functions, multi-line macros, enums or list initialized variables directly into the documentation.   |  `None` |
| <a id="doxygen-strip_code_comments"></a>strip_code_comments |  Setting the `strip_code_comments` tag to `True` will instruct Doxygen to hide any special comment blocks from generated source code fragments.   |  `None` |
| <a id="doxygen-referenced_by_relation"></a>referenced_by_relation |  If the `referenced_by_relation` tag is set to `True` then for each documented entity all documented functions referencing it will be listed.   |  `None` |
| <a id="doxygen-references_relation"></a>references_relation |  If the `references_relation` tag is set to `True` then for each documented function all documented entities called/used by that function will be listed.   |  `None` |
| <a id="doxygen-references_link_source"></a>references_link_source |  If the `references_link_source` tag is set to `True` and `source_browser` tag is set to `True` then the hyperlinks from functions in `references_relation` and `referenced_by_relation` lists will link to the source code.   |  `None` |
| <a id="doxygen-source_tooltips"></a>source_tooltips |  If `source_tooltips` is enabled (the default) then hovering a hyperlink in the source code will show a tooltip with additional information such as prototype, brief description and links to the definition and documentation.   |  `None` |
| <a id="doxygen-use_htags"></a>use_htags |  If the `use_htags` tag is set to `True` then the references to source code will point to the HTML generated by the htags(1) tool instead of Doxygen built-in source browser.   |  `None` |
| <a id="doxygen-verbatim_headers"></a>verbatim_headers |  If the `verbatim_headers` tag is set the `True` then Doxygen will generate a verbatim copy of the header file for each class for which an include is specified.   |  `None` |
| <a id="doxygen-clang_assisted_parsing"></a>clang_assisted_parsing |  If the `clang_assisted_parsing` tag is set to `True` then Doxygen will use the clang parser (see: http://clang.llvm.org/) for more accurate parsing at the cost of reduced performance.   |  `None` |
| <a id="doxygen-clang_add_inc_paths"></a>clang_add_inc_paths |  If the `clang_assisted_parsing` tag is set to `True` and the `clang_add_inc_paths` tag is set to `True` then Doxygen will add the directory of each input to the include path.   |  `None` |
| <a id="doxygen-clang_options"></a>clang_options |  If clang assisted parsing is enabled you can provide the compiler with command line options that you would normally use when invoking the compiler.   |  `None` |
| <a id="doxygen-clang_database_path"></a>clang_database_path |  If clang assisted parsing is enabled you can provide the clang parser with the path to the directory containing a file called compile_commands.json.   |  `None` |
| <a id="doxygen-alphabetical_index"></a>alphabetical_index |  If the `alphabetical_index` tag is set to `True`, an alphabetical index of all compounds will be generated.   |  `None` |
| <a id="doxygen-ignore_prefix"></a>ignore_prefix |  The `ignore_prefix` tag can be used to specify a prefix (or a list of prefixes) that should be ignored while generating the index headers.   |  `None` |
| <a id="doxygen-generate_html"></a>generate_html |  If the `generate_html` tag is set to `True`, Doxygen will generate HTML output The default value is: `True`.   |  `None` |
| <a id="doxygen-html_output"></a>html_output |  The `html_output` tag is used to specify where the HTML docs will be put.   |  `None` |
| <a id="doxygen-html_file_extension"></a>html_file_extension |  The `html_file_extension` tag can be used to specify the file extension for each generated HTML page (for example: .htm, .php, .asp).   |  `None` |
| <a id="doxygen-html_header"></a>html_header |  The `html_header` tag can be used to specify a user-defined HTML header file for each generated HTML page.   |  `None` |
| <a id="doxygen-html_footer"></a>html_footer |  The `html_footer` tag can be used to specify a user-defined HTML footer for each generated HTML page.   |  `None` |
| <a id="doxygen-html_stylesheet"></a>html_stylesheet |  The `html_stylesheet` tag can be used to specify a user-defined cascading style sheet that is used by each HTML page.   |  `None` |
| <a id="doxygen-html_extra_stylesheet"></a>html_extra_stylesheet |  The `html_extra_stylesheet` tag can be used to specify additional user-defined cascading style sheets that are included after the standard style sheets created by Doxygen.   |  `None` |
| <a id="doxygen-html_extra_files"></a>html_extra_files |  The `html_extra_files` tag can be used to specify one or more extra images or other source files which should be copied to the HTML output directory.   |  `None` |
| <a id="doxygen-html_colorstyle"></a>html_colorstyle |  The `html_colorstyle` tag can be used to specify if the generated HTML output should be rendered with a dark or light theme.   |  `None` |
| <a id="doxygen-html_colorstyle_hue"></a>html_colorstyle_hue |  The `html_colorstyle_hue` tag controls the color of the HTML output.   |  `None` |
| <a id="doxygen-html_colorstyle_sat"></a>html_colorstyle_sat |  The `html_colorstyle_sat` tag controls the purity (or saturation) of the colors in the HTML output.   |  `None` |
| <a id="doxygen-html_colorstyle_gamma"></a>html_colorstyle_gamma |  The `html_colorstyle_gamma` tag controls the gamma correction applied to the luminance component of the colors in the HTML output.   |  `None` |
| <a id="doxygen-html_dynamic_menus"></a>html_dynamic_menus |  If the `html_dynamic_menus` tag is set to `True` then the generated HTML documentation will contain a main index with vertical navigation menus that are dynamically created via JavaScript.   |  `None` |
| <a id="doxygen-html_dynamic_sections"></a>html_dynamic_sections |  If the `html_dynamic_sections` tag is set to `True` then the generated HTML documentation will contain sections that can be hidden and shown after the page has loaded.   |  `None` |
| <a id="doxygen-html_code_folding"></a>html_code_folding |  If the `html_code_folding` tag is set to `True` then classes and functions can be dynamically folded and expanded in the generated HTML source code.   |  `None` |
| <a id="doxygen-html_copy_clipboard"></a>html_copy_clipboard |  If the `html_copy_clipboard` tag is set to `True` then Doxygen will show an icon in the top right corner of code and text fragments that allows the user to copy its content to the clipboard.   |  `None` |
| <a id="doxygen-html_project_cookie"></a>html_project_cookie |  Doxygen stores a couple of settings persistently in the browser (via e.g. cookies).   |  `None` |
| <a id="doxygen-html_index_num_entries"></a>html_index_num_entries |  With `html_index_num_entries` one can control the preferred number of entries shown in the various tree structured indices initially; the user can expand and collapse entries dynamically later on.   |  `None` |
| <a id="doxygen-generate_docset"></a>generate_docset |  If the `generate_docset` tag is set to `True`, additional index files will be generated that can be used as input for Apple's Xcode 3 integrated development environment (see: https://developer.apple.com/xcode/), introduced with OSX 10.5 (Leopard).   |  `None` |
| <a id="doxygen-docset_feedname"></a>docset_feedname |  This tag determines the name of the docset feed.   |  `None` |
| <a id="doxygen-docset_feedurl"></a>docset_feedurl |  This tag determines the URL of the docset feed.   |  `None` |
| <a id="doxygen-docset_bundle_id"></a>docset_bundle_id |  This tag specifies a string that should uniquely identify the documentation set bundle.   |  `None` |
| <a id="doxygen-docset_publisher_id"></a>docset_publisher_id |  The `docset_publisher_id` tag specifies a string that should uniquely identify the documentation publisher.   |  `None` |
| <a id="doxygen-docset_publisher_name"></a>docset_publisher_name |  The `docset_publisher_name` tag identifies the documentation publisher.   |  `None` |
| <a id="doxygen-generate_htmlhelp"></a>generate_htmlhelp |  If the `generate_htmlhelp` tag is set to `True` then Doxygen generates three additional HTML index files: index.hhp, index.hhc, and index.hhk.   |  `None` |
| <a id="doxygen-chm_file"></a>chm_file |  The `chm_file` tag can be used to specify the file name of the resulting .chm file.   |  `None` |
| <a id="doxygen-hhc_location"></a>hhc_location |  The `hhc_location` tag can be used to specify the location (absolute path including file name) of the HTML help compiler (hhc.exe).   |  `None` |
| <a id="doxygen-generate_chi"></a>generate_chi |  The `generate_chi` flag controls if a separate .chi index file is generated (YES) or that it should be included in the main .chm file (NO).   |  `None` |
| <a id="doxygen-chm_index_encoding"></a>chm_index_encoding |  The `chm_index_encoding` is used to encode HtmlHelp index (hhk), content (hhc) and project file content.   |  `None` |
| <a id="doxygen-binary_toc"></a>binary_toc |  The `binary_toc` flag controls whether a binary table of contents is generated (YES) or a normal table of contents (NO) in the .chm file.   |  `None` |
| <a id="doxygen-toc_expand"></a>toc_expand |  The `toc_expand` flag can be set to `True` to add extra items for group members to the table of contents of the HTML help documentation and to the tree view.   |  `None` |
| <a id="doxygen-sitemap_url"></a>sitemap_url |  The `sitemap_url` tag is used to specify the full URL of the place where the generated documentation will be placed on the server by the user during the deployment of the documentation.   |  `None` |
| <a id="doxygen-generate_qhp"></a>generate_qhp |  If the `generate_qhp` tag is set to `True` and both `qhp_namespace` and `qhp_virtual_folder` are set, an additional index file will be generated that can be used as input for Qt's qhelpgenerator to generate a Qt Compressed Help (.qch) of the generated HTML documentation.   |  `None` |
| <a id="doxygen-qch_file"></a>qch_file |  If the `qhg_location` tag is specified, the `qch_file` tag can be used to specify the file name of the resulting .qch file.   |  `None` |
| <a id="doxygen-qhp_namespace"></a>qhp_namespace |  The `qhp_namespace` tag specifies the namespace to use when generating Qt Help Project output.   |  `None` |
| <a id="doxygen-qhp_virtual_folder"></a>qhp_virtual_folder |  The `qhp_virtual_folder` tag specifies the namespace to use when generating Qt Help Project output.   |  `None` |
| <a id="doxygen-qhp_cust_filter_name"></a>qhp_cust_filter_name |  If the `qhp_cust_filter_name` tag is set, it specifies the name of a custom filter to add.   |  `None` |
| <a id="doxygen-qhp_cust_filter_attrs"></a>qhp_cust_filter_attrs |  The `qhp_cust_filter_attrs` tag specifies the list of the attributes of the custom filter to add.   |  `None` |
| <a id="doxygen-qhp_sect_filter_attrs"></a>qhp_sect_filter_attrs |  The `qhp_sect_filter_attrs` tag specifies the list of the attributes this project's filter section matches.   |  `None` |
| <a id="doxygen-qhg_location"></a>qhg_location |  The `qhg_location` tag can be used to specify the location (absolute path including file name) of Qt's qhelpgenerator.   |  `None` |
| <a id="doxygen-generate_eclipsehelp"></a>generate_eclipsehelp |  If the `generate_eclipsehelp` tag is set to `True`, additional index files will be generated, together with the HTML files, they form an Eclipse help plugin.   |  `None` |
| <a id="doxygen-eclipse_doc_id"></a>eclipse_doc_id |  A unique identifier for the Eclipse help plugin.   |  `None` |
| <a id="doxygen-disable_index"></a>disable_index |  If you want full control over the layout of the generated HTML pages it might be necessary to disable the index and replace it with your own.   |  `None` |
| <a id="doxygen-generate_treeview"></a>generate_treeview |  The `generate_treeview` tag is used to specify whether a tree-like index structure should be generated to display hierarchical information.   |  `None` |
| <a id="doxygen-full_sidebar"></a>full_sidebar |  When both `generate_treeview` and `disable_index` are set to `True`, then the `full_sidebar` option determines if the side bar is limited to only the treeview area (value `False`) or if it should extend to the full height of the window (value `True`).   |  `None` |
| <a id="doxygen-enum_values_per_line"></a>enum_values_per_line |  The `enum_values_per_line` tag can be used to set the number of enum values that Doxygen will group on one line in the generated HTML documentation.   |  `None` |
| <a id="doxygen-show_enum_values"></a>show_enum_values |  When the `show_enum_values` tag is set doxygen will show the specified enumeration values besides the enumeration mnemonics.   |  `None` |
| <a id="doxygen-treeview_width"></a>treeview_width |  If the treeview is enabled (see `generate_treeview`) then this tag can be used to set the initial width (in pixels) of the frame in which the tree is shown.   |  `None` |
| <a id="doxygen-ext_links_in_window"></a>ext_links_in_window |  If the `ext_links_in_window` option is set to `True`, Doxygen will open links to external symbols imported via tag files in a separate window.   |  `None` |
| <a id="doxygen-obfuscate_emails"></a>obfuscate_emails |  If the `obfuscate_emails` tag is set to `True`, Doxygen will obfuscate email addresses.   |  `None` |
| <a id="doxygen-html_formula_format"></a>html_formula_format |  If the `html_formula_format` option is set to svg, Doxygen will use the pdf2svg tool (see https://github.com/dawbarton/pdf2svg) or inkscape (see https://inkscape.org) to generate formulas as SVG images instead of PNGs for the HTML output.   |  `None` |
| <a id="doxygen-formula_fontsize"></a>formula_fontsize |  Use this tag to change the font size of LaTeX formulas included as images in the HTML documentation.   |  `None` |
| <a id="doxygen-formula_macrofile"></a>formula_macrofile |  The `formula_macrofile` can contain LaTeX \newcommand and \renewcommand commands to create new LaTeX commands to be used in formulas as building blocks.   |  `None` |
| <a id="doxygen-use_mathjax"></a>use_mathjax |  Enable the `use_mathjax` option to render LaTeX formulas using MathJax (see https://www.mathjax.org) which uses client side JavaScript for the rendering instead of using pre-rendered bitmaps.   |  `None` |
| <a id="doxygen-mathjax_version"></a>mathjax_version |  With `mathjax_version` it is possible to specify the MathJax version to be used.   |  `None` |
| <a id="doxygen-mathjax_format"></a>mathjax_format |  When MathJax is enabled you can set the default output format to be used for the MathJax output.   |  `None` |
| <a id="doxygen-mathjax_relpath"></a>mathjax_relpath |  When MathJax is enabled you need to specify the location relative to the HTML output directory using the `mathjax_relpath` option.   |  `None` |
| <a id="doxygen-mathjax_extensions"></a>mathjax_extensions |  The `mathjax_extensions` tag can be used to specify one or more MathJax extension names that should be enabled during MathJax rendering.   |  `None` |
| <a id="doxygen-mathjax_codefile"></a>mathjax_codefile |  The `mathjax_codefile` tag can be used to specify a file with JavaScript pieces of code that will be used on startup of the MathJax code.   |  `None` |
| <a id="doxygen-searchengine"></a>searchengine |  When the `searchengine` tag is enabled Doxygen will generate a search box for the HTML output.   |  `None` |
| <a id="doxygen-server_based_search"></a>server_based_search |  When the `server_based_search` tag is enabled the search engine will be implemented using a web server instead of a web client using JavaScript.   |  `None` |
| <a id="doxygen-external_search"></a>external_search |  When `external_search` tag is enabled Doxygen will no longer generate the PHP script for searching.   |  `None` |
| <a id="doxygen-searchengine_url"></a>searchengine_url |  The `searchengine_url` should point to a search engine hosted by a web server which will return the search results when `external_search` is enabled.   |  `None` |
| <a id="doxygen-searchdata_file"></a>searchdata_file |  When `server_based_search` and `external_search` are both enabled the unindexed search data is written to a file for indexing by an external tool.   |  `None` |
| <a id="doxygen-external_search_id"></a>external_search_id |  When `server_based_search` and `external_search` are both enabled the `external_search_id` tag can be used as an identifier for the project.   |  `None` |
| <a id="doxygen-extra_search_mappings"></a>extra_search_mappings |  The `extra_search_mappings` tag can be used to enable searching through Doxygen projects other than the one defined by this configuration file, but that are all added to the same external search index.   |  `None` |
| <a id="doxygen-generate_latex"></a>generate_latex |  If the `generate_latex` tag is set to `True`, Doxygen will generate LaTeX output.   |  `None` |
| <a id="doxygen-latex_output"></a>latex_output |  The `latex_output` tag is used to specify where the LaTeX docs will be put.   |  `None` |
| <a id="doxygen-latex_cmd_name"></a>latex_cmd_name |  The `latex_cmd_name` tag can be used to specify the LaTeX command name to be invoked.   |  `None` |
| <a id="doxygen-makeindex_cmd_name"></a>makeindex_cmd_name |  The `makeindex_cmd_name` tag can be used to specify the command name to generate index for LaTeX.   |  `None` |
| <a id="doxygen-latex_makeindex_cmd"></a>latex_makeindex_cmd |  The `latex_makeindex_cmd` tag can be used to specify the command name to generate index for LaTeX.   |  `None` |
| <a id="doxygen-compact_latex"></a>compact_latex |  If the `compact_latex` tag is set to `True`, Doxygen generates more compact LaTeX documents.   |  `None` |
| <a id="doxygen-paper_type"></a>paper_type |  The `paper_type` tag can be used to set the paper type that is used by the printer.   |  `None` |
| <a id="doxygen-extra_packages"></a>extra_packages |  The `extra_packages` tag can be used to specify one or more LaTeX package names that should be included in the LaTeX output.   |  `None` |
| <a id="doxygen-latex_header"></a>latex_header |  The `latex_header` tag can be used to specify a user-defined LaTeX header for the generated LaTeX document.   |  `None` |
| <a id="doxygen-latex_footer"></a>latex_footer |  The `latex_footer` tag can be used to specify a user-defined LaTeX footer for the generated LaTeX document.   |  `None` |
| <a id="doxygen-latex_extra_stylesheet"></a>latex_extra_stylesheet |  The `latex_extra_stylesheet` tag can be used to specify additional user-defined LaTeX style sheets that are included after the standard style sheets created by Doxygen.   |  `None` |
| <a id="doxygen-latex_extra_files"></a>latex_extra_files |  The `latex_extra_files` tag can be used to specify one or more extra images or other source files which should be copied to the `latex_output` output directory.   |  `None` |
| <a id="doxygen-pdf_hyperlinks"></a>pdf_hyperlinks |  If the `pdf_hyperlinks` tag is set to `True`, the LaTeX that is generated is prepared for conversion to PDF (using ps2pdf or pdflatex).   |  `None` |
| <a id="doxygen-use_pdflatex"></a>use_pdflatex |  If the `use_pdflatex` tag is set to `True`, Doxygen will use the engine as specified with `latex_cmd_name` to generate the PDF file directly from the LaTeX files.   |  `None` |
| <a id="doxygen-latex_batchmode"></a>latex_batchmode |  The `latex_batchmode` tag signals the behavior of LaTeX in case of an error.   |  `None` |
| <a id="doxygen-latex_hide_indices"></a>latex_hide_indices |  If the `latex_hide_indices` tag is set to `True` then Doxygen will not include the index chapters (such as File Index, Compound Index, etc.) in the output.   |  `None` |
| <a id="doxygen-latex_bib_style"></a>latex_bib_style |  The `latex_bib_style` tag can be used to specify the style to use for the bibliography, e.g. plainnat, or ieeetr.   |  `None` |
| <a id="doxygen-latex_emoji_directory"></a>latex_emoji_directory |  The `latex_emoji_directory` tag is used to specify the (relative or absolute) path from which the emoji images will be read.   |  `None` |
| <a id="doxygen-generate_rtf"></a>generate_rtf |  If the `generate_rtf` tag is set to `True`, Doxygen will generate RTF output.   |  `None` |
| <a id="doxygen-rtf_output"></a>rtf_output |  The `rtf_output` tag is used to specify where the RTF docs will be put.   |  `None` |
| <a id="doxygen-compact_rtf"></a>compact_rtf |  If the `compact_rtf` tag is set to `True`, Doxygen generates more compact RTF documents.   |  `None` |
| <a id="doxygen-rtf_hyperlinks"></a>rtf_hyperlinks |  If the `rtf_hyperlinks` tag is set to `True`, the RTF that is generated will contain hyperlink fields.   |  `None` |
| <a id="doxygen-rtf_stylesheet_file"></a>rtf_stylesheet_file |  Load stylesheet definitions from file.   |  `None` |
| <a id="doxygen-rtf_extensions_file"></a>rtf_extensions_file |  Set optional variables used in the generation of an RTF document.   |  `None` |
| <a id="doxygen-rtf_extra_files"></a>rtf_extra_files |  The `rtf_extra_files` tag can be used to specify one or more extra images or other source files which should be copied to the `rtf_output` output directory.   |  `None` |
| <a id="doxygen-generate_man"></a>generate_man |  If the `generate_man` tag is set to `True`, Doxygen will generate man pages for classes and files.   |  `None` |
| <a id="doxygen-man_output"></a>man_output |  The `man_output` tag is used to specify where the man pages will be put.   |  `None` |
| <a id="doxygen-man_extension"></a>man_extension |  The `man_extension` tag determines the extension that is added to the generated man pages.   |  `None` |
| <a id="doxygen-man_subdir"></a>man_subdir |  The `man_subdir` tag determines the name of the directory created within `man_output` in which the man pages are placed.   |  `None` |
| <a id="doxygen-man_links"></a>man_links |  If the `man_links` tag is set to `True` and Doxygen generates man output, then it will generate one additional man file for each entity documented in the real man page(s).   |  `None` |
| <a id="doxygen-generate_xml"></a>generate_xml |  If the `generate_xml` tag is set to `True`, Doxygen will generate an XML file that captures the structure of the code including all documentation.   |  `None` |
| <a id="doxygen-xml_output"></a>xml_output |  The `xml_output` tag is used to specify where the XML pages will be put.   |  `None` |
| <a id="doxygen-xml_programlisting"></a>xml_programlisting |  If the `xml_programlisting` tag is set to `True`, Doxygen will dump the program listings (including syntax highlighting and cross-referencing information) to the XML output.   |  `None` |
| <a id="doxygen-xml_ns_memb_file_scope"></a>xml_ns_memb_file_scope |  If the `xml_ns_memb_file_scope` tag is set to `True`, Doxygen will include namespace members in file scope as well, matching the HTML output.   |  `None` |
| <a id="doxygen-generate_docbook"></a>generate_docbook |  If the `generate_docbook` tag is set to `True`, Doxygen will generate Docbook files that can be used to generate PDF.   |  `None` |
| <a id="doxygen-docbook_output"></a>docbook_output |  The `docbook_output` tag is used to specify where the Docbook pages will be put.   |  `None` |
| <a id="doxygen-generate_autogen_def"></a>generate_autogen_def |  If the `generate_autogen_def` tag is set to `True`, Doxygen will generate an AutoGen Definitions (see https://autogen.sourceforge.net/) file that captures the structure of the code including all documentation.   |  `None` |
| <a id="doxygen-generate_sqlite3"></a>generate_sqlite3 |  If the `generate_sqlite3` tag is set to `True` Doxygen will generate a Sqlite3 database with symbols found by Doxygen stored in tables.   |  `None` |
| <a id="doxygen-sqlite3_output"></a>sqlite3_output |  The `sqlite3_output` tag is used to specify where the Sqlite3 database will be put.   |  `None` |
| <a id="doxygen-sqlite3_recreate_db"></a>sqlite3_recreate_db |  The `sqlite3_recreate_db` tag is set to `True`, the existing doxygen_sqlite3.db database file will be recreated with each Doxygen run.   |  `None` |
| <a id="doxygen-generate_perlmod"></a>generate_perlmod |  If the `generate_perlmod` tag is set to `True`, Doxygen will generate a Perl module file that captures the structure of the code including all documentation.   |  `None` |
| <a id="doxygen-perlmod_latex"></a>perlmod_latex |  If the `perlmod_latex` tag is set to `True`, Doxygen will generate the necessary Makefile rules, Perl scripts and LaTeX code to be able to generate PDF and DVI output from the Perl module output.   |  `None` |
| <a id="doxygen-perlmod_pretty"></a>perlmod_pretty |  If the `perlmod_pretty` tag is set to `True`, the Perl module output will be nicely formatted so it can be parsed by a human reader.   |  `None` |
| <a id="doxygen-perlmod_makevar_prefix"></a>perlmod_makevar_prefix |  The names of the make variables in the generated doxyrules.make file are prefixed with the string contained in `perlmod_makevar_prefix`.   |  `None` |
| <a id="doxygen-enable_preprocessing"></a>enable_preprocessing |  If the `enable_preprocessing` tag is set to `True`, Doxygen will evaluate all C-preprocessor directives found in the sources and include files.   |  `None` |
| <a id="doxygen-macro_expansion"></a>macro_expansion |  If the `macro_expansion` tag is set to `True`, Doxygen will expand all macro names in the source code.   |  `None` |
| <a id="doxygen-expand_only_predef"></a>expand_only_predef |  If the `expand_only_predef` and `macro_expansion` tags are both set to `True` then the macro expansion is limited to the macros specified with the `predefined` and `expand_as_defined` tags.   |  `None` |
| <a id="doxygen-search_includes"></a>search_includes |  If the `search_includes` tag is set to `True`, the include files in the `include_path` will be searched if a #include is found.   |  `None` |
| <a id="doxygen-include_path"></a>include_path |  The `include_path` tag can be used to specify one or more directories that contain include files that are not input files but should be processed by the preprocessor.   |  `None` |
| <a id="doxygen-include_file_patterns"></a>include_file_patterns |  You can use the `include_file_patterns` tag to specify one or more wildcard patterns (like *.h and *.hpp) to filter out the header-files in the directories.   |  `None` |
| <a id="doxygen-predefined"></a>predefined |  The `predefined` tag can be used to specify one or more macro names that are defined before the preprocessor is started (similar to the -D option of e.g. gcc).   |  `None` |
| <a id="doxygen-expand_as_defined"></a>expand_as_defined |  If the `macro_expansion` and `expand_only_predef` tags are set to `True` then this tag can be used to specify a list of macro names that should be expanded.   |  `None` |
| <a id="doxygen-skip_function_macros"></a>skip_function_macros |  If the `skip_function_macros` tag is set to `True` then Doxygen's preprocessor will remove all references to function-like macros that are alone on a line, have an all uppercase name, and do not end with a semicolon.   |  `None` |
| <a id="doxygen-tagfiles"></a>tagfiles |  The `tagfiles` tag can be used to specify one or more tag files.   |  `None` |
| <a id="doxygen-generate_tagfile"></a>generate_tagfile |  When a file name is specified after `generate_tagfile`, Doxygen will create a tag file that is based on the input files it reads.   |  `None` |
| <a id="doxygen-allexternals"></a>allexternals |  If the `allexternals` tag is set to `True`, all external classes and namespaces will be listed in the class and namespace index.   |  `None` |
| <a id="doxygen-external_groups"></a>external_groups |  If the `external_groups` tag is set to `True`, all external groups will be listed in the topic index.   |  `None` |
| <a id="doxygen-external_pages"></a>external_pages |  If the `external_pages` tag is set to `True`, all external pages will be listed in the related pages index.   |  `None` |
| <a id="doxygen-hide_undoc_relations"></a>hide_undoc_relations |  If set to `True` the inheritance and collaboration graphs will hide inheritance and usage relations if the target is undocumented or is not a class.   |  `None` |
| <a id="doxygen-have_dot"></a>have_dot |  If you set the `have_dot` tag to `True` then Doxygen will assume the dot tool is available from the path.   |  `None` |
| <a id="doxygen-dot_num_threads"></a>dot_num_threads |  The `dot_num_threads` specifies the number of dot invocations Doxygen is allowed to run in parallel.   |  `None` |
| <a id="doxygen-dot_common_attr"></a>dot_common_attr |  `dot_common_attr` is common attributes for nodes, edges and labels of subgraphs.   |  `None` |
| <a id="doxygen-dot_edge_attr"></a>dot_edge_attr |  `dot_edge_attr` is concatenated with `dot_common_attr`.   |  `None` |
| <a id="doxygen-dot_node_attr"></a>dot_node_attr |  `dot_node_attr` is concatenated with `dot_common_attr`.   |  `None` |
| <a id="doxygen-dot_fontpath"></a>dot_fontpath |  You can set the path where dot can find font specified with fontname in `dot_common_attr` and others dot attributes.   |  `None` |
| <a id="doxygen-dot_transparent"></a>dot_transparent |  If the `dot_transparent` tag is set to `True`, then the images generated by dot will have a transparent background.   |  `None` |
| <a id="doxygen-class_graph"></a>class_graph |  If the `class_graph` tag is set to `True` or GRAPH or BUILTIN then Doxygen will generate a graph for each documented class showing the direct and indirect inheritance relations.   |  `None` |
| <a id="doxygen-collaboration_graph"></a>collaboration_graph |  If the `collaboration_graph` tag is set to `True` then Doxygen will generate a graph for each documented class showing the direct and indirect implementation dependencies (inheritance, containment, and class references variables) of the class with other documented classes.   |  `None` |
| <a id="doxygen-group_graphs"></a>group_graphs |  If the `group_graphs` tag is set to `True` then Doxygen will generate a graph for groups, showing the direct groups dependencies.   |  `None` |
| <a id="doxygen-uml_look"></a>uml_look |  If the `uml_look` tag is set to `True`, Doxygen will generate inheritance and collaboration diagrams in a style similar to the OMG's Unified Modeling Language.   |  `None` |
| <a id="doxygen-uml_limit_num_fields"></a>uml_limit_num_fields |  If the `uml_look` tag is enabled, the fields and methods are shown inside the class node.   |  `None` |
| <a id="doxygen-dot_uml_details"></a>dot_uml_details |  If the `dot_uml_details` tag is set to `False`, Doxygen will show attributes and methods without types and arguments in the UML graphs.   |  `None` |
| <a id="doxygen-dot_wrap_threshold"></a>dot_wrap_threshold |  The `dot_wrap_threshold` tag can be used to set the maximum number of characters to display on a single line.   |  `None` |
| <a id="doxygen-template_relations"></a>template_relations |  If the `template_relations` tag is set to `True` then the inheritance and collaboration graphs will show the relations between templates and their instances.   |  `None` |
| <a id="doxygen-include_graph"></a>include_graph |  If the `include_graph`, `enable_preprocessing` and `search_includes` tags are set to `True` then Doxygen will generate a graph for each documented file showing the direct and indirect include dependencies of the file with other documented files.   |  `None` |
| <a id="doxygen-included_by_graph"></a>included_by_graph |  If the `included_by_graph`, `enable_preprocessing` and `search_includes` tags are set to `True` then Doxygen will generate a graph for each documented file showing the direct and indirect include dependencies of the file with other documented files.   |  `None` |
| <a id="doxygen-call_graph"></a>call_graph |  If the `call_graph` tag is set to `True` then Doxygen will generate a call dependency graph for every global function or class method.   |  `None` |
| <a id="doxygen-caller_graph"></a>caller_graph |  If the `caller_graph` tag is set to `True` then Doxygen will generate a caller dependency graph for every global function or class method.   |  `None` |
| <a id="doxygen-graphical_hierarchy"></a>graphical_hierarchy |  If the `graphical_hierarchy` tag is set to `True` then Doxygen will graphical hierarchy of all classes instead of a textual one.   |  `None` |
| <a id="doxygen-directory_graph"></a>directory_graph |  If the `directory_graph` tag is set to `True` then Doxygen will show the dependencies a directory has on other directories in a graphical way.   |  `None` |
| <a id="doxygen-dir_graph_max_depth"></a>dir_graph_max_depth |  The `dir_graph_max_depth` tag can be used to limit the maximum number of levels of child directories generated in directory dependency graphs by dot.   |  `None` |
| <a id="doxygen-dot_image_format"></a>dot_image_format |  The `dot_image_format` tag can be used to set the image format of the images generated by dot.   |  `None` |
| <a id="doxygen-interactive_svg"></a>interactive_svg |  If `dot_image_format` is set to svg, then this option can be set to `True` to enable generation of interactive SVG images that allow zooming and panning.   |  `None` |
| <a id="doxygen-dot_path"></a>dot_path |  The `dot_path` tag can be used to specify the path where the dot tool can be found.   |  `None` |
| <a id="doxygen-dotfile_dirs"></a>dotfile_dirs |  The `dotfile_dirs` tag can be used to specify one or more directories that contain dot files that are included in the documentation (see the \dotfile command).   |  `None` |
| <a id="doxygen-dia_path"></a>dia_path |  You can include diagrams made with dia in Doxygen documentation.   |  `None` |
| <a id="doxygen-diafile_dirs"></a>diafile_dirs |  The `diafile_dirs` tag can be used to specify one or more directories that contain dia files that are included in the documentation (see the \diafile command).   |  `None` |
| <a id="doxygen-plantuml_jar_path"></a>plantuml_jar_path |  When using PlantUML, the `plantuml_jar_path` tag should be used to specify the path where java can find the plantuml.jar file or to the filename of jar file to be used.   |  `None` |
| <a id="doxygen-plantuml_cfg_file"></a>plantuml_cfg_file |  When using PlantUML, the `plantuml_cfg_file` tag can be used to specify a configuration file for PlantUML.   |  `None` |
| <a id="doxygen-plantuml_include_path"></a>plantuml_include_path |  When using PlantUML, the specified paths are searched for files specified by the !include statement in a PlantUML block.   |  `None` |
| <a id="doxygen-dot_graph_max_nodes"></a>dot_graph_max_nodes |  The `dot_graph_max_nodes` tag can be used to set the maximum number of nodes that will be shown in the graph.   |  `None` |
| <a id="doxygen-max_dot_graph_depth"></a>max_dot_graph_depth |  The `max_dot_graph_depth` tag can be used to set the maximum depth of the graphs generated by dot.   |  `None` |
| <a id="doxygen-dot_multi_targets"></a>dot_multi_targets |  Set the `dot_multi_targets` tag to `True` to allow dot to generate multiple output files in one run (i.e. multiple -o and -T options on the command line).   |  `None` |
| <a id="doxygen-generate_legend"></a>generate_legend |  If the `generate_legend` tag is set to `True` Doxygen will generate a legend page explaining the meaning of the various boxes and arrows in the dot generated graphs.   |  `None` |
| <a id="doxygen-dot_cleanup"></a>dot_cleanup |  If the `dot_cleanup` tag is set to `True`, Doxygen will remove the intermediate files that are used to generate the various graphs.   |  `None` |
| <a id="doxygen-mscgen_tool"></a>mscgen_tool |  You can define message sequence charts within Doxygen comments using the \msc command.   |  `None` |
| <a id="doxygen-mscfile_dirs"></a>mscfile_dirs |  The `mscfile_dirs` tag can be used to specify one or more directories that contain msc files that are included in the documentation (see the \mscfile command).   |  `None` |
| <a id="doxygen-kwargs"></a>kwargs |  Additional arguments to pass to the rule (e.g. `visibility = ["//visibility:public"], tags = ["manual"]`)   |  none |


