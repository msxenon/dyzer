// ignore_for_file: implementation_imports
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/file_system.dart' hide File;
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/src/dart/analysis/byte_store.dart';
import 'package:analyzer/src/dart/analysis/file_byte_store.dart';
import 'package:crypto/crypto.dart';
import 'package:file/local.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';

import '../analyzer_plugin/analyzer_plugin.dart';
import '../cli/models/lint_file_model.dart';
import 'exclude_utils.dart';

class AnalyzerUtils {
  const AnalyzerUtils();

  bool isDirectory(String path) {
    final entityType = FileSystemEntity.typeSync(path);

    return entityType == FileSystemEntityType.directory;
  }

  AnalysisContextCollection createAnalysisContextCollection(
    Iterable<String> folders,
    String rootFolder,
    String? sdkPath,
  ) {
    final includedPaths =
        folders.map((path) => normalize(join(rootFolder, path))).toList();
    final resourceProvider = _prepareAnalysisOptions(includedPaths);

    return AnalysisContextCollectionImpl(
      sdkPath: sdkPath,
      includedPaths: includedPaths,
      resourceProvider: resourceProvider,
      byteStore: createByteStore(resourceProvider),
    );
  }

  Set<String> getFilePaths(
    Iterable<String> folders,
    AnalysisContext context,
    String rootFolder,
    Iterable<Glob> excludes,
  ) {
    final rootPath = context.contextRoot.root.path;

    final contextFolders = folders.where((path) {
      final normalizedPath = normalize(join(rootFolder, path));
      // root files like analysis_options.yaml might be in the folders path, so make sure its a directory and not a file
      if (!isDirectory(normalizedPath)) {
        return false;
      }

      return normalizedPath == rootPath ||
          normalizedPath.startsWith('$rootPath/');
    }).toList();

    return _extractDartFilesFromFolders(contextFolders, rootFolder, excludes);
  }

  /// If the state location can be accessed, return the file byte store,
  /// otherwise return the memory byte store.
  ByteStore createByteStore(ResourceProvider resourceProvider) {
    const miB = 1024 * 1024 /*1 MiB*/;
    const giB = 1024 * 1024 * 1024 /*1 GiB*/;

    const memoryCacheSize = miB * 128;

    final stateLocation = resourceProvider.getStateLocation('.dyzer');
    if (stateLocation != null) {
      return MemoryCachingByteStore(
        EvictingFileByteStore(stateLocation.path, giB),
        memoryCacheSize,
      );
    }

    return MemoryCachingByteStore(NullByteStore(), memoryCacheSize);
  }

  Set<String> _extractDartFilesFromFolders(
    Iterable<String> folders,
    String rootFolder,
    Iterable<Glob> globalExcludes,
  ) =>
      folders
          .expand((fileSystemEntity) => (fileSystemEntity.endsWith('.dart')
                  ? Glob(fileSystemEntity)
                  : Glob('$fileSystemEntity/**.dart'))
              .listFileSystemSync(
                const LocalFileSystem(),
                root: rootFolder,
                followLinks: false,
              )
              .whereType<File>()
              .where((entity) => !isExcluded(
                    relative(entity.path, from: rootFolder),
                    globalExcludes,
                  ))
              .map((entity) => normalize(entity.path)))
          .toSet();

  ResourceProvider _prepareAnalysisOptions(List<String> includedPaths) {
    final resourceProvider =
        OverlayResourceProvider(PhysicalResourceProvider.INSTANCE);

    final contextLocator = AnalysisContextCollection(
      resourceProvider: resourceProvider,
      includedPaths: includedPaths,
    );

    final roots = contextLocator.contexts
        .map((context) => context.contextRoot)
        .where((root) => root.optionsFile != null)
        .toList();

    for (final root in roots) {
      final path = root.optionsFile?.path;
      if (path != null) {
        resourceProvider.setOverlay(
          path,
          content: '',
          modificationStamp: DateTime.now().millisecondsSinceEpoch,
        );
      }
    }

    return resourceProvider;
  }

  bool isFileWhiteListed(String path) {
    final fileName = basename(path);

    for (final glob in AnalyzerPlugin.kfileGlobsToAnalyze) {
      if (glob.contains('*')) {
        final regex = RegExp(
          // ignore: prefer_interpolation_to_compose_strings
          '^' + glob.replaceAll('.', r'\.').replaceAll('*', '.*') + r'$',
        );
        if (regex.hasMatch(fileName)) {
          return true;
        }
      } else {
        if (glob == fileName) {
          return true;
        }
      }
    }

    return false;
  }

  String hashString(String input) {
    final bytes = utf8.encode(input);
    final hash = md5.convert(bytes);

    return hash.toString();
  }

  List<String>? filesToReanalyze(
    Map<String, LintFileModel>? files,
    Map<String, LintFileModel>? files2,
  ) {
    if (files == null && files2 == null) {
      return null;
    }
    if (files == null) {
      return files2!.keys.toList();
    }
    if (files2 == null) {
      return files.keys.toList();
    }
    final result = <String>[];

    for (final entry in files.entries) {
      final key = entry.key;
      final value = entry.value;

      final value2 = files2[key];
      if (value2 == null || value != value2) {
        result.add(key);
      }
    }

    return result;
  }

  Iterable<String> normalizeFoldersWildcards(
    List<String> folders,
    String rootFolder,
  ) {
    final safeFoldersList = <String>[];
    if (folders.isEmpty || (folders.length == 1 && folders.contains('.'))) {
      final dirsList = Directory(rootFolder).listSync().whereType<Directory>();
      for (final dir in dirsList) {
        final isValidDirName =
            !dir.uri.pathSegments.any((segment) => segment.startsWith('.'));
        if (isValidDirName && FileSystemEntity.isDirectorySync(dir.path)) {
          safeFoldersList.add(basename(dir.path));
        }
      }
    } else {
      safeFoldersList.addAll(folders);
    }

    return safeFoldersList;
  }
}
