import 'dart:io';
import '../state/eventer.dart';

class DownloadProgress {
  DownloadProgress(this.downloaded, this.total, this.speed);

  final int downloaded;
  final int total;
  final double speed;

  double get percent => (downloaded / total) * 100;
}

class HttpDownload extends Eventer<DownloadProgress> {
  HttpDownload(this.uri, this.file);

  final Uri uri;
  final File file;

  Future<void> download() async {
    final HttpClient client = HttpClient();
    final HttpClientRequest request = await client.getUrl(uri);
    final HttpClientResponse response = await request.close();

    int received = 0;
    final int total = response.headers['Content-Length']?.isNotEmpty ?? false
        ? int.parse(response.headers['Content-Length']!.first)
        : 0;
    final double startedAt = DateTime.now().millisecondsSinceEpoch / 1000;

    await response.map((final List<int> x) {
      received += x.length;
      final double now = DateTime.now().millisecondsSinceEpoch / 1000;

      dispatch(
        DownloadProgress(
          received,
          total,
          (now / startedAt) * received,
        ),
      );

      return x;
    }).pipe(file.openWrite());
  }
}
