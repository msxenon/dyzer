import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:source_span/source_span.dart';

class IgnoredIssueModel with EquatableMixin {
  final String hash;

  const IgnoredIssueModel(this.hash);

  factory IgnoredIssueModel.fromIssue({
    required SourceLocation start,
    required SourceLocation end,
    required String content,
    required int indexInFile,
  }) {
    final fullHighlightedCleanCode =
        content.substring(start.offset, end.offset);

    return fromString(fullHighlightedCleanCode, indexInFile);
  }

  factory IgnoredIssueModel.fromMap(String json) => IgnoredIssueModel(json);

  String toJson() => hash;

  // ignore: prefer_constructors_over_static_methods
  static IgnoredIssueModel fromString(String str, int indexInFile) {
    final fullHighlightedCleanCode = str
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'//.*?\n|/\*.*?\*/', dotAll: true), '');
    final fingerPrint = '$fullHighlightedCleanCode$indexInFile';

    final bytes = utf8.encode(fingerPrint);
    final hash = md5.convert(bytes);

    return IgnoredIssueModel(hash.toString());
  }

  @override
  List<Object?> get props => [hash];

  @override
  String toString() => hash;
}
