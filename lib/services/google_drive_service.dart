import 'dart:convert';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class GoogleDriveService {
  static const String _backupFileName = 'shiftly_backup.json';

  final _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  Future<GoogleSignInAccount?> signIn() async {
    if (!kIsWeb && Platform.isWindows) {
      debugPrint('Google Sign In is not natively supported on Windows via the official package.');
      return null;
    }
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb && Platform.isWindows) return;
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google Sign Out Error: $e');
    }
  }

  Future<void> uploadBackup(Map<String, dynamic> data) async {
    final httpClient = (await _googleSignIn.authenticatedClient());
    if (httpClient == null) return;

    final driveApi = drive.DriveApi(httpClient);
    final jsonContent = jsonEncode(data);
    final media = drive.Media(
      Stream.value(utf8.encode(jsonContent)),
      jsonContent.length,
    );

    final fileList = await driveApi.files.list(
      q: "name = '$_backupFileName'",
      spaces: 'appDataFolder',
    );

    if (fileList.files?.isNotEmpty ?? false) {
      await driveApi.files.update(
        drive.File(),
        fileList.files!.first.id!,
        uploadMedia: media,
      );
    } else {
      final driveFile = drive.File()
        ..name = _backupFileName
        ..parents = ['appDataFolder'];
      await driveApi.files.create(driveFile, uploadMedia: media);
    }
  }

  Future<Map<String, dynamic>?> downloadBackup() async {
    final httpClient = (await _googleSignIn.authenticatedClient());
    if (httpClient == null) return null;

    final driveApi = drive.DriveApi(httpClient);
    final fileList = await driveApi.files.list(
      q: "name = '$_backupFileName'",
      spaces: 'appDataFolder',
    );

    if (fileList.files?.isEmpty ?? true) return null;

    final response =
        await driveApi.files.get(
              fileList.files!.first.id!,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;

    final List<int> dataStore = [];
    await for (final data in response.stream) {
      dataStore.addAll(data);
    }
    return jsonDecode(utf8.decode(dataStore));
  }
}
