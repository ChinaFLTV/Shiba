import 'package:dio/dio.dart';
import 'package:shiba/core/constants.dart';
import 'package:shiba/data/models/hf_model.dart';

class HfApiService {
  late final Dio _dio;

  HfApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.hfMirrorBaseUrl,
      connectTimeout: AppConstants.httpTimeout,
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  /// Search GGUF models from hf-mirror.com
  Future<List<HfModel>> searchModels(String query, {int offset = 0}) async {
    try {
      final response = await _dio.get('/api/models', queryParameters: {
        'search': query,
        'library': 'gguf',
        'sort': 'downloads',
        'direction': '-1',
        'limit': AppConstants.searchPageSize,
        'offset': offset,
      });
      final list = response.data as List<dynamic>;
      return list
          .map((e) => HfModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('${ErrorMessages.networkUnavailable}: ${e.message}');
    }
  }

  /// Get all files for a specific model repo, filtered to GGUF only
  Future<List<HfModelFile>> getModelFiles(String repoId) async {
    try {
      final response = await _dio.get('/api/models/$repoId/tree/main');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => HfModelFile.fromJson(e as Map<String, dynamic>))
          .where((f) => f.isGguf)
          .toList()
        ..sort((a, b) => a.size.compareTo(b.size));
    } on DioException catch (e) {
      throw Exception('${ErrorMessages.networkUnavailable}: ${e.message}');
    }
  }

  /// Build download URL for a file
  String getDownloadUrl(String repoId, String rfilename) {
    return '${AppConstants.hfMirrorBaseUrl}/$repoId/resolve/main/$rfilename';
  }
}
