# Analyze

Reports lint rules violations.

To execute the command, run:

```sh
$ dart run dyzer analyze lib
```
info

You need to configure rules entry in the analysis_options.yaml to have a rules report included into the result.

Full command description:

```sh
Usage: dyzer analyze [arguments] <directories>
    -h, --help                                       Print this usage information
    -r, --reporter=<console>                         The format of the output of the analysis
                                                     [console (default), console-verbose, checkstyle, codeclimate, github, gitlab, html, json]
    -o, --output-directory=<OUTPUT>                  Write HTML output to OUTPUT
                                                     (defaults to "metrics")
        --json-path=<path/to/file.json>              Path to the JSON file with the output of the analysis
        --cyclomatic-complexity=<20>                 Cyclomatic Complexity threshold
        --halstead-volume=<150>                      Halstead Volume threshold
        --lines-of-code=<100>                        Lines of Code threshold
        --maximum-nesting-level=<5>                  Maximum Nesting Level threshold
        --number-of-methods=<10>                     Number of Methods threshold
        --number-of-parameters=<4>                   Number of Parameters threshold
        --source-lines-of-code=<50>                  Source lines of Code threshold
        --weight-of-class=<0.33>                     Weight Of a Class threshold
        --maintainability-index=<50>                 Maintainability Index threshold
        --technical-debt=<0>                         Technical Debt threshold
    -c, --print-config                               Print resolved config
        --root-folder=<./>                           Root folder
                                                     (defaults to current directory)
        --sdk-path=<directory-path>                  Dart SDK directory path. Should be provided only when you run the application as compiled executable(https://dart.dev/tools/dart-compile#exe) and automatic Dart SDK path detection fails
        --exclude=<{/**.g.dart,/**.freezed.dart}>    File paths in Glob syntax to be exclude
                                                     (defaults to "{/**.g.dart,/**.freezed.dart}")
        --no-congratulate                            Don't show output even when there are no issues.
        --[no-]verbose                               Show verbose logs
        --set-exit-on-violation-level=<warning>      Set exit code 2 if code violations same or higher level than selected are detected
                                                     [noted, warning, alarm]
        --[no-]fatal-style                           Treat style level issues as fatal
        --[no-]fatal-performance                     Treat performance level issues as fatal
        --[no-]fatal-warnings                        Treat warning level issues as fatal
                                                     (defaults to on)
        --fatal-warnings-threshold=<all>             Number of warnings to treat as fatal
        --fatal-performance-threshold=<all>          Number of performance issues to treat as fatal
        --fatal-style-threshold=<all>                Number of style issues to treat as fatal
```

## Output example
### Console

Use `--reporter=console` to enable this format.

### JSON

The reporter prints a single JSON object containing meta information and the violations grouped by a file. Use `--reporter=json` to enable this format.

#### The root object fields are

- `formatVersion` - an integer representing the format version (will be incremented each time the serialization format changes)
- `timestamp` - a creation time of the report in YYYY-MM-DD HH:MM:SS format
- `records` - an array of [objects](#the-record-object-fields-are)

```json
{
  "formatVersion": 2,
  "timestamp": "2021-04-11 14:44:42",
  "records": [
    {
      ...
    },
    {
      ...
    },
    {
      ...
    }
  ]
}
```

#### The record object fields are

- `path` - a relative path to the target file
- `issues` - an array of [issues](#the-issue-object-fields-are) detected in the target file

```json
{
  "path": "lib/src/metrics/metric_computation_result.dart",
  "issues": [
    ...
  ]
}
```

#### The issue object fields are

- `ruleId` - an id of the rule associated with the issue
- `documentation` - an url of a page containing documentation associated with the issue
- `codeSpan` - a source [code span](#the-code-span-object-fields-are) associated with the issue
- `severity` - a severity of the issue
- `message` - a short message

```json
{
  "ruleId": "long-parameter-list",
  "documentation": "https://git.io/JUGrU",
  "codeSpan": {
    ...
  },
  "severity": "none",
  "message": "Long Parameter List. This function require 5 arguments.",
}
```
#### The code span object fields are

start - a start [location](#the-location-object-fields-are) of an entity
end - an end [location](#the-location-object-fields-are) of an entity
text - a source code text of an entity
```json
{
  "start": {
    ...
  },
  "end": {
    ...
  },
  "text": "entity source code"
}
```

#### The location object fields are

- `offset` - a zero-based offset of the location in the source
- `line` - a zero-based line of the location in the source
- `column` - a zero-based column of the location in the source

```json
{
  "offset": 156,
  "line": 7,
  "column": 1
}
```

### GitHub

Reports about design and static code diagnostics issues in pull requests based on GitHub Actions Workflow commands. Use `--reporter=github` to enable this format.

- Install dart/flutter and get packages:

#### Flutter example

```yaml
jobs:
  your_job_name:
    steps:
      - name: Install Flutter
        uses: subosito/flutter-action@master
        with:
          channel: stable

      - name: Install dependencies
        run: flutter pub get
      ...
```
#### Dart example
```yaml
jobs:
  your_job_name:
    steps:
      - name: Install Dart
        uses: dart-lang/setup-dart@v1

      - name: Install dependencies
        run: dart pub get
      ...
```
- Run Dyzer:
```yaml
- name: Run Dyzer
  run: dyzer analyze --reporter=github lib
```

#### Full Example
```yaml
jobs:
  your_job_name:
    steps:
      - name: Install Flutter
        uses: subosito/flutter-action@master
        with:
          channel: stable

      - name: Install dependencies
        run: flutter pub get

      - name: Run Dyzer
        run: dyzer analyze --reporter=github lib
```

### GitLab

Reports lint issues in merge requests based on Code Quality custom tool. Use `--reporter=gitlab` to enable this format.

- Define a job in your `.gitlab-ci.yml` file that generates the [Code Quality report artifact](https://docs.gitlab.com/ee/ci/yaml/index.html#artifactsreportscodequality).

```yaml
code_quality:
  image: dart
  script:
    - dyzer analyze --reporter=gitlab lib > code-quality-report.json
  artifacts:
    reports:
      codequality: code-quality-report.json
```

### Checkstyle

Reports lint issues. Use `--reporter=checkstyle` to enable this format.
```xml
<?xml version="1.0"?>
<checkstyle version="10.0">
  <file name="lib/src/analyzers/lint_analyzer/lint_analyzer.dart">
    <error line="168" column="3" severity="ignore" message="Long method. This method contains 63 lines with code." source="long-method"/>
  </file>
  <file name="lib/src/analyzers/lint_analyzer/rules/rules_list/avoid_returning_widgets/visit_declaration.dart">
    <error line="3" column="1" severity="ignore" message="Long Parameter List. This function require 6 arguments." source="long-parameter-list"/>
  </file>
  <file name="lib/src/analyzers/lint_analyzer/reporters/utility_selector.dart">
    <error line="27" column="3" severity="ignore" message="Long method. This method contains 53 lines with code." source="long-method"/>
  </file>
  <file name="lib/src/analyzers/lint_analyzer/reporters/reporters_list/html/utility_functions.dart">
    <error line="45" column="1" severity="ignore" message="Long function. This function contains 56 lines with code." source="long-method"/>
  </file>
  <file name="lib/src/analyzers/lint_analyzer/reporters/reporters_list/html/lint_html_reporter.dart">
    <error line="74" column="3" severity="ignore" message="Long method. This method contains 136 lines with code." source="long-method"/>
    <error line="330" column="3" severity="ignore" message="Long method. This method contains 159 lines with code." source="long-method"/>
  </file>
</checkstyle>
```
Example Bitbucket pipeline configuration

- Define a pipeline in your [bitbucket-pipelines.yml](https://support.atlassian.com/bitbucket-cloud/docs/configure-bitbucket-pipelinesyml/) file that generates the Checkstyle report and [process them](https://bitbucket.org/product/features/pipelines/integrations?p=atlassian/checkstyle-report).
```yaml
image: dart

pipelines:
  default:
    - step:
        name: analyze
        script:
          - dyzer analyze --reporter=checkstyle lib > checkstyle-result.xml
        after-script:
          - pipe: atlassian/checkstyle-report:0.3.1
```
