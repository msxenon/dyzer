---
sidebar_position: 3
---
# Configuration

Dyzer is designed to be flexible and configurable for your use case. You can turn off every rule and run only with enabled metrics calculation or have both rules and metrics enabled.

To configure Dyzer, add a dyzer entry to `analysis_options.yaml`:

```analysis_options.yaml
dyzer:
  extends:
    - ... # configures the list of preset configurations
  metrics:
    - ... # configures the list of reported metrics
  metrics-exclude:
    - ... # configures the list of files that should be ignored by metrics
  rules:
    - ... # configures the list of rules
  rules-exclude:
    - ... # configures the list of files that should be ignored by rules
  anti-patterns:
    - ... # configures the list of anti-patterns
```


### _This configuration is used by both CLI and the analysis server._

Basic config example:

```analysis_options.yaml
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
    - avoid-collapsible-if
    - avoid-redundant-else
    - avoid-incomplete-copy-with
    - avoid-self-compare
    - avoid-self-assignment
    - avoid-unnecessary-nullable-return-type
    - avoid-unrelated-type-casts
    - prefer-declaring-const-constructor
```


### _You can find a list of recommended rules [here](/docs/configuration/presets)._ 

Basic config with metrics:
```analysis_options.yaml

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
    - avoid-collapsible-if
    - avoid-redundant-else
    - avoid-incomplete-copy-with
    - avoid-self-compare
    - avoid-self-assignment
    - avoid-unnecessary-nullable-return-type
    - avoid-unrelated-type-casts
    - prefer-declaring-const-constructor
```

### _You can find a list of recommended metrics [here](/docs/configuration/presets)._ 