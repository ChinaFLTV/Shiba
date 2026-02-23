// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Shiba';

  @override
  String get preparingEnvironment => 'Preparing local inference environment…';

  @override
  String get bootFailed => 'Startup Failed';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabModels => 'Models';

  @override
  String get tabSettings => 'Settings';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSetting => 'Display Language';

  @override
  String get ttsSection => 'Text-to-Speech (TTS)';

  @override
  String get ttsModelTitle => 'MeloTTS Chinese-English Voice Model';

  @override
  String get ttsChecking => 'Checking...';

  @override
  String ttsDownloaded(String size) {
    return 'Downloaded · $size';
  }

  @override
  String get ttsNotDownloaded => 'Not downloaded · ~182MB';

  @override
  String get ttsDeleteTitle => 'Delete Voice Model';

  @override
  String get ttsDeleteContent =>
      'Are you sure you want to delete the TTS voice model?\nRead-aloud will be unavailable until re-downloaded.';

  @override
  String get ttsDownloadTitle => 'Download Voice Model';

  @override
  String get ttsDownloadPrompt =>
      'TTS voice model not yet downloaded (~182MB).\nDownload now?';

  @override
  String get ttsDownloadComplete => 'Voice model download complete';

  @override
  String get ttsDownloadFailed =>
      'Download failed, please check your network and retry';

  @override
  String get ttsAutoSwitch => 'Will auto-switch download source if too slow';

  @override
  String get ttsSpeakFailed => 'Read-aloud failed, please retry';

  @override
  String get ttsSpeed => 'Speed';

  @override
  String get download => 'Download';

  @override
  String get downloadComplete => 'Download Complete';

  @override
  String get downloadModel => 'Download Voice Model';

  @override
  String get imageSection => 'Image Processing';

  @override
  String get compressImage => 'Compress Images';

  @override
  String get maxResolution => 'Max Resolution';

  @override
  String get imageQuality => 'Image Quality';

  @override
  String get chatDefaultsSection => 'Chat Default Parameters';

  @override
  String get defaultSystemPrompt => 'Default System Prompt';

  @override
  String get defaultSystemPromptHint =>
      'Used for new chats; can be overridden per conversation';

  @override
  String get maxGenerationLength => 'Max Generation Length';

  @override
  String get historyRounds => 'History Rounds';

  @override
  String get historyRoundsAll => 'All';

  @override
  String get historyRoundsHint =>
      'Default history message rounds for new chats; 0 means all history';

  @override
  String get restoreDefaults => 'Restore Defaults';

  @override
  String get save => 'Save';

  @override
  String get defaultsSaved => 'Global default chat parameters saved';

  @override
  String get aboutSection => 'About';

  @override
  String version(String v) {
    return 'Version $v';
  }

  @override
  String get inferenceEngine => 'Inference Engine';

  @override
  String get modelSource => 'Model Source';

  @override
  String get modelSourceValue => 'hf-mirror.com (HuggingFace Mirror)';

  @override
  String get allInferenceOnDevice => 'Shiba · All inference runs on device';

  @override
  String copied(String text) {
    return 'Copied: $text';
  }

  @override
  String get conversations => 'Conversations';

  @override
  String loadFailed(String error) {
    return 'Load failed: $error';
  }

  @override
  String get noConversations => 'No conversations yet';

  @override
  String get tapToStartChat => 'Tap the button below to start a new chat';

  @override
  String get newChat => 'New Chat';

  @override
  String get pleaseDownloadModel => 'Please download a model first';

  @override
  String get selectModel => 'Select Model';

  @override
  String get deleteConversation => 'Delete Conversation';

  @override
  String get deleteConversationConfirm =>
      'Are you sure you want to delete this conversation?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'OK';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get renameConversation => 'Rename Conversation';

  @override
  String get enterNewTitle => 'Enter new title';

  @override
  String modelDeleted(String name) {
    return 'Model $name has been deleted, please re-download';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get noModelSelected => 'No model selected';

  @override
  String modelFileNotExist(String path) {
    return 'Model file does not exist, please re-download\nPath: $path';
  }

  @override
  String get visionProjectorFailed =>
      'Vision projector load failed, check if mmproj matches the current model';

  @override
  String get visionProjectorMissing =>
      'This model supports image input but is missing the vision projector (mmproj) file. Please download the corresponding mmproj file from the model repository';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get selectAll => 'Select All';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get conversationSettings => 'Chat Settings';

  @override
  String get inferenceError => 'Inference Error';

  @override
  String get details => 'Details';

  @override
  String get errorCopied => 'Error copied to clipboard';

  @override
  String get errorDetails => 'Error Details';

  @override
  String get copy => 'Copy';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get startConversation => 'Start a Conversation';

  @override
  String get chatWithShiba => 'Type your question to chat with Shiba';

  @override
  String get deleteMessage => 'Delete Message';

  @override
  String deleteMessageConfirm(String content) {
    return 'Delete this message?\n\n\"$content\"';
  }

  @override
  String get batchDelete => 'Batch Delete';

  @override
  String batchDeleteConfirm(int count) {
    return 'Delete $count selected messages? This cannot be undone.';
  }

  @override
  String get modelLoadFailedUnknown => 'Model load failed (unknown error)';

  @override
  String get modelLoadFailed => 'Model load failed';

  @override
  String get conversationSettingsTitle => 'Chat Settings';

  @override
  String get conversationTitle => 'Chat Title';

  @override
  String get systemPrompt => 'System Prompt';

  @override
  String get systemPromptHint => 'e.g. You are a professional translator';

  @override
  String get historyRoundsDescription =>
      'For assembling history messages; 0 means all history';

  @override
  String get copyAction => 'Copy';

  @override
  String get editAndResend => 'Edit & Resend';

  @override
  String get deleteAction => 'Delete';

  @override
  String get stopReading => 'Stop Reading';

  @override
  String get readAloud => 'Read Aloud';

  @override
  String get selectImage => 'Select Image';

  @override
  String get inputMessage => 'Type a message...';

  @override
  String get modelLoading => 'Loading model...';

  @override
  String get saveImageCopy => 'Save Copy';

  @override
  String get imageNotExist => 'Image file does not exist';

  @override
  String get imageSavedAndroid => 'Image saved to Pictures/Shiba';

  @override
  String imageSavedIos(String name) {
    return 'Image saved as $name';
  }

  @override
  String saveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get models => 'Models';

  @override
  String get searchModels => 'Search Models';

  @override
  String get noModels => 'No models yet';

  @override
  String get tapSearchToDownload =>
      'Tap the search button to download models from HuggingFace';

  @override
  String get downloading => 'Downloading';

  @override
  String get completed => 'Completed';

  @override
  String get failed => 'Failed';

  @override
  String get searchGgufModels => 'Search GGUF models (e.g. llama, qwen, phi)';

  @override
  String get search => 'Search';

  @override
  String get searchFromHf => 'Search GGUF models from HuggingFace Mirror';

  @override
  String searchFailed(String error) {
    return 'Search failed: $error';
  }

  @override
  String get noModelsFound => 'No matching models found';

  @override
  String downloadsCount(String count) {
    return '$count downloads';
  }

  @override
  String get ggufFiles => 'GGUF Files';

  @override
  String get noGgufFiles => 'No GGUF files in this repository';

  @override
  String availableMemory(String size) {
    return 'Available memory: ~$size';
  }

  @override
  String likesCount(String count) {
    return '$count likes';
  }

  @override
  String get suitabilityRecommended => 'Recommended';

  @override
  String get suitabilityOk => 'OK';

  @override
  String get suitabilityRisky => 'Risky';

  @override
  String get suitabilityTooLarge => 'Too Large';

  @override
  String alreadyInList(String name) {
    return '$name is already in the download list';
  }

  @override
  String startDownloadWithVision(String name) {
    return 'Downloading $name (with vision projector)';
  }

  @override
  String startDownload(String name) {
    return 'Downloading $name';
  }

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusDownloading => 'Downloading';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusFailed => 'Failed';

  @override
  String remaining(String time) {
    return '$time remaining';
  }

  @override
  String get paused => 'Paused';

  @override
  String get pauseAction => 'Pause';

  @override
  String get cancelDownload => 'Cancel Download';

  @override
  String get resumeDownload => 'Resume';

  @override
  String get cancelDownloadTitle => 'Cancel Download';

  @override
  String cancelDownloadContent(String name) {
    return 'Cancel downloading $name?\nDownloaded files will be deleted.';
  }

  @override
  String get continueDownload => 'Continue';

  @override
  String get deleteModel => 'Delete Model';

  @override
  String deleteModelContent(String name, String size) {
    return 'Delete $name?\nThis will free $size of storage.';
  }

  @override
  String get detailRepo => 'Repo';

  @override
  String get detailFilename => 'Filename';

  @override
  String get detailPath => 'Path';

  @override
  String get detailFileSize => 'File Size';

  @override
  String get detailQuantType => 'Quantization';

  @override
  String get detailDownloadTime => 'Downloaded';

  @override
  String get networkUnavailable =>
      'Network unavailable, please check your connection';

  @override
  String get downloadFailedGeneric => 'Download failed';

  @override
  String get downloadCancelled => 'Download cancelled';

  @override
  String get insufficientMemory => 'Insufficient memory to load this model';

  @override
  String get modelNotFound => 'Model file not found';

  @override
  String get inferenceErrorGeneric => 'An error occurred during inference';

  @override
  String get databaseError => 'Database operation failed';
}
