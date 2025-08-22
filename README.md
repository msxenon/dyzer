# ✨ Dyzer:
[![Pub](https://img.shields.io/pub/v/dyzer.svg)](https://pub.dev/packages/dyzer)

## The Baseline-Aware Dart Analyzer Plugin

Dyzer is a powerful Dart plugin designed to streamline your development workflow by providing early baseline-aware support for key features. Our goal is to help you build modern, performant, and future-proof Dart applications with confidence.


## Installation

```sh
dart pub add --dev dyzer
```

## 🚀 Features

* **Baseline-Aware Support:** Dyzer helps you identify and use features that are considered "baseline" in the Dart ecosystem, ensuring your code is compatible and stable across a wide range of platforms and environments.

* **Early-Stage Integration:** Get a head start on upcoming features and APIs. Dyzer provides experimental support for new language constructs and platform capabilities, allowing you to innovate faster.

* **Enhanced Code Analysis:** The plugin integrates with the Dart Analysis Server to provide specific warnings and suggestions tailored to baseline compatibility.

## Basic configuration

Add configuration to `analysis_options.yaml` and reload IDE to allow the analyzer to discover the plugin config.

### Basic config example

```yaml title="analysis_options.yaml"
analyzer:
  plugins:
    - dyzer

dyzer:
  rules:
    - avoid-dynamic
    - avoid-passing-async-when-sync-expected
    - avoid-redundant-async
    - avoid-unnecessary-type-assertions
    - avoid-unnecessary-type-casts
    - avoid-unrelated-type-assertions
    - avoid-unused-parameters
    - avoid-nested-conditional-expressions
    - newline-before-return
    - no-boolean-literal-compare
    - no-empty-block
    - prefer-trailing-comma
    - prefer-conditional-expressions
    - no-equal-then-else
    - prefer-moving-to-variable
    - prefer-match-file-name
```

### Basic config with metrics

```yaml title="analysis_options.yaml"
analyzer:
  plugins:
    - dyzer

dyzer:
  metrics:
    cyclomatic-complexity: 20
    number-of-parameters: 4
    maximum-nesting-level: 5
  metrics-exclude:
    - test/**
  rules:
    - avoid-dynamic
    - avoid-passing-async-when-sync-expected
    - avoid-redundant-async
    - avoid-unnecessary-type-assertions
    - avoid-unnecessary-type-casts
    - avoid-unrelated-type-assertions
    - avoid-unused-parameters
    - avoid-nested-conditional-expressions
    - newline-before-return
    - no-boolean-literal-compare
    - no-empty-block
    - prefer-trailing-comma
    - prefer-conditional-expressions
    - no-equal-then-else
    - prefer-moving-to-variable
    - prefer-match-file-name
```

## Usage

### Analyzer plugin

Dyzer can be used as a plugin for the Dart `analyzer` [package](https://pub.dev/packages/analyzer) providing additional rules. All issues produced by rules or anti-patterns will be highlighted in IDE.

Rules that marked with 🛠 have auto-fixes available through the IDE context menu. VS Code example:

![VS Code example](https://github.com/msxenon/dyzer/blob/main/media/quick-fixes.png)


### CLI

The package can be used as CLI and supports multiple commands:

| Command            | Example of use                                            | Short description                                         |
| ------------------ | --------------------------------------------------------- | --------------------------------------------------------- |
| analyze            | dart run dyzer analyze lib            | Reports code metrics, rules and anti-patterns violations. |
| check-unnecessary-nullable | dart run dyzer check-unnecessary-nullable lib | Checks unnecessary nullable parameters in functions, methods, constructors. |
| check-unused-files | dart run dyzer check-unused-files lib | Checks unused \*.dart files.                              |
| check-unused-l10n  | dart run dyzer check-unused-l10n lib  | Check unused localization in \*.dart files.               |
| check-unused-code  | dart run dyzer check-unused-code lib  | Checks unused code in \*.dart files.                      |

For additional help on any of the commands, enter `dart run dyzer help <command>`

**Note:** if you're setting up dyzer for multi-package repository (a.k.a. monorepo), it'll pick up analysis_options.yaml files correctly.

You can define one analysis_options.yaml at the root file.

#### Analyze

Reports code metrics, rules and anti-patterns violations. To execute the command, run

```sh
$ dart run dyzer analyze lib
```

It will produce a result in one of the format:

- Console
- GitHub
- Codeclimate
- HTML
- JSON



#### Check unnecessary nullable parameters

Checks unnecessary nullable parameters in functions, methods, constructors. To execute the command, run

```sh
$ dart run dyzer check-unnecessary-nullable lib
```

It will produce a result in one of the format:

- Console
- JSON



#### Check unused files

Checks unused `*.dart` files. To execute the command, run

```sh
$ dart run dyzer check-unused-files lib
```

It will produce a result in one of the format:

- Console
- JSON


#### Check unused localization

Checks unused Dart class members, that encapsulates the app’s localized values.

An example of such class:

```dart
class ClassWithLocalization {
  String get title {
    return Intl.message(
      'Hello World',
      name: 'title',
      desc: 'Title for the Demo application',
      locale: localeName,
    );
  }
}
```

To execute the command, run

```sh
$ dart run dyzer check-unused-l10n lib
```

It will produce a result in one of the format:

- Console
- JSON


#### Check unused code

Checks unused code in `*.dart` files. To execute the command, run

```sh
$ dart run dyzer check-unused-code lib
```

It will produce a result in one of the format:

- Console
- JSON


## ⚠️ Active Development Warning

**Dyzer is currently in active development.** While we are committed to providing a stable and reliable experience, you may encounter breaking changes as we evolve the API and integrate new features. This is an exciting journey to build the best tooling for Dart, and we appreciate your understanding and feedback.

**We strongly recommend using Dyzer for projects where you are comfortable with an evolving API.** For mission-critical, production applications, please consider this a tool for exploration and development, and be prepared for potential updates.

### Installation (For plugin development)

1. Clone Repo.
2. Install FVM.
3. In the repo root directory, run `fvm use`.
4. Set up dev workspace, run `sh scripts/dev_ws_setup.sh`.
5. Restart your IDE.


## Troubleshooting

Please read [the following guide](./TROUBLESHOOTING.md) if the plugin is not working as you'd expect it to work.

## Contributing

If you are interested in contributing, please check out the [contribution guidelines](./CONTRIBUTING.md). Feedback and contributions are welcome!

## License
Dart Code Linter is licensed under the [MIT](./LICENSE)