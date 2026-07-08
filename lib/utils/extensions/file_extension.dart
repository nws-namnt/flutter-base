import 'dart:io' show File, Directory;

import 'package:image_picker/image_picker.dart' show XFile;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../app_logger.dart' show err;
import '../app_utils.dart' show genUniqueFileName;

/// Copies [sourcePath] into the app's temporary `Files` directory under a
/// collision-safe generated name, preserving the original extension.
///
/// Uses [getTemporaryDirectory] (not the documents directory) since these are
/// throwaway working copies — not user data that should be persisted or
/// backed up.
///
/// Returns `null` (and logs via [err]) if the copy fails, e.g. the source
/// file no longer exists or the destination can't be created.
Future<File?> _copyToTmpFiles(String sourcePath) async {
  try {
    final targetDir = await _tmpFilesDir();

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final ext = extension(sourcePath).replaceFirst('.', '');
    final fileName = genUniqueFileName(
      prefix: basenameWithoutExtension(sourcePath),
      fileExtension: ext.isEmpty ? 'tmp' : ext,
    );
    final newPath = join(targetDir.path, fileName);

    return await File(sourcePath).copy(newPath);
  } catch (e) {
    err('_copyToTmpFiles: $e');
    return null;
  }
}

/// Resolves the shared temporary `Files` directory used by
/// [_copyToTmpFiles], without creating it.
Future<Directory> _tmpFilesDir() async {
  final appDir = await getTemporaryDirectory();
  return Directory(join(appDir.path, 'Files'));
}

/// Deletes files inside the app's temporary `Files` directory (populated by
/// [XFileExtension.createTmpFileFrom] / [FileExtension.createTmpFileFrom])
/// that haven't been modified in the last [maxAge].
///
/// Call this once during app startup — see `main.dart`, ideally via
/// `unawaited(...)` so the sweep doesn't delay app launch — so throwaway
/// copies don't accumulate indefinitely across sessions. It's safe to call
/// on every launch: an empty/missing directory is a fast no-op.
///
/// [maxAge] defaults to 24 hours. Age is based on each file's filesystem
/// last-modified time ([FileSystemEntity.lastModified]) rather than a
/// name-embedded timestamp, so it works no matter how the file got there.
///
/// Returns the number of files deleted. A single file's stat/delete failure
/// (e.g. deleted concurrently, permission error) is logged via [err] and
/// skipped — it does not abort the rest of the sweep.
Future<int> clearExpiredTmpFiles({
  Duration maxAge = const Duration(hours: 24),
}) async {
  var deletedCount = 0;
  try {
    final targetDir = await _tmpFilesDir();
    if (!await targetDir.exists()) return 0;

    final cutoff = DateTime.now().subtract(maxAge);
    await for (final entity in targetDir.list()) {
      if (entity is! File) continue;
      try {
        final modified = await entity.lastModified();
        if (modified.isBefore(cutoff)) {
          await entity.delete();
          deletedCount++;
        }
      } catch (e) {
        err('clearExpiredTmpFiles: ${entity.path}: $e');
      }
    }
  } catch (e) {
    err('clearExpiredTmpFiles: $e');
  }
  return deletedCount;
}

/// Deletes the entire temporary `Files` directory outright, regardless of
/// file age.
///
/// Prefer [clearExpiredTmpFiles] for routine startup hygiene; reach for this
/// when a hard reset is needed instead — e.g. a "Clear cache" action in
/// Settings. Safe to call even if the directory doesn't exist.
Future<void> clearAllTmpFiles() async {
  try {
    final targetDir = await _tmpFilesDir();
    if (await targetDir.exists()) {
      await targetDir.delete(recursive: true);
    }
  } catch (e) {
    err('clearAllTmpFiles: $e');
  }
}

/// Extension helpers for copying an [XFile] into the app's own temp storage.
extension XFileExtension on XFile {
  /// Copies this file into the app's temporary `Files` directory under a
  /// new, collision-safe name (see [_copyToTmpFiles]).
  ///
  /// Useful right after picking a file (camera, gallery, file picker) when
  /// the original [path] lives in a location the app doesn't control — e.g.
  /// a cache the OS may clear, or a content:// URI that isn't a plain
  /// filesystem path.
  ///
  /// Returns `null` on failure instead of throwing.
  Future<XFile?> createTmpFileFrom() async {
    final newFile = await _copyToTmpFiles(path);
    return newFile == null ? null : XFile(newFile.path);
  }
}

/// Extension helpers for copying a [File] into the app's own temp storage.
extension FileExtension on File {
  /// Copies this file into the app's temporary `Files` directory under a
  /// new, collision-safe name (see [_copyToTmpFiles]).
  ///
  /// Returns `null` on failure instead of throwing.
  Future<File?> createTmpFileFrom() => _copyToTmpFiles(path);
}

