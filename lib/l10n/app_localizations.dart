import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'Shiba'**
  String get appName;

  /// No description provided for @preparingEnvironment.
  ///
  /// In zh, this message translates to:
  /// **'正在准备本地推理环境…'**
  String get preparingEnvironment;

  /// No description provided for @bootFailed.
  ///
  /// In zh, this message translates to:
  /// **'启动失败'**
  String get bootFailed;

  /// No description provided for @tabChat.
  ///
  /// In zh, this message translates to:
  /// **'对话'**
  String get tabChat;

  /// No description provided for @tabModels.
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get tabModels;

  /// No description provided for @tabSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get tabSettings;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get appearance;

  /// No description provided for @themeMode.
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @languageSetting.
  ///
  /// In zh, this message translates to:
  /// **'显示语言'**
  String get languageSetting;

  /// No description provided for @ttsSection.
  ///
  /// In zh, this message translates to:
  /// **'语音合成 (TTS)'**
  String get ttsSection;

  /// No description provided for @ttsModelTitle.
  ///
  /// In zh, this message translates to:
  /// **'MeloTTS 中英文语音模型'**
  String get ttsModelTitle;

  /// No description provided for @ttsChecking.
  ///
  /// In zh, this message translates to:
  /// **'检查中...'**
  String get ttsChecking;

  /// No description provided for @ttsDownloaded.
  ///
  /// In zh, this message translates to:
  /// **'已下载 · {size}'**
  String ttsDownloaded(String size);

  /// No description provided for @ttsNotDownloaded.
  ///
  /// In zh, this message translates to:
  /// **'未下载 · 约182MB'**
  String get ttsNotDownloaded;

  /// No description provided for @ttsDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除语音模型'**
  String get ttsDeleteTitle;

  /// No description provided for @ttsDeleteContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除已下载的TTS语音模型吗？\n删除后朗读功能将不可用，需要重新下载。'**
  String get ttsDeleteContent;

  /// No description provided for @ttsDownloadTitle.
  ///
  /// In zh, this message translates to:
  /// **'下载语音模型'**
  String get ttsDownloadTitle;

  /// No description provided for @ttsDownloadPrompt.
  ///
  /// In zh, this message translates to:
  /// **'TTS语音模型尚未下载（约182MB）。\n是否现在下载？'**
  String get ttsDownloadPrompt;

  /// No description provided for @ttsDownloadComplete.
  ///
  /// In zh, this message translates to:
  /// **'语音模型下载完成'**
  String get ttsDownloadComplete;

  /// No description provided for @ttsDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'下载失败，请检查网络后重试'**
  String get ttsDownloadFailed;

  /// No description provided for @ttsAutoSwitch.
  ///
  /// In zh, this message translates to:
  /// **'速度过慢时会自动切换下载源'**
  String get ttsAutoSwitch;

  /// No description provided for @ttsSpeakFailed.
  ///
  /// In zh, this message translates to:
  /// **'朗读失败，请重试'**
  String get ttsSpeakFailed;

  /// No description provided for @ttsSpeed.
  ///
  /// In zh, this message translates to:
  /// **'语速'**
  String get ttsSpeed;

  /// No description provided for @download.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get download;

  /// No description provided for @downloadComplete.
  ///
  /// In zh, this message translates to:
  /// **'下载完成'**
  String get downloadComplete;

  /// No description provided for @downloadModel.
  ///
  /// In zh, this message translates to:
  /// **'下载语音模型'**
  String get downloadModel;

  /// No description provided for @imageSection.
  ///
  /// In zh, this message translates to:
  /// **'图片处理'**
  String get imageSection;

  /// No description provided for @compressImage.
  ///
  /// In zh, this message translates to:
  /// **'压缩图片'**
  String get compressImage;

  /// No description provided for @maxResolution.
  ///
  /// In zh, this message translates to:
  /// **'最大分辨率'**
  String get maxResolution;

  /// No description provided for @imageQuality.
  ///
  /// In zh, this message translates to:
  /// **'图片质量'**
  String get imageQuality;

  /// No description provided for @chatDefaultsSection.
  ///
  /// In zh, this message translates to:
  /// **'对话默认参数'**
  String get chatDefaultsSection;

  /// No description provided for @defaultSystemPrompt.
  ///
  /// In zh, this message translates to:
  /// **'默认系统提示词'**
  String get defaultSystemPrompt;

  /// No description provided for @defaultSystemPromptHint.
  ///
  /// In zh, this message translates to:
  /// **'新对话默认使用；可在对话设置中覆盖'**
  String get defaultSystemPromptHint;

  /// No description provided for @maxGenerationLength.
  ///
  /// In zh, this message translates to:
  /// **'最大生成长度'**
  String get maxGenerationLength;

  /// No description provided for @historyRounds.
  ///
  /// In zh, this message translates to:
  /// **'历史轮数'**
  String get historyRounds;

  /// No description provided for @historyRoundsAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get historyRoundsAll;

  /// No description provided for @historyRoundsHint.
  ///
  /// In zh, this message translates to:
  /// **'新建对话默认 history messages 使用该轮数；0 表示全部历史'**
  String get historyRoundsHint;

  /// No description provided for @restoreDefaults.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认'**
  String get restoreDefaults;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @defaultsSaved.
  ///
  /// In zh, this message translates to:
  /// **'全局默认对话参数已保存'**
  String get defaultsSaved;

  /// No description provided for @aboutSection.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get aboutSection;

  /// No description provided for @version.
  ///
  /// In zh, this message translates to:
  /// **'版本 {v}'**
  String version(String v);

  /// No description provided for @inferenceEngine.
  ///
  /// In zh, this message translates to:
  /// **'推理引擎'**
  String get inferenceEngine;

  /// No description provided for @modelSource.
  ///
  /// In zh, this message translates to:
  /// **'模型来源'**
  String get modelSource;

  /// No description provided for @modelSourceValue.
  ///
  /// In zh, this message translates to:
  /// **'hf-mirror.com (HuggingFace 镜像)'**
  String get modelSourceValue;

  /// No description provided for @allInferenceOnDevice.
  ///
  /// In zh, this message translates to:
  /// **'Shiba · 所有推理均在设备上完成'**
  String get allInferenceOnDevice;

  /// No description provided for @copied.
  ///
  /// In zh, this message translates to:
  /// **'已复制: {text}'**
  String copied(String text);

  /// No description provided for @conversations.
  ///
  /// In zh, this message translates to:
  /// **'对话'**
  String get conversations;

  /// No description provided for @loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String loadFailed(String error);

  /// No description provided for @noConversations.
  ///
  /// In zh, this message translates to:
  /// **'还没有对话'**
  String get noConversations;

  /// No description provided for @tapToStartChat.
  ///
  /// In zh, this message translates to:
  /// **'点击右下角按钮开始新对话'**
  String get tapToStartChat;

  /// No description provided for @newChat.
  ///
  /// In zh, this message translates to:
  /// **'新对话'**
  String get newChat;

  /// No description provided for @pleaseDownloadModel.
  ///
  /// In zh, this message translates to:
  /// **'请先下载一个模型'**
  String get pleaseDownloadModel;

  /// No description provided for @selectModel.
  ///
  /// In zh, this message translates to:
  /// **'选择模型'**
  String get selectModel;

  /// No description provided for @deleteConversation.
  ///
  /// In zh, this message translates to:
  /// **'删除对话'**
  String get deleteConversation;

  /// No description provided for @deleteConversationConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这个对话吗？'**
  String get deleteConversationConfirm;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @renameConversation.
  ///
  /// In zh, this message translates to:
  /// **'重命名对话'**
  String get renameConversation;

  /// No description provided for @enterNewTitle.
  ///
  /// In zh, this message translates to:
  /// **'输入新标题'**
  String get enterNewTitle;

  /// No description provided for @modelDeleted.
  ///
  /// In zh, this message translates to:
  /// **'模型 {name} 已被删除，请重新下载'**
  String modelDeleted(String name);

  /// No description provided for @justNow.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}分钟前'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}小时前'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}天前'**
  String daysAgo(int count);

  /// No description provided for @noModelSelected.
  ///
  /// In zh, this message translates to:
  /// **'未选择模型'**
  String get noModelSelected;

  /// No description provided for @modelFileNotExist.
  ///
  /// In zh, this message translates to:
  /// **'模型文件不存在，请重新下载\n路径: {path}'**
  String modelFileNotExist(String path);

  /// No description provided for @visionProjectorFailed.
  ///
  /// In zh, this message translates to:
  /// **'视觉投影器加载失败，请检查 mmproj 是否与当前模型匹配'**
  String get visionProjectorFailed;

  /// No description provided for @visionProjectorMissing.
  ///
  /// In zh, this message translates to:
  /// **'该模型支持图片输入，但缺少视觉投影器(mmproj)文件，请在模型仓库中下载对应的 mmproj 文件'**
  String get visionProjectorMissing;

  /// No description provided for @selectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count} 条'**
  String selectedCount(int count);

  /// No description provided for @selectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get selectAll;

  /// No description provided for @deleteSelected.
  ///
  /// In zh, this message translates to:
  /// **'删除所选'**
  String get deleteSelected;

  /// No description provided for @conversationSettings.
  ///
  /// In zh, this message translates to:
  /// **'对话设置'**
  String get conversationSettings;

  /// No description provided for @inferenceError.
  ///
  /// In zh, this message translates to:
  /// **'推理错误'**
  String get inferenceError;

  /// No description provided for @details.
  ///
  /// In zh, this message translates to:
  /// **'详情'**
  String get details;

  /// No description provided for @errorCopied.
  ///
  /// In zh, this message translates to:
  /// **'错误信息已复制到剪贴板'**
  String get errorCopied;

  /// No description provided for @errorDetails.
  ///
  /// In zh, this message translates to:
  /// **'错误详情'**
  String get errorDetails;

  /// No description provided for @copy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copy;

  /// No description provided for @copiedToClipboard.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get copiedToClipboard;

  /// No description provided for @startConversation.
  ///
  /// In zh, this message translates to:
  /// **'开始对话'**
  String get startConversation;

  /// No description provided for @chatWithShiba.
  ///
  /// In zh, this message translates to:
  /// **'输入你的问题，与Shiba对话'**
  String get chatWithShiba;

  /// No description provided for @deleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'删除消息'**
  String get deleteMessage;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定删除这条消息？\n\n\"{content}\"'**
  String deleteMessageConfirm(String content);

  /// No description provided for @batchDelete.
  ///
  /// In zh, this message translates to:
  /// **'批量删除'**
  String get batchDelete;

  /// No description provided for @batchDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定删除选中的 {count} 条消息？此操作不可撤销。'**
  String batchDeleteConfirm(int count);

  /// No description provided for @modelLoadFailedUnknown.
  ///
  /// In zh, this message translates to:
  /// **'模型加载失败（未知错误）'**
  String get modelLoadFailedUnknown;

  /// No description provided for @modelLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'模型加载失败'**
  String get modelLoadFailed;

  /// No description provided for @conversationSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'对话设置'**
  String get conversationSettingsTitle;

  /// No description provided for @conversationTitle.
  ///
  /// In zh, this message translates to:
  /// **'对话标题'**
  String get conversationTitle;

  /// No description provided for @systemPrompt.
  ///
  /// In zh, this message translates to:
  /// **'系统提示词'**
  String get systemPrompt;

  /// No description provided for @systemPromptHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：你是一个专业的翻译助手'**
  String get systemPromptHint;

  /// No description provided for @historyRoundsDescription.
  ///
  /// In zh, this message translates to:
  /// **'用于拼接 history messages；0 表示使用全部历史'**
  String get historyRoundsDescription;

  /// No description provided for @copyAction.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copyAction;

  /// No description provided for @editAndResend.
  ///
  /// In zh, this message translates to:
  /// **'编辑并重发'**
  String get editAndResend;

  /// No description provided for @deleteAction.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get deleteAction;

  /// No description provided for @stopReading.
  ///
  /// In zh, this message translates to:
  /// **'停止朗读'**
  String get stopReading;

  /// No description provided for @readAloud.
  ///
  /// In zh, this message translates to:
  /// **'朗读'**
  String get readAloud;

  /// No description provided for @selectImage.
  ///
  /// In zh, this message translates to:
  /// **'选择图片'**
  String get selectImage;

  /// No description provided for @inputMessage.
  ///
  /// In zh, this message translates to:
  /// **'输入消息...'**
  String get inputMessage;

  /// No description provided for @modelLoading.
  ///
  /// In zh, this message translates to:
  /// **'模型加载中...'**
  String get modelLoading;

  /// No description provided for @saveImageCopy.
  ///
  /// In zh, this message translates to:
  /// **'保存副本'**
  String get saveImageCopy;

  /// No description provided for @imageNotExist.
  ///
  /// In zh, this message translates to:
  /// **'图片文件不存在'**
  String get imageNotExist;

  /// No description provided for @imageSavedAndroid.
  ///
  /// In zh, this message translates to:
  /// **'图片已保存到 Pictures/Shiba'**
  String get imageSavedAndroid;

  /// No description provided for @imageSavedIos.
  ///
  /// In zh, this message translates to:
  /// **'图片已保存到 {name}'**
  String imageSavedIos(String name);

  /// No description provided for @saveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败: {error}'**
  String saveFailed(String error);

  /// No description provided for @models.
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get models;

  /// No description provided for @searchModels.
  ///
  /// In zh, this message translates to:
  /// **'搜索模型'**
  String get searchModels;

  /// No description provided for @noModels.
  ///
  /// In zh, this message translates to:
  /// **'还没有模型'**
  String get noModels;

  /// No description provided for @tapSearchToDownload.
  ///
  /// In zh, this message translates to:
  /// **'点击右上角搜索按钮从 HuggingFace 下载模型'**
  String get tapSearchToDownload;

  /// No description provided for @downloading.
  ///
  /// In zh, this message translates to:
  /// **'下载中'**
  String get downloading;

  /// No description provided for @completed.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get completed;

  /// No description provided for @failed.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get failed;

  /// No description provided for @searchGgufModels.
  ///
  /// In zh, this message translates to:
  /// **'搜索 GGUF 模型 (如: llama, qwen, phi)'**
  String get searchGgufModels;

  /// No description provided for @search.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// No description provided for @searchFromHf.
  ///
  /// In zh, this message translates to:
  /// **'从 HuggingFace 镜像搜索 GGUF 模型'**
  String get searchFromHf;

  /// No description provided for @searchFailed.
  ///
  /// In zh, this message translates to:
  /// **'搜索失败: {error}'**
  String searchFailed(String error);

  /// No description provided for @noModelsFound.
  ///
  /// In zh, this message translates to:
  /// **'没有找到相关模型'**
  String get noModelsFound;

  /// No description provided for @downloadsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 下载'**
  String downloadsCount(String count);

  /// No description provided for @ggufFiles.
  ///
  /// In zh, this message translates to:
  /// **'GGUF 文件'**
  String get ggufFiles;

  /// No description provided for @noGgufFiles.
  ///
  /// In zh, this message translates to:
  /// **'该仓库没有 GGUF 文件'**
  String get noGgufFiles;

  /// No description provided for @availableMemory.
  ///
  /// In zh, this message translates to:
  /// **'可用内存: ~{size}'**
  String availableMemory(String size);

  /// No description provided for @likesCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 喜欢'**
  String likesCount(String count);

  /// No description provided for @suitabilityRecommended.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get suitabilityRecommended;

  /// No description provided for @suitabilityOk.
  ///
  /// In zh, this message translates to:
  /// **'可用'**
  String get suitabilityOk;

  /// No description provided for @suitabilityRisky.
  ///
  /// In zh, this message translates to:
  /// **'勉强'**
  String get suitabilityRisky;

  /// No description provided for @suitabilityTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'超出内存'**
  String get suitabilityTooLarge;

  /// No description provided for @alreadyInList.
  ///
  /// In zh, this message translates to:
  /// **'{name} 已在下载列表中'**
  String alreadyInList(String name);

  /// No description provided for @startDownloadWithVision.
  ///
  /// In zh, this message translates to:
  /// **'开始下载 {name}（已自动附带视觉投影器）'**
  String startDownloadWithVision(String name);

  /// No description provided for @startDownload.
  ///
  /// In zh, this message translates to:
  /// **'开始下载 {name}'**
  String startDownload(String name);

  /// No description provided for @statusCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get statusCompleted;

  /// No description provided for @statusDownloading.
  ///
  /// In zh, this message translates to:
  /// **'下载中'**
  String get statusDownloading;

  /// No description provided for @statusPending.
  ///
  /// In zh, this message translates to:
  /// **'等待中'**
  String get statusPending;

  /// No description provided for @statusPaused.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get statusPaused;

  /// No description provided for @statusFailed.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get statusFailed;

  /// No description provided for @remaining.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {time}'**
  String remaining(String time);

  /// No description provided for @paused.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get paused;

  /// No description provided for @pauseAction.
  ///
  /// In zh, this message translates to:
  /// **'暂停'**
  String get pauseAction;

  /// No description provided for @cancelDownload.
  ///
  /// In zh, this message translates to:
  /// **'取消下载'**
  String get cancelDownload;

  /// No description provided for @resumeDownload.
  ///
  /// In zh, this message translates to:
  /// **'继续下载'**
  String get resumeDownload;

  /// No description provided for @cancelDownloadTitle.
  ///
  /// In zh, this message translates to:
  /// **'取消下载'**
  String get cancelDownloadTitle;

  /// No description provided for @cancelDownloadContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要取消下载 {name} 吗？\n已下载的文件将被删除。'**
  String cancelDownloadContent(String name);

  /// No description provided for @continueDownload.
  ///
  /// In zh, this message translates to:
  /// **'继续下载'**
  String get continueDownload;

  /// No description provided for @deleteModel.
  ///
  /// In zh, this message translates to:
  /// **'删除模型'**
  String get deleteModel;

  /// No description provided for @deleteModelContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除 {name} 吗？\n这将释放 {size} 的存储空间。'**
  String deleteModelContent(String name, String size);

  /// No description provided for @detailRepo.
  ///
  /// In zh, this message translates to:
  /// **'仓库'**
  String get detailRepo;

  /// No description provided for @detailFilename.
  ///
  /// In zh, this message translates to:
  /// **'文件名'**
  String get detailFilename;

  /// No description provided for @detailPath.
  ///
  /// In zh, this message translates to:
  /// **'路径'**
  String get detailPath;

  /// No description provided for @detailFileSize.
  ///
  /// In zh, this message translates to:
  /// **'文件大小'**
  String get detailFileSize;

  /// No description provided for @detailQuantType.
  ///
  /// In zh, this message translates to:
  /// **'量化类型'**
  String get detailQuantType;

  /// No description provided for @detailDownloadTime.
  ///
  /// In zh, this message translates to:
  /// **'下载时间'**
  String get detailDownloadTime;

  /// No description provided for @networkUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'网络不可用，请检查网络连接'**
  String get networkUnavailable;

  /// No description provided for @downloadFailedGeneric.
  ///
  /// In zh, this message translates to:
  /// **'下载失败'**
  String get downloadFailedGeneric;

  /// No description provided for @downloadCancelled.
  ///
  /// In zh, this message translates to:
  /// **'下载已取消'**
  String get downloadCancelled;

  /// No description provided for @insufficientMemory.
  ///
  /// In zh, this message translates to:
  /// **'内存不足，无法加载该模型'**
  String get insufficientMemory;

  /// No description provided for @modelNotFound.
  ///
  /// In zh, this message translates to:
  /// **'模型文件未找到'**
  String get modelNotFound;

  /// No description provided for @inferenceErrorGeneric.
  ///
  /// In zh, this message translates to:
  /// **'推理过程发生错误'**
  String get inferenceErrorGeneric;

  /// No description provided for @databaseError.
  ///
  /// In zh, this message translates to:
  /// **'数据库操作失败'**
  String get databaseError;

  /// No description provided for @sttListening.
  ///
  /// In zh, this message translates to:
  /// **'正在聆听...'**
  String get sttListening;

  /// No description provided for @sttNotAvailable.
  ///
  /// In zh, this message translates to:
  /// **'语音识别不可用'**
  String get sttNotAvailable;

  /// No description provided for @sttMicPermissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'麦克风权限被拒绝'**
  String get sttMicPermissionDenied;

  /// No description provided for @sttTooltip.
  ///
  /// In zh, this message translates to:
  /// **'语音输入'**
  String get sttTooltip;

  /// No description provided for @sttDownloadTitle.
  ///
  /// In zh, this message translates to:
  /// **'下载语音识别模型'**
  String get sttDownloadTitle;

  /// No description provided for @sttDownloadPrompt.
  ///
  /// In zh, this message translates to:
  /// **'语音识别模型尚未下载（约230MB）。\n是否现在下载？'**
  String get sttDownloadPrompt;

  /// No description provided for @sttDownloadModel.
  ///
  /// In zh, this message translates to:
  /// **'下载语音识别模型'**
  String get sttDownloadModel;

  /// No description provided for @sttDownloadComplete.
  ///
  /// In zh, this message translates to:
  /// **'语音识别模型下载完成'**
  String get sttDownloadComplete;

  /// No description provided for @sttDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'下载失败，请检查网络后重试'**
  String get sttDownloadFailed;

  /// No description provided for @sttRecognizing.
  ///
  /// In zh, this message translates to:
  /// **'识别中...'**
  String get sttRecognizing;

  /// No description provided for @sttRecognizeFailed.
  ///
  /// In zh, this message translates to:
  /// **'语音识别失败，请重试'**
  String get sttRecognizeFailed;

  /// No description provided for @sttModelTitle.
  ///
  /// In zh, this message translates to:
  /// **'SenseVoice 语音识别模型'**
  String get sttModelTitle;

  /// No description provided for @sttNotDownloaded.
  ///
  /// In zh, this message translates to:
  /// **'未下载 · 约230MB'**
  String get sttNotDownloaded;

  /// No description provided for @sttDownloaded.
  ///
  /// In zh, this message translates to:
  /// **'已下载 · {size}'**
  String sttDownloaded(String size);

  /// No description provided for @sttDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除语音识别模型'**
  String get sttDeleteTitle;

  /// No description provided for @sttDeleteContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除已下载的语音识别模型吗？\n删除后语音输入功能将不可用，需要重新下载。'**
  String get sttDeleteContent;

  /// No description provided for @sttSection.
  ///
  /// In zh, this message translates to:
  /// **'语音识别 (STT)'**
  String get sttSection;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return SZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return SDe();
    case 'en':
      return SEn();
    case 'fr':
      return SFr();
    case 'zh':
      return SZh();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
