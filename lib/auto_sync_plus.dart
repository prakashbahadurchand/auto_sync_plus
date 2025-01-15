import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoSyncPlus {
  static final AutoSyncPlus _instance = AutoSyncPlus._internal();
  final String _group = 'auto_sync_plus';
  bool logging = false;

  factory AutoSyncPlus({bool logging = false}) {
    _instance.logging = logging;
    return _instance;
  }
  AutoSyncPlus._internal();

  void _log(String message) {
    if (logging) {
      dev.log("# ♻️ [AutoSyncPlus] :: $message");
    }
  }

  /// Checks network connectivity.
  Future<bool> hasInternetAccess() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult
        .any((ConnectivityResult result) => result != ConnectivityResult.none);
  }

  /// Saves data to cache.
  Future<void> saveToCache(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
    _log("Data saved to cache with key: $key");
  }

  /// Loads data from cache.
  Future<T?> loadFromCache<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    final Map<String, dynamic> decodedData = jsonDecode(jsonString);
    _log("Data loaded from cache with key: $key");
    return fromJson(decodedData);
  }

  /// Downloads a file and saves it locally.
  Future<String> downloadAndSaveFile(String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/auto_sync_plus/${_getUniqueFileNameFromUrl(url)}';
      final file = File(filePath);
      if (await file.exists()) {
        _log("File already exists at: $filePath");
        return filePath;
      }
      final response = await Dio().download(url, filePath);
      if (response.statusCode == 200) {
        _log("File downloaded and saved at: $filePath");
        return filePath;
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      _log("Error downloading file: $e");
      return '';
    }
  }

  String _getUniqueFileNameFromUrl(String url) {
    String extension = path.extension(url);
    var bytes = utf8.encode(url);
    var digest = sha256.convert(bytes);
    return digest.toString() + extension;
  }

  Future<bool> _fileExists(String localPath) async {
    return await File(localPath).exists();
  }

  /// Gets the saved file path for a given URL.
  Future<String?> getSavedFilePath(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/$_group/${_getUniqueFileNameFromUrl(url)}';
    return await _fileExists(filePath) ? filePath : null;
  }

  /// Fetches data from API, caches it, and downloads associated files.
  Future<T> fetchAndCacheData<T>({
    required String key,
    required Future<T> Function() apiCall,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
    bool cacheImage = true,
    bool cachePDF = true,
  }) async {
    if (await hasInternetAccess()) {
      try {
        final data = await apiCall();
        final itemMap = toJson(data);
        final List<String> urlsToDownload =
            _findUrlsToDownload(itemMap, cacheImage, cachePDF);
        _log("Urls to download: $urlsToDownload");
        for (var url in urlsToDownload) {
          final localPath = await downloadAndSaveFile(url);
          if (localPath.isNotEmpty) {
            _replaceUrlWithLocalPath(itemMap, url, localPath);
          }
        }
        await saveToCache(key, toJson(data));
        return data;
      } catch (e) {
        return (await loadFromCache(key, fromJson))!;
      }
    } else {
      return (await loadFromCache(key, fromJson))!;
    }
  }

  /// Fetches data from multiple APIs, caches it, and downloads associated files with progress stream.
  Stream<double> fetchAndCacheMultipleData<T>({
    required List<AutoSyncPlusParam<T>> params,
  }) async* {
    if (await hasInternetAccess()) {
      int totalCalls = params.length;
      int completedCalls = 0;

      for (var param in params) {
        try {
          final data = await param.apiCall();
          final itemMap = param.toJson(data);
          final List<String> urlsToDownload =
              _findUrlsToDownload(itemMap, param.cacheImage, param.cachePDF);
          _log("Urls to download: $urlsToDownload");
          for (var url in urlsToDownload) {
            final localPath = await downloadAndSaveFile(url);
            if (localPath.isNotEmpty) {
              _replaceUrlWithLocalPath(itemMap, url, localPath);
            }
          }
          await saveToCache(param.key, param.toJson(data));
          completedCalls++;
          yield completedCalls / totalCalls;
        } catch (e) {
          _log("Error fetching data for key: ${param.key} - $e");
        }
      }
    } else {
      _log("No internet access");
      yield 0.0;
    }
  }

  List<String> _findUrlsToDownload(
    Map<String, dynamic> itemMap,
    bool cacheImage,
    bool cachePDF,
  ) {
    final String itemMapString = jsonEncode(itemMap);
    final List<String> urls = [];
    final regex =
        RegExp(r'https?://[^\s,"]+\.(png|jpg|jpeg)', caseSensitive: false);

    // Match all the URLs in the input string
    final matches = regex.allMatches(itemMapString);

    for (var match in matches) {
      // Extract the URL from each match and add it to the list
      _log("Match URL: ${match.group(0)}");
      urls.add(match.group(0)!);
    }

    // Do not cache Images if `cacheImage` is false
    if (!cacheImage) {
      urls.removeWhere((url) =>
          url.toLowerCase().endsWith('.jpg') ||
          url.toLowerCase().endsWith('.jpeg') ||
          url.toLowerCase().endsWith('.png'));
    }

    // Do not cache PDFs if `cachePDF` is false
    if (!cachePDF) {
      urls.removeWhere((url) => url.toLowerCase().endsWith('.pdf'));
    }

    _log("Urls to download: $urls");

    return urls;
  }

  void _replaceUrlWithLocalPath(
      Map<String, dynamic> itemMap, String url, String localPath) {
    itemMap.forEach((key, value) {
      if (value is String && value == url) {
        itemMap[key] = localPath;
      } else if (value is Map<String, dynamic>) {
        _replaceUrlWithLocalPath(value, url, localPath);
      } else if (value is List) {
        for (var item in value) {
          if (item is Map<String, dynamic>) {
            _replaceUrlWithLocalPath(item, url, localPath);
          }
        }
      }
    });
  }

  /// Deletes all cached preferences under the `_group` namespace.
  Future<void> deleteCachedAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _log("All cached preferences deleted");
  }

  /// Deletes all cached files under the `_group` directory with optional flags for selective deletion.
  Future<void> deleteCachedAllFiles(
      {bool deleteImage = true, bool deletePDF = true}) async {
    final directory = await getApplicationDocumentsDirectory();
    final groupDirectory = Directory('${directory.path}/auto_sync_plus');

    if (await groupDirectory.exists()) {
      final files = groupDirectory.listSync(recursive: true).whereType<File>();
      for (var file in files) {
        final filePath = file.path;
        final fileExtension = path.extension(filePath).toLowerCase();
        if ((deleteImage &&
                (fileExtension == '.jpg' ||
                    fileExtension == '.jpeg' ||
                    fileExtension == '.png')) ||
            (deletePDF && fileExtension == '.pdf') ||
            (!deleteImage && !deletePDF)) {
          await file.delete();
          _log("Deleted file: $filePath");
        }
      }
      if (groupDirectory.listSync().isEmpty) {
        await groupDirectory.delete();
        _log("Deleted directory: ${groupDirectory.path}");
      }
    }
  }

  // For Post or Queue Management for Later Sync to Server:

  Future<void> postOrQueueData<T>({
    required String key,
    required Future<void> Function() apiCall,
    required T data,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final queueKey = '${key}_queue';

    try {
      // Attempt to make the API call
      await apiCall();
    } catch (e) {
      // If the API call fails, add the data to the queue
      final queue = prefs.getStringList(queueKey) ?? [];
      queue.add(jsonEncode(toJson(data)));
      await prefs.setStringList(queueKey, queue);
    }
  }

  Future<void> syncQueuedData<T>({
    required String key,
    required Future<void> Function(T data) apiCall,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final queueKey = '${key}_queue';
    final queue = prefs.getStringList(queueKey) ?? [];

    final remainingQueue = <String>[];

    for (final item in queue) {
      try {
        final data = fromJson(jsonDecode(item));
        await apiCall(data);
      } catch (e) {
        // If the API call fails, keep the item in the queue
        remainingQueue.add(item);
      }
    }

    // Update the queue with the remaining items
    await prefs.setStringList(queueKey, remainingQueue);
  }

  Future<bool> checkQueueExists(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final queueKey = '${key}_queue';
    final queue = prefs.getStringList(queueKey);
    return queue != null && queue.isNotEmpty;
  }
}


class AutoSyncPlusParam<T> {
  final String key;
  final Future<T> Function() apiCall;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final bool cacheImage;
  final bool cachePDF;

  AutoSyncPlusParam({
    required this.key,
    required this.apiCall,
    required this.fromJson,
    required this.toJson,
    this.cacheImage = true,
    this.cachePDF = true,
  });
}
