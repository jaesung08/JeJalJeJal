import 'dart:async';
import 'dart:io';

Future<FileSystemEntity?> recentFile(Directory recordDir) async {
  FileSystemEntity? target;
  await Future.delayed(const Duration(seconds: 1));
  print('66');

  if (await recordDir.exists()) {
    print('67');

    List<FileSystemEntity> files = await recordDir.list().toList();
    files
        .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    target = files.first;
  } else {
    print('68');

    target = null;
  }
  return target;
}
