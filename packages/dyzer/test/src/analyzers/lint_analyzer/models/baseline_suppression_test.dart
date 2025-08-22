import 'dart:convert';

import 'package:dyzer/src/cli/models/baseline_model.dart';
import 'package:dyzer/src/providers/baseline_model_reader.dart';
import 'package:dyzer/src/utils/baseline_suppression.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

import '../../../helpers/file_resolver.dart';

const _baselineRootFolder = 'test/resources';

void main() {
  const filePath = 'test/resources/suppression_example.dart';
  late BaselineSuppression suppression;

  setUpAll(() async {
    final parseResult = await FileResolver.resolve(filePath);
    final baseline =
        await FileResolver.resolve('$_baselineRootFolder/.dyzer_baseline.json');
    BaselineReaderProvider().assignInstance(
      BaselineModel.fromMap(
        json.decode(baseline.content) as Map<String, dynamic>,
      ),
      _baselineRootFolder,
    );
    suppression = BaselineSuppression(_baselineRootFolder, parseResult.content);
  });

  test('isSuppressed', () async {
    expect(
      suppression.isSuppressed('rule_id4', filePath),
      isTrue,
    );
  });

  test('isSuppressedAt #0', () {
    expect(
      suppression.isSuppressedAt(
        SourceLocation(0, sourceUrl: Uri.parse(filePath)),
        SourceLocation(10, sourceUrl: Uri.parse(filePath)),
        ruleId: 'rule_id4',
        indexInFile: 0,
      ),
      isTrue,
    );
  });

  test('isSuppressedAt #1', () {
    expect(
      suppression.isSuppressedAt(
        SourceLocation(0, sourceUrl: Uri.parse(filePath)),
        SourceLocation(10, sourceUrl: Uri.parse(filePath)),
        ruleId: 'rule_id4',
        indexInFile: 1,
      ),
      isFalse,
    );
  });
}
