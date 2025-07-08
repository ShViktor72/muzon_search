import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class DownloadService {
  static final Dio _dio = Dio();

  static Future<void> downloadFile(String url, String folderPath, String fileName,
      {Function(int, int)? onProgress}) async {
    final savePath = p.join(folderPath, fileName);

    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        options: Options(responseType: ResponseType.bytes, followRedirects: false, validateStatus: (status) => status! < 500),
      );
    } catch (e) {
      rethrow;
    }
  }
}
