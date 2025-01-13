// library;

// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:crypto/crypto.dart';
// import 'package:dio/dio.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AutoSyncPlus {
//   final String _group = 'auto_sync_plus';

//   /// Helper to check network connectivity.
//   static Future<bool> hasInternetAccess() async {
//     var connectivityResult = await Connectivity().checkConnectivity();
//     return connectivityResult.any((ConnectivityResult result) => result != ConnectivityResult.none);
//   }

//   /// Helper to save data to shared preferences.
//   Future<void> saveToLocalStorage(String key, dynamic data) async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString("$_group.$key", jsonEncode(data));
//   }

//   /// Helper to load data from shared preferences.
//   Future<List<T>?> loadFromLocalStorage<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
//     final prefs = await SharedPreferences.getInstance();
//     final jsonString = prefs.getString("$_group.$key");
//     if (jsonString == null) return null;

//     final List<dynamic> decodedData = jsonDecode(jsonString);
//     return decodedData.map((item) => fromJson(item as Map<String, dynamic>)).toList();
//   }

//   /// Helper to download file and save it locally (e.g., image, pdf)
//   Future<String> downloadAndSaveFile(String url) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       //final fileName = url.split('/').last; // Extract file name from URL
//       //final filePath = '${directory.path}/$fileName';
//       final filePath = '${directory.path}/$_group/${_getUniqueFileNameFromUrl(url)}';

//       // Check if the file already exists
//       final file = File(filePath);
//       if (await file.exists()) {
//         log('File already exists at: $filePath');
//         return filePath; // Skip downloading if the file already exists
//       }

//       // Download the file using Dio
//       final response = await Dio().download(url, filePath);
//       if (response.statusCode == 200) {
//         return filePath; // Return the file path where it's saved
//       } else {
//         throw Exception('Failed to download file');
//       }
//     } catch (e) {
//       log('Error downloading file: $e');
//       return '';
//     }
//   }

//   String _getUniqueFileNameFromUrl(String url) {
//     // Extract the file extension from the URL
//     String extension = path.extension(url);

//     // Convert URL to a byte array and generate the hash
//     var bytes = utf8.encode(url);
//     var digest = sha256.convert(bytes); // You can use other hash algorithms like MD5 or SHA1 as well

//     // Create the unique file name by appending the extension
//     String uniqueFileName = digest.toString() + extension;

//     return uniqueFileName;
//   }

//   /// Helper to check if a file exists at the given local path
//   Future<bool> _fileExists(String localPath) async {
//     final file = File(localPath);
//     return await file.exists();
//   }

//   Future<String?> getSavedFilePath(String url) async {
//     final directory = await getApplicationDocumentsDirectory();
//     //final fileName = url.split('/').last; // Extract file name from URL
//     final filePath = '${directory.path}/$_group/${_getUniqueFileNameFromUrl(url)}';
//     if (await _fileExists(filePath)) {
//       return filePath;
//     }
//     return null;
//   }

//   /// Fetch and cache data with local file saving
//   Future<List<T>> fetchAndCacheData<T>(String key, Future<List<T>> Function() apiCall,
//       T Function(Map<String, dynamic>) fromJson, Map<String, dynamic> Function(T) toJson, // Serialization function
//       {bool cacheImage = true,
//       bool cachePDF = true} // New flags for caching
//       ) async {
//     if (await hasInternetAccess()) {
//       try {
//         // Fetch data from API
//         final data = await apiCall();

//         // Check if any URL contains an image or PDF, and download them
//         for (var item in data) {
//           final itemMap = toJson(item);
//           final List<String> urlsToDownload = [];

//           itemMap.forEach((key, value) {
//             if (value is String) {
//               // Add image URLs for caching if `cacheImage` is true
//               if (cacheImage && (value.endsWith('.jpg') || value.endsWith('.jpeg') || value.endsWith('.png'))) {
//                 urlsToDownload.add(value);
//               }

//               // Add PDF URLs for caching if `cachePDF` is true
//               if (cachePDF && value.endsWith('.pdf')) {
//                 urlsToDownload.add(value);
//               }
//             }
//           });

//           // Download files and update the item with local file paths
//           for (var url in urlsToDownload) {
//             final localPath = await downloadAndSaveFile(url);
//             if (localPath.isNotEmpty) {
//               // Replace the URL with the local file path
//               itemMap.update('localFilePath', (_) => localPath, ifAbsent: () => localPath);
//             }
//           }
//         }

//         // Save the updated data to local storage
//         await saveToLocalStorage(key, data.map((e) => toJson(e)).toList());
//         return data;
//       } catch (e) {
//         // On API error, fallback to local storage
//         return (await loadFromLocalStorage(key, fromJson)) ?? [];
//       }
//     } else {
//       // If offline, load from local storage
//       return (await loadFromLocalStorage(key, fromJson)) ?? [];
//     }
//   }

//   /// Delete all cached preferences under the `_group` namespace
//   Future<void> deleteCachedAllPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     final keysToDelete = prefs.getKeys().where((key) => key.startsWith('$_group.'));
//     for (var key in keysToDelete) {
//       await prefs.remove(key);
//     }
//   }

//   /// Delete all cached files under the `_group` directory with optional flags for selective deletion.
//   Future<void> deleteCachedAllFiles({bool deleteImage = true, bool deletePDF = true}) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final groupDirectory = Directory('${directory.path}/$_group');

//     if (await groupDirectory.exists()) {
//       // List all files in the directory
//       final files = groupDirectory.listSync(recursive: true).whereType<File>();

//       for (var file in files) {
//         final filePath = file.path;
//         final fileExtension = path.extension(filePath).toLowerCase();

//         // Check file type and delete based on flags
//         if ((deleteImage && (fileExtension == '.jpg' || fileExtension == '.jpeg' || fileExtension == '.png')) ||
//             (deletePDF && fileExtension == '.pdf') ||
//             (!deleteImage && !deletePDF)) {
//           await file.delete();
//         }
//       }

//       // If the directory is empty after file deletion, remove the directory
//       if (groupDirectory.listSync().isEmpty) {
//         await groupDirectory.delete();
//       }
//     }
//   }
// }
