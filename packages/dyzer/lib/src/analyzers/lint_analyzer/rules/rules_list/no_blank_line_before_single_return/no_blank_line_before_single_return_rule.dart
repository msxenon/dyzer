import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';

import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../../models/issue.dart';
import '../../../models/severity.dart';
import '../../models/dart_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

class NoBlankLineBeforeSingleReturnRule extends DartRule {
  static const String ruleId = 'no-blank-line-before-single-return';

  static const warning =
      'Remove blank line before single return statement in a block.';

  NoBlankLineBeforeSingleReturnRule([Map<String, Object> config = const {}])
      : super(
          id: ruleId,
          severity: readSeverity(config, Severity.style),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        );

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor();

    source.unit.visitChildren(visitor);

    return visitor.statements
        // Ensure the return statement is in a block
        .where((statement) => statement.parent is Block)
        // Ensure the return statement is the only statement in the block
        .where((statement) {
          final parentBlock = statement.parent as Block;

          return parentBlock.statements.length == 1;
        })
        // Ensure there is no blank line before the return statement, ignoring comments
        .where((statement) {
          final lineInfo = source.lineInfo;

          // Get the last non-comment token before the return statement
          final previousTokenLine = lineInfo
              .getLocation(statement.returnKeyword.previous!.end)
              .lineNumber;

          final tokenLine = lineInfo
              .getLocation(
                _optimalToken(statement.returnKeyword, lineInfo).offset,
              )
              .lineNumber;

          return tokenLine != previousTokenLine + 1;
        })
        .map((statement) => createIssue(
              rule: this,
              location: nodeLocation(node: statement, source: source),
              message: warning,
            ))
        .toList(growable: false);
  }
}

Token _optimalToken(Token token, LineInfo lineInfo) {
  var optimalToken = token;
  var commentToken = _latestCommentToken(token);

  while (commentToken != null) {
    final commentTokenLineNumber =
        lineInfo.getLocation(commentToken.end).lineNumber;
    final optimalTokenLineNumber =
        lineInfo.getLocation(optimalToken.offset).lineNumber;

    final isDirectlyPrecedingComment =
        commentTokenLineNumber + 1 >= optimalTokenLineNumber;

    if (!isDirectlyPrecedingComment) {
      break;
    }

    optimalToken = commentToken;
    commentToken = commentToken.previous;
  }

  return optimalToken;
}

Token? _latestCommentToken(Token token) {
  Token? latestCommentToken = token.precedingComments;

  while (latestCommentToken?.next != null) {
    latestCommentToken = latestCommentToken?.next;
  }

  return latestCommentToken;
}
