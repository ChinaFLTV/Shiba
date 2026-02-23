// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class SZh extends S {
  SZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Shiba';

  @override
  String get preparingEnvironment => '正在准备本地推理环境…';

  @override
  String get bootFailed => '启动失败';

  @override
  String get tabChat => '对话';

  @override
  String get tabModels => '模型';

  @override
  String get tabSettings => '设置';

  @override
  String get settings => '设置';

  @override
  String get appearance => '外观';

  @override
  String get themeMode => '主题模式';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色模式';

  @override
  String get themeDark => '深色模式';

  @override
  String get language => '语言';

  @override
  String get languageSetting => '显示语言';

  @override
  String get ttsSection => '语音合成 (TTS)';

  @override
  String get ttsModelTitle => 'MeloTTS 中英文语音模型';

  @override
  String get ttsChecking => '检查中...';

  @override
  String ttsDownloaded(String size) {
    return '已下载 · $size';
  }

  @override
  String get ttsNotDownloaded => '未下载 · 约182MB';

  @override
  String get ttsDeleteTitle => '删除语音模型';

  @override
  String get ttsDeleteContent => '确定要删除已下载的TTS语音模型吗？\n删除后朗读功能将不可用，需要重新下载。';

  @override
  String get ttsDownloadTitle => '下载语音模型';

  @override
  String get ttsDownloadPrompt => 'TTS语音模型尚未下载（约182MB）。\n是否现在下载？';

  @override
  String get ttsDownloadComplete => '语音模型下载完成';

  @override
  String get ttsDownloadFailed => '下载失败，请检查网络后重试';

  @override
  String get ttsAutoSwitch => '速度过慢时会自动切换下载源';

  @override
  String get ttsSpeakFailed => '朗读失败，请重试';

  @override
  String get ttsSpeed => '语速';

  @override
  String get download => '下载';

  @override
  String get downloadComplete => '下载完成';

  @override
  String get downloadModel => '下载语音模型';

  @override
  String get imageSection => '图片处理';

  @override
  String get compressImage => '压缩图片';

  @override
  String get maxResolution => '最大分辨率';

  @override
  String get imageQuality => '图片质量';

  @override
  String get chatDefaultsSection => '对话默认参数';

  @override
  String get defaultSystemPrompt => '默认系统提示词';

  @override
  String get defaultSystemPromptHint => '新对话默认使用；可在对话设置中覆盖';

  @override
  String get maxGenerationLength => '最大生成长度';

  @override
  String get historyRounds => '历史轮数';

  @override
  String get historyRoundsAll => '全部';

  @override
  String get historyRoundsHint => '新建对话默认 history messages 使用该轮数；0 表示全部历史';

  @override
  String get restoreDefaults => '恢复默认';

  @override
  String get save => '保存';

  @override
  String get defaultsSaved => '全局默认对话参数已保存';

  @override
  String get aboutSection => '关于';

  @override
  String version(String v) {
    return '版本 $v';
  }

  @override
  String get inferenceEngine => '推理引擎';

  @override
  String get modelSource => '模型来源';

  @override
  String get modelSourceValue => 'hf-mirror.com (HuggingFace 镜像)';

  @override
  String get allInferenceOnDevice => 'Shiba · 所有推理均在设备上完成';

  @override
  String copied(String text) {
    return '已复制: $text';
  }

  @override
  String get conversations => '对话';

  @override
  String loadFailed(String error) {
    return '加载失败: $error';
  }

  @override
  String get noConversations => '还没有对话';

  @override
  String get tapToStartChat => '点击右下角按钮开始新对话';

  @override
  String get newChat => '新对话';

  @override
  String get pleaseDownloadModel => '请先下载一个模型';

  @override
  String get selectModel => '选择模型';

  @override
  String get deleteConversation => '删除对话';

  @override
  String get deleteConversationConfirm => '确定要删除这个对话吗？';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get confirm => '确定';

  @override
  String get close => '关闭';

  @override
  String get retry => '重试';

  @override
  String get renameConversation => '重命名对话';

  @override
  String get enterNewTitle => '输入新标题';

  @override
  String modelDeleted(String name) {
    return '模型 $name 已被删除，请重新下载';
  }

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int count) {
    return '$count分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count小时前';
  }

  @override
  String daysAgo(int count) {
    return '$count天前';
  }

  @override
  String get noModelSelected => '未选择模型';

  @override
  String modelFileNotExist(String path) {
    return '模型文件不存在，请重新下载\n路径: $path';
  }

  @override
  String get visionProjectorFailed => '视觉投影器加载失败，请检查 mmproj 是否与当前模型匹配';

  @override
  String get visionProjectorMissing =>
      '该模型支持图片输入，但缺少视觉投影器(mmproj)文件，请在模型仓库中下载对应的 mmproj 文件';

  @override
  String selectedCount(int count) {
    return '已选 $count 条';
  }

  @override
  String get selectAll => '全选';

  @override
  String get deleteSelected => '删除所选';

  @override
  String get conversationSettings => '对话设置';

  @override
  String get inferenceError => '推理错误';

  @override
  String get details => '详情';

  @override
  String get errorCopied => '错误信息已复制到剪贴板';

  @override
  String get errorDetails => '错误详情';

  @override
  String get copy => '复制';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get startConversation => '开始对话';

  @override
  String get chatWithShiba => '输入你的问题，与Shiba对话';

  @override
  String get deleteMessage => '删除消息';

  @override
  String deleteMessageConfirm(String content) {
    return '确定删除这条消息？\n\n\"$content\"';
  }

  @override
  String get batchDelete => '批量删除';

  @override
  String batchDeleteConfirm(int count) {
    return '确定删除选中的 $count 条消息？此操作不可撤销。';
  }

  @override
  String get modelLoadFailedUnknown => '模型加载失败（未知错误）';

  @override
  String get modelLoadFailed => '模型加载失败';

  @override
  String get conversationSettingsTitle => '对话设置';

  @override
  String get conversationTitle => '对话标题';

  @override
  String get systemPrompt => '系统提示词';

  @override
  String get systemPromptHint => '例如：你是一个专业的翻译助手';

  @override
  String get historyRoundsDescription => '用于拼接 history messages；0 表示使用全部历史';

  @override
  String get copyAction => '复制';

  @override
  String get editAndResend => '编辑并重发';

  @override
  String get deleteAction => '删除';

  @override
  String get stopReading => '停止朗读';

  @override
  String get readAloud => '朗读';

  @override
  String get selectImage => '选择图片';

  @override
  String get inputMessage => '输入消息...';

  @override
  String get modelLoading => '模型加载中...';

  @override
  String get saveImageCopy => '保存副本';

  @override
  String get imageNotExist => '图片文件不存在';

  @override
  String get imageSavedAndroid => '图片已保存到 Pictures/Shiba';

  @override
  String imageSavedIos(String name) {
    return '图片已保存到 $name';
  }

  @override
  String saveFailed(String error) {
    return '保存失败: $error';
  }

  @override
  String get models => '模型';

  @override
  String get searchModels => '搜索模型';

  @override
  String get noModels => '还没有模型';

  @override
  String get tapSearchToDownload => '点击右上角搜索按钮从 HuggingFace 下载模型';

  @override
  String get downloading => '下载中';

  @override
  String get completed => '已完成';

  @override
  String get failed => '失败';

  @override
  String get searchGgufModels => '搜索 GGUF 模型 (如: llama, qwen, phi)';

  @override
  String get search => '搜索';

  @override
  String get searchFromHf => '从 HuggingFace 镜像搜索 GGUF 模型';

  @override
  String searchFailed(String error) {
    return '搜索失败: $error';
  }

  @override
  String get noModelsFound => '没有找到相关模型';

  @override
  String downloadsCount(String count) {
    return '$count 下载';
  }

  @override
  String get ggufFiles => 'GGUF 文件';

  @override
  String get noGgufFiles => '该仓库没有 GGUF 文件';

  @override
  String availableMemory(String size) {
    return '可用内存: ~$size';
  }

  @override
  String likesCount(String count) {
    return '$count 喜欢';
  }

  @override
  String get suitabilityRecommended => '推荐';

  @override
  String get suitabilityOk => '可用';

  @override
  String get suitabilityRisky => '勉强';

  @override
  String get suitabilityTooLarge => '超出内存';

  @override
  String alreadyInList(String name) {
    return '$name 已在下载列表中';
  }

  @override
  String startDownloadWithVision(String name) {
    return '开始下载 $name（已自动附带视觉投影器）';
  }

  @override
  String startDownload(String name) {
    return '开始下载 $name';
  }

  @override
  String get statusCompleted => '已完成';

  @override
  String get statusDownloading => '下载中';

  @override
  String get statusPending => '等待中';

  @override
  String get statusPaused => '已暂停';

  @override
  String get statusFailed => '失败';

  @override
  String remaining(String time) {
    return '剩余 $time';
  }

  @override
  String get paused => '已暂停';

  @override
  String get pauseAction => '暂停';

  @override
  String get cancelDownload => '取消下载';

  @override
  String get resumeDownload => '继续下载';

  @override
  String get cancelDownloadTitle => '取消下载';

  @override
  String cancelDownloadContent(String name) {
    return '确定要取消下载 $name 吗？\n已下载的文件将被删除。';
  }

  @override
  String get continueDownload => '继续下载';

  @override
  String get deleteModel => '删除模型';

  @override
  String deleteModelContent(String name, String size) {
    return '确定要删除 $name 吗？\n这将释放 $size 的存储空间。';
  }

  @override
  String get detailRepo => '仓库';

  @override
  String get detailFilename => '文件名';

  @override
  String get detailPath => '路径';

  @override
  String get detailFileSize => '文件大小';

  @override
  String get detailQuantType => '量化类型';

  @override
  String get detailDownloadTime => '下载时间';

  @override
  String get networkUnavailable => '网络不可用，请检查网络连接';

  @override
  String get downloadFailedGeneric => '下载失败';

  @override
  String get downloadCancelled => '下载已取消';

  @override
  String get insufficientMemory => '内存不足，无法加载该模型';

  @override
  String get modelNotFound => '模型文件未找到';

  @override
  String get inferenceErrorGeneric => '推理过程发生错误';

  @override
  String get databaseError => '数据库操作失败';

  @override
  String get sttListening => '正在聆听...';

  @override
  String get sttNotAvailable => '语音识别不可用';

  @override
  String get sttMicPermissionDenied => '麦克风权限被拒绝';

  @override
  String get sttTooltip => '语音输入';

  @override
  String get sttDownloadTitle => '下载语音识别模型';

  @override
  String get sttDownloadPrompt => '语音识别模型尚未下载（约230MB）。\n是否现在下载？';

  @override
  String get sttDownloadModel => '下载语音识别模型';

  @override
  String get sttDownloadComplete => '语音识别模型下载完成';

  @override
  String get sttDownloadFailed => '下载失败，请检查网络后重试';

  @override
  String get sttRecognizing => '识别中...';

  @override
  String get sttRecognizeFailed => '语音识别失败，请重试';

  @override
  String get sttModelTitle => 'SenseVoice 语音识别模型';

  @override
  String get sttNotDownloaded => '未下载 · 约230MB';

  @override
  String sttDownloaded(String size) {
    return '已下载 · $size';
  }

  @override
  String get sttDeleteTitle => '删除语音识别模型';

  @override
  String get sttDeleteContent => '确定要删除已下载的语音识别模型吗？\n删除后语音输入功能将不可用，需要重新下载。';

  @override
  String get sttSection => '语音识别 (STT)';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class SZhHant extends SZh {
  SZhHant() : super('zh_Hant');

  @override
  String get appName => 'Shiba';

  @override
  String get preparingEnvironment => '正在準備本地推理環境…';

  @override
  String get bootFailed => '啟動失敗';

  @override
  String get tabChat => '對話';

  @override
  String get tabModels => '模型';

  @override
  String get tabSettings => '設定';

  @override
  String get settings => '設定';

  @override
  String get appearance => '外觀';

  @override
  String get themeMode => '主題模式';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get themeLight => '淺色模式';

  @override
  String get themeDark => '深色模式';

  @override
  String get language => '語言';

  @override
  String get languageSetting => '顯示語言';

  @override
  String get ttsSection => '語音合成 (TTS)';

  @override
  String get ttsModelTitle => 'MeloTTS 中英文語音模型';

  @override
  String get ttsChecking => '檢查中...';

  @override
  String ttsDownloaded(String size) {
    return '已下載 · $size';
  }

  @override
  String get ttsNotDownloaded => '未下載 · 約182MB';

  @override
  String get ttsDeleteTitle => '刪除語音模型';

  @override
  String get ttsDeleteContent => '確定要刪除已下載的TTS語音模型嗎？\n刪除後朗讀功能將不可用，需要重新下載。';

  @override
  String get ttsDownloadTitle => '下載語音模型';

  @override
  String get ttsDownloadPrompt => 'TTS語音模型尚未下載（約182MB）。\n是否現在下載？';

  @override
  String get ttsDownloadComplete => '語音模型下載完成';

  @override
  String get ttsDownloadFailed => '下載失敗，請檢查網路後重試';

  @override
  String get ttsAutoSwitch => '速度過慢時會自動切換下載源';

  @override
  String get ttsSpeakFailed => '朗讀失敗，請重試';

  @override
  String get ttsSpeed => '語速';

  @override
  String get download => '下載';

  @override
  String get downloadComplete => '下載完成';

  @override
  String get downloadModel => '下載語音模型';

  @override
  String get imageSection => '圖片處理';

  @override
  String get compressImage => '壓縮圖片';

  @override
  String get maxResolution => '最大解析度';

  @override
  String get imageQuality => '圖片品質';

  @override
  String get chatDefaultsSection => '對話預設參數';

  @override
  String get defaultSystemPrompt => '預設系統提示詞';

  @override
  String get defaultSystemPromptHint => '新對話預設使用；可在對話設定中覆蓋';

  @override
  String get maxGenerationLength => '最大生成長度';

  @override
  String get historyRounds => '歷史輪數';

  @override
  String get historyRoundsAll => '全部';

  @override
  String get historyRoundsHint => '新建對話預設 history messages 使用該輪數；0 表示全部歷史';

  @override
  String get restoreDefaults => '恢復預設';

  @override
  String get save => '儲存';

  @override
  String get defaultsSaved => '全域預設對話參數已儲存';

  @override
  String get aboutSection => '關於';

  @override
  String version(String v) {
    return '版本 $v';
  }

  @override
  String get inferenceEngine => '推理引擎';

  @override
  String get modelSource => '模型來源';

  @override
  String get modelSourceValue => 'hf-mirror.com (HuggingFace 鏡像)';

  @override
  String get allInferenceOnDevice => 'Shiba · 所有推理均在裝置上完成';

  @override
  String copied(String text) {
    return '已複製: $text';
  }

  @override
  String get conversations => '對話';

  @override
  String loadFailed(String error) {
    return '載入失敗: $error';
  }

  @override
  String get noConversations => '還沒有對話';

  @override
  String get tapToStartChat => '點擊右下角按鈕開始新對話';

  @override
  String get newChat => '新對話';

  @override
  String get pleaseDownloadModel => '請先下載一個模型';

  @override
  String get selectModel => '選擇模型';

  @override
  String get deleteConversation => '刪除對話';

  @override
  String get deleteConversationConfirm => '確定要刪除這個對話嗎？';

  @override
  String get cancel => '取消';

  @override
  String get delete => '刪除';

  @override
  String get confirm => '確定';

  @override
  String get close => '關閉';

  @override
  String get retry => '重試';

  @override
  String get renameConversation => '重新命名對話';

  @override
  String get enterNewTitle => '輸入新標題';

  @override
  String modelDeleted(String name) {
    return '模型 $name 已被刪除，請重新下載';
  }

  @override
  String get justNow => '剛剛';

  @override
  String minutesAgo(int count) {
    return '$count分鐘前';
  }

  @override
  String hoursAgo(int count) {
    return '$count小時前';
  }

  @override
  String daysAgo(int count) {
    return '$count天前';
  }

  @override
  String get noModelSelected => '未選擇模型';

  @override
  String modelFileNotExist(String path) {
    return '模型檔案不存在，請重新下載\n路徑: $path';
  }

  @override
  String get visionProjectorFailed => '視覺投影器載入失敗，請檢查 mmproj 是否與當前模型匹配';

  @override
  String get visionProjectorMissing =>
      '該模型支援圖片輸入，但缺少視覺投影器(mmproj)檔案，請在模型倉庫中下載對應的 mmproj 檔案';

  @override
  String selectedCount(int count) {
    return '已選 $count 條';
  }

  @override
  String get selectAll => '全選';

  @override
  String get deleteSelected => '刪除所選';

  @override
  String get conversationSettings => '對話設定';

  @override
  String get inferenceError => '推理錯誤';

  @override
  String get details => '詳情';

  @override
  String get errorCopied => '錯誤資訊已複製到剪貼簿';

  @override
  String get errorDetails => '錯誤詳情';

  @override
  String get copy => '複製';

  @override
  String get copiedToClipboard => '已複製到剪貼簿';

  @override
  String get startConversation => '開始對話';

  @override
  String get chatWithShiba => '輸入你的問題，與Shiba對話';

  @override
  String get deleteMessage => '刪除訊息';

  @override
  String deleteMessageConfirm(String content) {
    return '確定刪除這條訊息？\n\n\"$content\"';
  }

  @override
  String get batchDelete => '批次刪除';

  @override
  String batchDeleteConfirm(int count) {
    return '確定刪除選中的 $count 條訊息？此操作不可撤銷。';
  }

  @override
  String get modelLoadFailedUnknown => '模型載入失敗（未知錯誤）';

  @override
  String get modelLoadFailed => '模型載入失敗';

  @override
  String get conversationSettingsTitle => '對話設定';

  @override
  String get conversationTitle => '對話標題';

  @override
  String get systemPrompt => '系統提示詞';

  @override
  String get systemPromptHint => '例如：你是一個專業的翻譯助手';

  @override
  String get historyRoundsDescription => '用於拼接 history messages；0 表示使用全部歷史';

  @override
  String get copyAction => '複製';

  @override
  String get editAndResend => '編輯並重發';

  @override
  String get deleteAction => '刪除';

  @override
  String get stopReading => '停止朗讀';

  @override
  String get readAloud => '朗讀';

  @override
  String get selectImage => '選擇圖片';

  @override
  String get inputMessage => '輸入訊息...';

  @override
  String get modelLoading => '模型載入中...';

  @override
  String get saveImageCopy => '儲存副本';

  @override
  String get imageNotExist => '圖片檔案不存在';

  @override
  String get imageSavedAndroid => '圖片已儲存到 Pictures/Shiba';

  @override
  String imageSavedIos(String name) {
    return '圖片已儲存到 $name';
  }

  @override
  String saveFailed(String error) {
    return '儲存失敗: $error';
  }

  @override
  String get models => '模型';

  @override
  String get searchModels => '搜尋模型';

  @override
  String get noModels => '還沒有模型';

  @override
  String get tapSearchToDownload => '點擊右上角搜尋按鈕從 HuggingFace 下載模型';

  @override
  String get downloading => '下載中';

  @override
  String get completed => '已完成';

  @override
  String get failed => '失敗';

  @override
  String get searchGgufModels => '搜尋 GGUF 模型 (如: llama, qwen, phi)';

  @override
  String get search => '搜尋';

  @override
  String get searchFromHf => '從 HuggingFace 鏡像搜尋 GGUF 模型';

  @override
  String searchFailed(String error) {
    return '搜尋失敗: $error';
  }

  @override
  String get noModelsFound => '沒有找到相關模型';

  @override
  String downloadsCount(String count) {
    return '$count 下載';
  }

  @override
  String get ggufFiles => 'GGUF 檔案';

  @override
  String get noGgufFiles => '該倉庫沒有 GGUF 檔案';

  @override
  String availableMemory(String size) {
    return '可用記憶體: ~$size';
  }

  @override
  String likesCount(String count) {
    return '$count 喜歡';
  }

  @override
  String get suitabilityRecommended => '推薦';

  @override
  String get suitabilityOk => '可用';

  @override
  String get suitabilityRisky => '勉強';

  @override
  String get suitabilityTooLarge => '超出記憶體';

  @override
  String alreadyInList(String name) {
    return '$name 已在下載列表中';
  }

  @override
  String startDownloadWithVision(String name) {
    return '開始下載 $name（已自動附帶視覺投影器）';
  }

  @override
  String startDownload(String name) {
    return '開始下載 $name';
  }

  @override
  String get statusCompleted => '已完成';

  @override
  String get statusDownloading => '下載中';

  @override
  String get statusPending => '等待中';

  @override
  String get statusPaused => '已暫停';

  @override
  String get statusFailed => '失敗';

  @override
  String remaining(String time) {
    return '剩餘 $time';
  }

  @override
  String get paused => '已暫停';

  @override
  String get pauseAction => '暫停';

  @override
  String get cancelDownload => '取消下載';

  @override
  String get resumeDownload => '繼續下載';

  @override
  String get cancelDownloadTitle => '取消下載';

  @override
  String cancelDownloadContent(String name) {
    return '確定要取消下載 $name 嗎？\n已下載的檔案將被刪除。';
  }

  @override
  String get continueDownload => '繼續下載';

  @override
  String get deleteModel => '刪除模型';

  @override
  String deleteModelContent(String name, String size) {
    return '確定要刪除 $name 嗎？\n這將釋放 $size 的儲存空間。';
  }

  @override
  String get detailRepo => '倉庫';

  @override
  String get detailFilename => '檔案名';

  @override
  String get detailPath => '路徑';

  @override
  String get detailFileSize => '檔案大小';

  @override
  String get detailQuantType => '量化類型';

  @override
  String get detailDownloadTime => '下載時間';

  @override
  String get networkUnavailable => '網路不可用，請檢查網路連線';

  @override
  String get downloadFailedGeneric => '下載失敗';

  @override
  String get downloadCancelled => '下載已取消';

  @override
  String get insufficientMemory => '記憶體不足，無法載入該模型';

  @override
  String get modelNotFound => '模型檔案未找到';

  @override
  String get inferenceErrorGeneric => '推理過程發生錯誤';

  @override
  String get databaseError => '資料庫操作失敗';

  @override
  String get sttListening => '正在聆聽...';

  @override
  String get sttNotAvailable => '語音辨識不可用';

  @override
  String get sttMicPermissionDenied => '麥克風權限被拒絕';

  @override
  String get sttTooltip => '語音輸入';

  @override
  String get sttDownloadTitle => '下載語音辨識模型';

  @override
  String get sttDownloadPrompt => '語音辨識模型尚未下載（約230MB）。\n是否現在下載？';

  @override
  String get sttDownloadModel => '下載語音辨識模型';

  @override
  String get sttDownloadComplete => '語音辨識模型下載完成';

  @override
  String get sttDownloadFailed => '下載失敗，請檢查網路後重試';

  @override
  String get sttRecognizing => '辨識中...';

  @override
  String get sttRecognizeFailed => '語音辨識失敗，請重試';

  @override
  String get sttModelTitle => 'SenseVoice 語音辨識模型';

  @override
  String get sttNotDownloaded => '未下載 · 約230MB';

  @override
  String sttDownloaded(String size) {
    return '已下載 · $size';
  }

  @override
  String get sttDeleteTitle => '刪除語音辨識模型';

  @override
  String get sttDeleteContent => '確定要刪除已下載的語音辨識模型嗎？\n刪除後語音輸入功能將不可用，需要重新下載。';

  @override
  String get sttSection => '語音辨識 (STT)';
}
