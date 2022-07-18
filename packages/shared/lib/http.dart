import 'package:http/http.dart';

export 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes;

final Client client = Client();
