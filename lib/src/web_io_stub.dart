// lib/src/web_io_stub.dart
class File {
  final String path;
  File(this.path);
  Future<bool> exists() async => false;
  Future<String> readAsString({Object? encoding}) async =>
      throw UnsupportedError("Stub");
  Future<File> writeAsString(String contents,
          {Object? mode, Object? encoding, Object? flush}) async =>
      throw UnsupportedError("Stub");
}
// Add other dart:io stubs if needed by other parts of your code
