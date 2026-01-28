// lib/src/web_path_provider_stub.dart
Future<Directory> getApplicationDocumentsDirectory() async {
  throw UnsupportedError(
      "getApplicationDocumentsDirectory is not supported on web.");
}

class Directory {
  final String path;
  Directory(this.path);
}
