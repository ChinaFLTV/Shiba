class AppConstants {
  static const String appName = '本地大模型';
  static const String hfMirrorBaseUrl = 'https://hf-mirror.com';
  static const String hfApiModelsUrl = '$hfMirrorBaseUrl/api/models';
  static const String modelsSubDir = 'models';
  static const String dbName = 'local_model.db';
  static const int searchPageSize = 20;
  static const int maxConcurrentDownloads = 1;
  static const Duration httpTimeout = Duration(seconds: 30);
  static const int defaultContextSize = 2048;
  static const int defaultThreads = 4;
  static const double defaultTemperature = 0.7;
  static const double defaultTopP = 0.9;
  static const int defaultTopK = 40;
  static const int defaultMaxTokens = 1024;

  // TTS defaults
  static const double defaultTtsSpeed = 1.0;
}

class ErrorMessages {
  static const String networkUnavailable = '网络不可用，请检查网络连接';
  static const String modelLoadFailed = '模型加载失败';
  static const String downloadFailed = '下载失败';
  static const String downloadCancelled = '下载已取消';
  static const String insufficientMemory = '内存不足，无法加载该模型';
  static const String modelNotFound = '模型文件未找到';
  static const String inferenceError = '推理过程发生错误';
  static const String inferenceCrashed = 'Native inference crashed unexpectedly';
  static const String cpuIncompatible =
      '当前设备CPU不支持I8MM指令集（需要ARMv8.6-A+），'
      '无法运行本地推理。\n\n'
      '已知不兼容的SoC：Snapdragon 860/870/865及更早型号。\n'
      '建议在支持ARMv8.6-A的设备上使用（如Snapdragon 8 Gen1及以上）。';
  static const String databaseError = '数据库操作失败';
}
