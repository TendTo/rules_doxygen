# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.6.0]

### Changed

- Default doxygen version is now `1.15.0`

## [2.5.1]

### Changed

- Bump in the version of multiple dependencies, to accommodate for incompatible flags and ease future migrations
- Autogenerate documentation for the bcr
- Add 'rolling' to the CI bazel versions
- Update dependencies notification via Bazel Steward

## [2.5.0]

### Added

- Documenting `exclude_patterns` workaround [#31](https://github.com/TendTo/rules_doxygen/issues/31) (thanks to @AustinSchuh)
- Documenting limitations for the automatic download of the doxygen binary in the `doxygen` extension rule [#32](https://github.com/TendTo/rules_doxygen/issues/32) (thanks to @oxidase)
- `use_default_shell_env` parameter to allow the use of the default shell environment when running doxygen. Allows for better integration with the user's environment at the cost of hermeticity
- `tools` parameter to allow the use of additional tools when running doxygen. Allows for hermetic integration with other executables
- `env` parameter to allow the use of custom environment variables when running doxygen
- Example showcasing the use of a custom executable for doxygen

### Changed

- Renamed `_executable` parameter in the `doxygen` rule to `executable` to allow its use from the `doxygen` macro (thanks to @mutalibmohammed)

## [2.4.2]

### Added

- Support for `{{OUTDIR}}` substitution in the `Doxyfile` [#30](https://github.com/TendTo/rules_doxygen/pull/30) (thanks to @kaycebasques)

## [2.4.1]

### Added

- `Doxyfile` is now included in the `doxygen` rule DefaultInfo provider
- Mnemonic `DoxygenBuild` added to the `ctx.run` in the `doxygen` rule
- Added support by default for the `$(OUTDIR)` make variable in the `doxygen` rule [#28](https://github.com/TendTo/rules_doxygen/pull/28) (thanks to @kaycebasques)
- `doxylink` example in the documentation

### Changed

- Updated documentation
- More information in the progress message of the `doxygen` rule

## [2.4.0]

### Changed

- Default doxygen version is now `1.14.0`

## [2.3.0]

### Added

- Support for dependency inclusion in the `doxygen` rule [#24](https://github.com/TendTo/rules_doxygen/pull/24) (thanks to @oxidase)

### Changed

- `srcs` attribute in the `doxygen` macro is now optional, as it defaults to `[]`
- Updated documentation

## [2.2.2]

### Added

- CI tests for both Bazel 7 and 8

### Fix

- Remove dependency on `@bazel_tools//tools/build_defs/repo` to support Bazel 7.0.0 [#22](https://github.com/TendTo/rules_doxygen/issues/22) (thanks to @filmil)
- Remove unnecessary `get_auth`

### Changed

- Made documentation clearer

## [2.2.1]

### Fix

- Added missing config DOT_TRANSPARENT

### Changed

- Updated documentation and added example with the output substitution

## [2.2.0]

### Added

- OutputGroup support in the `doxygen` rule [#20](https://github.com/TendTo/rules_doxygen/pull/20) (thanks to @kaycebasques)

### Changed

- Updated documentation
- Default doxygen version is now `1.13.2`

## [2.1.0]

### Added

- Most of the `doxygen` parameters are now available in the `doxygen` extension rule
- Support for make substitutions in the `doxygen` extension rule [#11](https://github.com/TendTo/rules_doxygen/issues/11) (thanks to @hofbi)
- `repository` tag in the `doxygen` extension rule to avoid conflicts with other modules when used in a submodule [#15](https://github.com/TendTo/rules_doxygen/issues/15) (thanks to @blaizard)

### Fix

- `doxygen` list parameters not properly escaping their values [#12](https://github.com/TendTo/rules_doxygen/issues/12) (thanks to @kaycebasques)
- Missing dependency on `skylib` for the documentation

### Changed

- Updated documentation (thanks to @Vertexwahn)

## [2.0.0]

### Added

- Platform `mac-arm` to support the Apple silicon macs (thanks to @kaycebasques, @wyverald, @tpudlik, @rickeylev)
- Allow executable configuration in the `doxygen` extension rule (thanks to @kaycebasques, @wyverald, @tpudlik, @rickeylev)

### Changed

- Module extension tag renamed from `version` to `configuration` **BREAKING CHANGE**
- Updated documentation

## [1.3.0]

### Added

- Support hermetic build for `mac` platform (thanks to @kaycebasques, @wyverald, @tpudlik, @rickeylev)
- Support for platform-specific configurations in the extension rule

### Changed

- Update dependencies (stardoc 0.6.2 -> 0.7.1, platforms 0.0.5 -> 0.0.10)
- Refactor of internal repository and extension rules
- Updated documentation

## [1.2.0]

### Added

- Support for system-wide doxygen installation. This allows the rule to run on mac os, but loses hermeticity. Can be enabled by using doxygen version `0.0.0`.
- Tests for the new feature in the CI pipeline
- Local repository rule for doxygen

### Changed

- Default doxygen version is now `1.12.0`

## [1.1.3]

### Added

- `dot_executable` parameter in the macro
- Example of how to use the `doxygen` alongside `graphviz` in hermetic builds

## [1.1.2]

### Added

- Forward `**kwargs` from the `doxygen` macro to the underlying `_doxygen` rule invocation [#1](https://github.com/TendTo/rules_doxygen/issues/1)
- Some more easy to use common configurations for the `doxygen` macro

### Changed

- Updated documentation

## [1.1.1]

### Added

- Automatically determine the INPUT value for the Doxyfile based on the sources of the target
- Customizable extra args to doxygen invocation
- Some more easy to use common configurations for the `doxygen` macro

## [1.1.0]

### Added

- Possibility of using a custom Doxyfile
- Added documentation to rules, macro and extensions

### Fixed

- Correctly use `project_name` and `project_brief` in the macro
- Unfreeze default list in macro

## [1.0.0]

### Added

- Initial release

### Fixed

- Remove superfluous `\` before the `\n` in the `doxygen` configurations list formatting

[1.0.0]: https://github.com/TendTo/rules_doxygen/tree/1.0.0
[1.1.0]: https://github.com/TendTo/rules_doxygen/compare/1.0.0...1.1.0
[1.1.1]: https://github.com/TendTo/rules_doxygen/compare/1.1.0...1.1.1
[1.1.2]: https://github.com/TendTo/rules_doxygen/compare/1.1.1...1.1.2
[1.1.3]: https://github.com/TendTo/rules_doxygen/compare/1.1.2...1.1.3
[1.2.0]: https://github.com/TendTo/rules_doxygen/compare/1.1.3...1.2.0
[1.3.0]: https://github.com/TendTo/rules_doxygen/compare/1.2.0...1.3.0
[2.0.0]: https://github.com/TendTo/rules_doxygen/compare/1.3.0...2.0.0
[2.1.0]: https://github.com/TendTo/rules_doxygen/compare/2.0.0...2.1.0
[2.2.0]: https://github.com/TendTo/rules_doxygen/compare/2.1.0...2.2.0
[2.2.1]: https://github.com/TendTo/rules_doxygen/compare/2.2.0...2.2.1
[2.2.2]: https://github.com/TendTo/rules_doxygen/compare/2.2.1...2.2.2
[2.3.0]: https://github.com/TendTo/rules_doxygen/compare/2.2.2...2.3.0
[2.4.0]: https://github.com/TendTo/rules_doxygen/compare/2.3.0...2.4.0
[2.4.1]: https://github.com/TendTo/rules_doxygen/compare/2.4.0...2.4.1
[2.4.2]: https://github.com/TendTo/rules_doxygen/compare/2.4.1...2.4.2
[2.5.0]: https://github.com/TendTo/rules_doxygen/compare/2.4.2...2.5.0
[NEXT.VERSION]: https://github.com/TendTo/rules_doxygen/compare/2.5.0...HEAD
