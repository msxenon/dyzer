import 'package:dyzer/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dyzer/src/analyzers/lint_analyzer/rules/rules_list/no_blank_line_before_single_return/no_blank_line_before_single_return_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath = 'no_blank_line_before_single_return/examples/example.dart';

void main() {
  group('NoBlankLineBeforeSingleReturnRule', () {
    test('initialization', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = NoBlankLineBeforeSingleReturnRule().check(unit);

      RuleTestHelper.verifyInitialization(
        issues: issues,
        ruleId: NoBlankLineBeforeSingleReturnRule.ruleId,
        severity: Severity.style,
      );
    });

    test('reports about found issues', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = NoBlankLineBeforeSingleReturnRule().check(unit);

      final startLines = <int>[102, 108, 116];

      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: startLines,
        startColumns: List.generate(startLines.length, (index) => 5),
        locationTexts:
            List.generate(startLines.length, (index) => 'return a - 1;'),
        messages: List.generate(startLines.length,
            (index) => NoBlankLineBeforeSingleReturnRule.warning),
      );
    });
  });
}
