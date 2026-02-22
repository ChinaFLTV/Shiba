/// Represents a model from HuggingFace Hub API
class HfModel {
  final String modelId;
  final String? author;
  final int downloads;
  final int likes;
  final String? pipelineTag;
  final List<String> tags;
  final DateTime? lastModified;

  const HfModel({
    required this.modelId,
    this.author,
    required this.downloads,
    required this.likes,
    this.pipelineTag,
    required this.tags,
    this.lastModified,
  });

  String get displayName {
    final parts = modelId.split('/');
    return parts.length > 1 ? parts.last : modelId;
  }

  String get downloadsFormatted {
    if (downloads >= 1000000) {
      return '${(downloads / 1000000).toStringAsFixed(1)}M';
    }
    if (downloads >= 1000) {
      return '${(downloads / 1000).toStringAsFixed(1)}K';
    }
    return '$downloads';
  }

  factory HfModel.fromJson(Map<String, dynamic> json) => HfModel(
        modelId: json['modelId'] as String? ?? json['id'] as String? ?? '',
        author: json['author'] as String?,
        downloads: json['downloads'] as int? ?? 0,
        likes: json['likes'] as int? ?? 0,
        pipelineTag: json['pipeline_tag'] as String?,
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        lastModified: json['lastModified'] != null
            ? DateTime.tryParse(json['lastModified'] as String)
            : null,
      );
}

/// Represents a single file in a HuggingFace repo
class HfModelFile {
  final String filename;
  final int size;
  final String rfilename;

  const HfModelFile({
    required this.filename,
    required this.size,
    required this.rfilename,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  bool get isGguf => filename.toLowerCase().endsWith('.gguf');

  /// Extract quantization type from filename (e.g. Q4_K_M, Q8_0, F16, F32)
  String get quantization {
    final upper = filename.toUpperCase();
    final match = RegExp(r'[_\-\.](Q[0-9]+_[A-Z0-9_]+|F16|F32|IQ[0-9]+_[A-Z]+|BF16)[\._\-]')
        .firstMatch(upper);
    if (match != null) return match.group(1)!;
    final simple = RegExp(r'[_\-\.](Q[0-9]+_[0-9]+)[\._\-]').firstMatch(upper);
    if (simple != null) return simple.group(1)!;
    return '';
  }

  factory HfModelFile.fromJson(Map<String, dynamic> json) {
    final path = json['path'] as String? ?? json['rfilename'] as String? ?? '';
    return HfModelFile(
      filename: path.split('/').last,
      size: json['size'] as int? ?? 0,
      rfilename: path,
    );
  }
}
