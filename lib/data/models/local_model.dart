enum ModelStatus { pending, downloading, paused, completed, failed }

class LocalModel {
  final String id;
  final String repoId;
  final String filename;
  final String filePath;
  final int fileSize;
  final int downloadedSize;
  final ModelStatus status;
  final String downloadUrl;
  final DateTime createdAt;

  const LocalModel({
    required this.id,
    required this.repoId,
    required this.filename,
    required this.filePath,
    required this.fileSize,
    required this.downloadedSize,
    required this.status,
    required this.downloadUrl,
    required this.createdAt,
  });

  double get progress =>
      fileSize > 0 ? downloadedSize / fileSize : 0.0;

  String get displayName {
    final parts = repoId.split('/');
    return parts.length > 1 ? parts.last : repoId;
  }

  /// Extract quantization type from filename (e.g. Q4_K_M, Q8_0, F16, F32)
  String get quantization {
    final upper = filename.toUpperCase();
    // Match common GGUF quantization patterns
    final match = RegExp(r'[_\-\.](Q[0-9]+_[A-Z0-9_]+|F16|F32|IQ[0-9]+_[A-Z]+|BF16)[\._\-]')
        .firstMatch(upper);
    if (match != null) return match.group(1)!;
    // Fallback: try simpler pattern like Q4_0, Q5_1
    final simple = RegExp(r'[_\-\.](Q[0-9]+_[0-9]+)[\._\-]').firstMatch(upper);
    if (simple != null) return simple.group(1)!;
    return '';
  }

  /// Author / organization from repoId
  String get author {
    final parts = repoId.split('/');
    return parts.length > 1 ? parts.first : '';
  }

  String get createdAtFormatted {
    final d = createdAt;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String get fileSizeFormatted => _formatBytes(fileSize);
  String get downloadedSizeFormatted => _formatBytes(downloadedSize);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'repo_id': repoId,
        'filename': filename,
        'file_path': filePath,
        'file_size': fileSize,
        'downloaded_size': downloadedSize,
        'status': status.name,
        'download_url': downloadUrl,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory LocalModel.fromMap(Map<String, dynamic> map) => LocalModel(
        id: map['id'] as String,
        repoId: map['repo_id'] as String,
        filename: map['filename'] as String,
        filePath: map['file_path'] as String,
        fileSize: map['file_size'] as int,
        downloadedSize: map['downloaded_size'] as int,
        status: ModelStatus.values.byName(map['status'] as String),
        downloadUrl: map['download_url'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );

  LocalModel copyWith({
    int? downloadedSize,
    ModelStatus? status,
    String? filePath,
  }) =>
      LocalModel(
        id: id,
        repoId: repoId,
        filename: filename,
        filePath: filePath ?? this.filePath,
        fileSize: fileSize,
        downloadedSize: downloadedSize ?? this.downloadedSize,
        status: status ?? this.status,
        downloadUrl: downloadUrl,
        createdAt: createdAt,
      );
}
