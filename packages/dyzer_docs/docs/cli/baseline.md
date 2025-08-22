# Baseline

Takes a snapshot of current issues, and saves it to your project directory as '.dyzer_baseline.json', so analyzer will ignore all issues in the snapshot so you can focus on new issues.

To execute the command, run:

```sh
$ dart run dyzer baseline lib
```

## Json output file example
```json
{
  "createdAt": "2025-08-20T18:07:49.652488",
  "baselinedIssues": 5,
  "baselinedFiles": 1,
  "version": "1.0.0",
  "files": {
    "/lib/src/analyzer_plugin/analyzer_plugin.dart": {
      "newline-before-return": [
        "b29ae52d28276068059e941b32ce1038"
      ],
      "prefer-correct-identifier-length": [
        "a9e26254e651465c89ff715d5733e97c"
      ],
      "prefer-trailing-comma": [
        "84974f25dd295c0e5f1354de50e07a78",
        "af160e11707294beaa12f2f3d08b8684",
        "fdf2d1530c824df727fa581e2dd21442"
      ]
    }
  }
}
```
 ## Baseline currently supports
- Lint issues.
- Anti Pattern issues.