import 'package:dyzer/src/cli/models/baseline_model.dart';
import 'package:dyzer/src/utils/baseline_suppression.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('baseline suppression on windows file path', () {
    // 💡 The file file:///C:/Users/modi/build/dyzer/packages/dyzer/lib/src/analyzers/unnecessary_nullable_analyzer/unnecessary_nullable_analyzer.dart is not found in the baseline.
    //_rootFolder "C:\Users\modi\build\dyzer\packages\dyzer" /test/src/analyzers/lint_analyzer/rules/rules_list/no_blank_line_before_single_return/no_blank_line_before_single_return_rule_test.dartPlease,
    //make sure that the correct root folder is provided.
    final path =
        'file:///C:/Users/modi/build/dyzer/packages/dyzer/test/src/analyzers/lint_analyzer/rules/rules_list/no_blank_line_before_single_return/no_blank_line_before_single_return_rule_test.dart';

    const rootFolder = r'C:\Users\modi\build\dyzer\packages\dyzer';
    const expectedTrimmedPath =
        '/test/src/analyzers/lint_analyzer/rules/rules_list/no_blank_line_before_single_return/no_blank_line_before_single_return_rule_test.dart';

    final filePath = Uri.parse(path);
    final context = p.Context(style: p.Style.posix);

    final xx = context.fromUri(filePath);
    final xxxx = context.relative(xx);

    final filePathTrimmer = context.joinAll(p.split(xx));

    final x = filePath.path;
    final rootFolderNormalized = context.joinAll(p.split(rootFolder));

    final suppression = BaselineSuppression(rootFolder, '');
    final zz = BaselineModel.normalizeBaselinePath(xx);
    final zzz = BaselineModel.normalizeBaselinePath(rootFolder);
    // expect(filePathTrimmer.replaceAll(rootFolderNormalized, ''),
    //     expectedTrimmedPath);
    expect(suppression.fullToBaselineFriendlyPath(Uri.parse(path)),
        expectedTrimmedPath);
  });

  test('xxx', () {
    final path =
        'file:///C:/Users/modi/build/dyzer/packages/dyzer/test/src/analyzers/lint_analyzer/rules/rules_list/no_blank_line_before_single_return/no_blank_line_before_single_return_rule_test.dart';
    const rootFolder = r'C:\Users\modi\build\dyzer\packages\dyzer';

    // Convert file URI to normal file system path
    final filePath = Uri.parse(path).toFilePath();

    // Normalize both paths to handle separators
    final normalizedFilePath = p.normalize(filePath);
    final normalizedRoot = p.normalize(rootFolder);

    // Get the relative path
    final relativePath = p.relative(normalizedFilePath, from: normalizedRoot);

    // Ensure POSIX-style slashes
    var expectedTrimmedPath = p.posix.joinAll(p.split(relativePath));

    const expectedTrimmedPath1 =
        '/test/src/analyzers/lint_analyzer/rules/rules_list/no_blank_line_before_single_return/no_blank_line_before_single_return_rule_test.dart';
    final posixSeparator = p.posix.separator;
    // Add leading slash if missing
    if (!expectedTrimmedPath.startsWith(posixSeparator)) {
      expectedTrimmedPath = '$posixSeparator$expectedTrimmedPath';
    }

    expect(expectedTrimmedPath, expectedTrimmedPath1);
  });
}
