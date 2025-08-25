# ✨ Dyzer:
[![Pub](https://img.shields.io/pub/v/dyzer.svg)](https://pub.dev/packages/dyzer)

*Note: this repo is forked from [Dart Code Metrics](https://github.com/dart-code-checker/dart-code-metrics)

## The Baseline-Aware Dart Analyzer Plugin

Dyzer is a powerful Dart plugin designed to streamline your development workflow by providing early baseline-aware support for key features. Our goal is to help you build modern, performant, and future-proof Dart applications with confidence.


## Installation

```sh
dart pub add --dev dyzer
dart pub global activate dyzer
```

## 🚀 Features

* **Baseline-Aware Support:** Dyzer helps you identify and use features that are considered "baseline" in the Dart ecosystem, ensuring your code is compatible and stable across a wide range of platforms and environments.

* **Early-Stage Integration:** Get a head start on upcoming features and APIs. Dyzer provides experimental support for new language constructs and platform capabilities, allowing you to innovate faster.

* **Enhanced Code Analysis:** The plugin integrates with the Dart Analysis Server to provide specific warnings and suggestions tailored to baseline compatibility.

## Basic configuration

Add configuration to `analysis_options.yaml` and reload IDE to allow the analyzer to discover the plugin config.