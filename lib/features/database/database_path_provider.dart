import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Centralized database path resolution.
///
/// Single source of truth for where the SQLite database file lives.
/// All components (database, backup service, developer tools) must use
/// this class instead of resolving paths independently.
///
/// **Release mode:** `{drive_of_exe}:\.aba_data\aba_donation.sqlite`
/// **Debug mode:** `{Documents}\aba_donation.sqlite`
class DatabasePathProvider {
  static const String _folderName = '.aba_data';
  static const String _dbFileName = 'aba_donation.sqlite';

  /// Cached path after first resolution to avoid repeated I/O.
  static String? _cachedPath;

  /// Returns the absolute path to the database file.
  ///
  /// In release mode, the database is stored in a hidden `.aba_data` folder
  /// at the root of the drive where the application executable resides.
  /// If write permission is denied, falls back to the Documents folder.
  ///
  /// In debug mode, the database is always stored in the Documents folder.
  static Future<String> getDatabasePath() async {
    if (_cachedPath != null) return _cachedPath!;

    String resolvedPath;

    if (kReleaseMode) {
      resolvedPath = await _resolveReleasePath();
    } else {
      resolvedPath = await _resolveDebugPath();
    }

    _cachedPath = resolvedPath;
    return resolvedPath;
  }

  /// Returns the directory containing the database file.
  static Future<String> getDatabaseDirectory() async {
    final dbPath = await getDatabasePath();
    return p.dirname(dbPath);
  }

  /// Clears the cached path (useful for testing or reconfiguration).
  static void clearCache() {
    _cachedPath = null;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Resolve the database path for release mode.
  /// Uses the drive root of the running executable.
  static Future<String> _resolveReleasePath() async {
    try {
      final exePath = Platform.resolvedExecutable;
      final driveRoot = p.rootPrefix(exePath); // e.g. "E:\"
      final dataDir = Directory(p.join(driveRoot, _folderName));

      // Create the hidden folder if it doesn't exist
      if (!await dataDir.exists()) {
        await dataDir.create(recursive: true);
        await _markHidden(dataDir);
        debugPrint('📁 Created hidden database folder: ${dataDir.path}');
      }

      final dbFile = File(p.join(dataDir.path, _dbFileName));

      // Auto-migrate: if NO database exists at the new location,
      // check the old Documents folder and copy it over.
      if (!await dbFile.exists()) {
        await _migrateFromDocuments(dbFile);
      }

      // Verify write permission by touching the directory
      try {
        await dbFile.parent.create(recursive: true);
      } catch (e) {
        debugPrint('⚠️ Write permission denied at ${dataDir.path}. '
            'Falling back to Documents. Error: $e');
        return await _resolveDebugPath();
      }

      debugPrint('✅ Database path (release): ${dbFile.path}');
      return dbFile.path;
    } catch (e) {
      debugPrint('⚠️ Failed to resolve release DB path. '
          'Falling back to Documents. Error: $e');
      return await _resolveDebugPath();
    }
  }

  /// Resolve the database path for debug mode (Documents folder).
  static Future<String> _resolveDebugPath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final path = p.join(dbFolder.path, _dbFileName);
    debugPrint('✅ Database path (debug): $path');
    return path;
  }

  /// Mark a directory as hidden on Windows using `attrib +h`.
  static Future<void> _markHidden(Directory dir) async {
    if (!Platform.isWindows) return;
    try {
      await Process.run('attrib', ['+h', dir.path]);
      debugPrint('🔒 Marked folder as hidden: ${dir.path}');
    } catch (e) {
      debugPrint('⚠️ Failed to mark folder as hidden: $e');
      // Non-critical — continue even if hiding fails
    }
  }

  /// One-time migration: copy database from old Documents location to new
  /// drive-root location. This ensures zero data loss when upgrading from
  /// an older release that stored the database in Documents.
  static Future<void> _migrateFromDocuments(File targetDbFile) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final oldDbFile = File(p.join(docsDir.path, _dbFileName));

      if (await oldDbFile.exists()) {
        debugPrint('📦 Found existing database at old location: ${oldDbFile.path}');
        debugPrint('📦 Migrating to new location: ${targetDbFile.path}');

        // Copy the main database file
        await oldDbFile.copy(targetDbFile.path);

        // Also copy WAL and SHM files if they exist (for WAL mode)
        final oldWal = File('${oldDbFile.path}-wal');
        final oldShm = File('${oldDbFile.path}-shm');
        if (await oldWal.exists()) {
          await oldWal.copy('${targetDbFile.path}-wal');
        }
        if (await oldShm.exists()) {
          await oldShm.copy('${targetDbFile.path}-shm');
        }

        debugPrint('✅ Database migration from Documents complete.');

        // Leave the old file in place as a safety net.
        // It won't be used anymore since the new path takes priority.
      } else {
        debugPrint('ℹ️ No existing database found at old location. '
            'A fresh database will be created.');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to migrate database from Documents: $e');
      // Non-critical — a fresh database will be created at the new location
    }
  }
}
