import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:isar/isar.dart';

bool _isarInitialized = false;

Future<void> initializeIsarForTests() async {
  if (_isarInitialized) {
    return;
  }

  final packageRoot = await _isarFlutterLibsPackageRoot();
  final libraryPath = switch (Abi.current()) {
    Abi.macosArm64 || Abi.macosX64 => '$packageRoot/macos/libisar.dylib',
    Abi.linuxX64 => '$packageRoot/linux/libisar.so',
    Abi.windowsX64 => '$packageRoot/windows/isar.dll',
    _ => throw StateError('Unsupported Isar test ABI: ${Abi.current()}'),
  };

  await Isar.initializeIsarCore(
    libraries: <Abi, String>{Abi.current(): libraryPath},
  );
  _isarInitialized = true;
}

Future<String> _isarFlutterLibsPackageRoot() async {
  final configFile = File('.dart_tool/package_config.json').absolute;
  final config = jsonDecode(await configFile.readAsString()) as Map;
  final packages = config['packages'] as List;

  for (final package in packages.cast<Map>()) {
    if (package['name'] != 'isar_flutter_libs') {
      continue;
    }

    final rootUri = configFile.parent.uri.resolve(package['rootUri'] as String);
    return Directory.fromUri(rootUri).path;
  }

  throw StateError('Unable to resolve package:isar_flutter_libs.');
}
