# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0]

### Changed

- Moved the `submodules` example to the `examples` directory

## [2.1.0]

### Added

- Most of the `doxygen` parameters are now available in the `doxygen` extension rule
- Support for make substitutions in the `doxygen` extension rule [#11](https://github.com/TendTo/rules_doxygen/issues/11) (thanks to @hofbi)
- `repository` tag in the `doxygen` extension rule to avoid conflicts with other modules when used in a submodule [#15](https://github.com/TendTo/rules_doxygen/issues/15) (thanks to @blaizard)

### Fix

- `doxygen` list parameters not properly escaping their values [#12](https://github.com/TendTo/rules_doxygen/issues/12) (thanks to @kaycebasques)
- Missing dependency on `skylib` for the documentation

## [2.0.0]

### Added

- Platform `mac-silicon` to support the Apple silicon macs (thanks to @kaycebasques, @wyverald, @tpudlik, @rickeylev)
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
- Testes for the new feature in the CI pipeline
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

## [NEXT.VERSION]

[1.0.0]: https://github.com/TendTo/rules_doxygen/tree/1.0.0
[1.1.0]: https://github.com/TendTo/rules_doxygen/compare/1.0.0...1.1.0
[1.1.1]: https://github.com/TendTo/rules_doxygen/compare/1.1.0...1.1.1
[1.1.2]: https://github.com/TendTo/rules_doxygen/compare/1.1.1...1.1.2
[1.1.3]: https://github.com/TendTo/rules_doxygen/compare/1.1.2...1.1.3
[1.2.0]: https://github.com/TendTo/rules_doxygen/compare/1.1.3...1.2.0
[1.3.0]: https://github.com/TendTo/rules_doxygen/compare/1.2.0...1.3.0
[2.0.0]: https://github.com/TendTo/rules_doxygen/compare/1.3.0...2.0.0
[2.1.0]: https://github.com/TendTo/rules_doxygen/compare/2.0.0...2.1.0
[NEXT.VERSION]: https://github.com/TendTo/rules_doxygen/compare/2.1.0...HEAD
