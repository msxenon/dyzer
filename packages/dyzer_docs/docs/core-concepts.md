---
sidebar_position: 2
---

# Core Concepts

This page contains a high-level overview of some of the core concepts of Dyzer.
## What is Dyzer?

Dyzer is a toolkit that helps you identify and fix problems in your Dart and Flutter code. These problems can range from potential runtime bugs and violations of best practices to styling issues. Dyzer includes over 70 built-in rules to validate your code against various expectations, and you can customize these rules to fit your specific needs.
## Baseline

A snapshot of all the existing issues in your codebase at a particular point in time. It's a way to acknowledge the current state of your code without being overwhelmed by a flood of warnings and errors.

For more information, see the [Baseline documentation](/docs/cli/baseline).
### Rules

Rules are central to how Dyzer works. They are used to check whether your code meets certain expectations, and to specify what should be done if it doesn't. Rules can also be configured with additional options specific to that rule.

For more information, see the [Rules documentation](/docs/rules).
### Metrics

Metrics are another important aspect of Dyzer. They are used to measure the complexity of your code and identify areas that may be difficult to maintain or test. This can be particularly useful for larger projects, where it can be challenging to keep track of all the different contributions from various developers. Metrics can also provide instant feedback on pull requests for smaller projects, helping to ensure that code stays easy to maintain.

All metrics are configurable.

For more information, see the [Metrics documentation](/docs/metrics).
### Commands

In addition to providing rules and metrics, Dyzer also includes commands to help with codebase maintenance, such as identifying unused code, unused files, and unused localization.

For more information, see the [CLI documentation](/docs/cli).
### Configuration

Dyzer is designed to be flexible and configurable to fit your specific needs. You can choose to enable only metrics calculation, only rules, or both.

For more information, see the [Configuration documentation](/docs/configuration).
## Dyzer and Dart analyzer

While the Dart analyzer is also a static analysis tool that highlights problems in code, there are some key differences between it and Dyzer:

- Dyzer includes custom rules that are not included in the analyzer and linter tools.
- Dyzer's rules are more configurable and therefore more flexible.
- Dyzer provides metrics to measure codebase complexity and commands to help with codebase maintenance.

Using both tools as part of your development workflow can help ensure the quality of your code.