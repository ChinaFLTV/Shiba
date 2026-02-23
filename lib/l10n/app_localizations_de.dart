// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SDe extends S {
  SDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Shiba';

  @override
  String get preparingEnvironment =>
      'Lokale Inferenzumgebung wird vorbereitet…';

  @override
  String get bootFailed => 'Start fehlgeschlagen';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabModels => 'Modelle';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get appearance => 'Darstellung';

  @override
  String get themeMode => 'Designmodus';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get language => 'Sprache';

  @override
  String get languageSetting => 'Anzeigesprache';

  @override
  String get ttsSection => 'Sprachsynthese (TTS)';

  @override
  String get ttsModelTitle => 'MeloTTS Chinesisch-Englisch Sprachmodell';

  @override
  String get ttsChecking => 'Wird überprüft...';

  @override
  String ttsDownloaded(String size) {
    return 'Heruntergeladen · $size';
  }

  @override
  String get ttsNotDownloaded => 'Nicht heruntergeladen · ~182 MB';

  @override
  String get ttsDeleteTitle => 'Sprachmodell löschen';

  @override
  String get ttsDeleteContent =>
      'Möchten Sie das TTS-Sprachmodell wirklich löschen?\nVorlesen ist bis zum erneuten Download nicht verfügbar.';

  @override
  String get ttsDownloadTitle => 'Sprachmodell herunterladen';

  @override
  String get ttsDownloadPrompt =>
      'TTS-Sprachmodell noch nicht heruntergeladen (~182 MB).\nJetzt herunterladen?';

  @override
  String get ttsDownloadComplete => 'Sprachmodell-Download abgeschlossen';

  @override
  String get ttsDownloadFailed =>
      'Download fehlgeschlagen, bitte Netzwerk prüfen und erneut versuchen';

  @override
  String get ttsAutoSwitch =>
      'Automatischer Quellenwechsel bei zu langsamer Geschwindigkeit';

  @override
  String get ttsSpeakFailed =>
      'Vorlesen fehlgeschlagen, bitte erneut versuchen';

  @override
  String get ttsSpeed => 'Geschwindigkeit';

  @override
  String get download => 'Herunterladen';

  @override
  String get downloadComplete => 'Download abgeschlossen';

  @override
  String get downloadModel => 'Sprachmodell herunterladen';

  @override
  String get imageSection => 'Bildverarbeitung';

  @override
  String get compressImage => 'Bilder komprimieren';

  @override
  String get maxResolution => 'Max. Auflösung';

  @override
  String get imageQuality => 'Bildqualität';

  @override
  String get chatDefaultsSection => 'Standard-Chat-Parameter';

  @override
  String get defaultSystemPrompt => 'Standard-Systemprompt';

  @override
  String get defaultSystemPromptHint =>
      'Wird für neue Chats verwendet; kann pro Gespräch überschrieben werden';

  @override
  String get maxGenerationLength => 'Max. Generierungslänge';

  @override
  String get historyRounds => 'Verlaufsrunden';

  @override
  String get historyRoundsAll => 'Alle';

  @override
  String get historyRoundsHint =>
      'Standard-Verlaufsrunden für neue Chats; 0 = gesamter Verlauf';

  @override
  String get restoreDefaults => 'Standardwerte wiederherstellen';

  @override
  String get save => 'Speichern';

  @override
  String get defaultsSaved => 'Globale Standard-Chat-Parameter gespeichert';

  @override
  String get aboutSection => 'Über';

  @override
  String version(String v) {
    return 'Version $v';
  }

  @override
  String get inferenceEngine => 'Inferenz-Engine';

  @override
  String get modelSource => 'Modellquelle';

  @override
  String get modelSourceValue => 'hf-mirror.com (HuggingFace-Spiegel)';

  @override
  String get allInferenceOnDevice =>
      'Shiba · Alle Inferenz läuft auf dem Gerät';

  @override
  String copied(String text) {
    return 'Kopiert: $text';
  }

  @override
  String get conversations => 'Gespräche';

  @override
  String loadFailed(String error) {
    return 'Laden fehlgeschlagen: $error';
  }

  @override
  String get noConversations => 'Noch keine Gespräche';

  @override
  String get tapToStartChat =>
      'Tippen Sie auf die Schaltfläche unten, um einen neuen Chat zu starten';

  @override
  String get newChat => 'Neuer Chat';

  @override
  String get pleaseDownloadModel =>
      'Bitte laden Sie zuerst ein Modell herunter';

  @override
  String get selectModel => 'Modell auswählen';

  @override
  String get deleteConversation => 'Gespräch löschen';

  @override
  String get deleteConversationConfirm =>
      'Möchten Sie dieses Gespräch wirklich löschen?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get confirm => 'OK';

  @override
  String get close => 'Schließen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get renameConversation => 'Gespräch umbenennen';

  @override
  String get enterNewTitle => 'Neuen Titel eingeben';

  @override
  String modelDeleted(String name) {
    return 'Modell $name wurde gelöscht, bitte erneut herunterladen';
  }

  @override
  String get justNow => 'Gerade eben';

  @override
  String minutesAgo(int count) {
    return 'Vor $count Min.';
  }

  @override
  String hoursAgo(int count) {
    return 'Vor $count Std.';
  }

  @override
  String daysAgo(int count) {
    return 'Vor $count Tagen';
  }

  @override
  String get noModelSelected => 'Kein Modell ausgewählt';

  @override
  String modelFileNotExist(String path) {
    return 'Modelldatei existiert nicht, bitte erneut herunterladen\nPfad: $path';
  }

  @override
  String get visionProjectorFailed =>
      'Vision-Projektor konnte nicht geladen werden, prüfen Sie die mmproj-Kompatibilität';

  @override
  String get visionProjectorMissing =>
      'Dieses Modell unterstützt Bildeingabe, aber die mmproj-Datei fehlt. Bitte laden Sie die entsprechende mmproj-Datei aus dem Modell-Repository herunter';

  @override
  String selectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get deleteSelected => 'Auswahl löschen';

  @override
  String get conversationSettings => 'Chat-Einstellungen';

  @override
  String get inferenceError => 'Inferenzfehler';

  @override
  String get details => 'Details';

  @override
  String get errorCopied => 'Fehler in die Zwischenablage kopiert';

  @override
  String get errorDetails => 'Fehlerdetails';

  @override
  String get copy => 'Kopieren';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String get startConversation => 'Gespräch starten';

  @override
  String get chatWithShiba => 'Stellen Sie Ihre Frage, um mit Shiba zu chatten';

  @override
  String get deleteMessage => 'Nachricht löschen';

  @override
  String deleteMessageConfirm(String content) {
    return 'Diese Nachricht löschen?\n\n\"$content\"';
  }

  @override
  String get batchDelete => 'Stapellöschung';

  @override
  String batchDeleteConfirm(int count) {
    return '$count ausgewählte Nachrichten löschen? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get modelLoadFailedUnknown =>
      'Modell konnte nicht geladen werden (unbekannter Fehler)';

  @override
  String get modelLoadFailed => 'Modell konnte nicht geladen werden';

  @override
  String get conversationSettingsTitle => 'Chat-Einstellungen';

  @override
  String get conversationTitle => 'Chat-Titel';

  @override
  String get systemPrompt => 'Systemprompt';

  @override
  String get systemPromptHint => 'z.B. Sie sind ein professioneller Übersetzer';

  @override
  String get historyRoundsDescription =>
      'Für die Zusammenstellung der Verlaufsnachrichten; 0 = gesamter Verlauf';

  @override
  String get copyAction => 'Kopieren';

  @override
  String get editAndResend => 'Bearbeiten & erneut senden';

  @override
  String get deleteAction => 'Löschen';

  @override
  String get stopReading => 'Vorlesen stoppen';

  @override
  String get readAloud => 'Vorlesen';

  @override
  String get selectImage => 'Bild auswählen';

  @override
  String get inputMessage => 'Nachricht eingeben...';

  @override
  String get modelLoading => 'Modell wird geladen...';

  @override
  String get saveImageCopy => 'Kopie speichern';

  @override
  String get imageNotExist => 'Bilddatei existiert nicht';

  @override
  String get imageSavedAndroid => 'Bild in Pictures/Shiba gespeichert';

  @override
  String imageSavedIos(String name) {
    return 'Bild als $name gespeichert';
  }

  @override
  String saveFailed(String error) {
    return 'Speichern fehlgeschlagen: $error';
  }

  @override
  String get models => 'Modelle';

  @override
  String get searchModels => 'Modelle suchen';

  @override
  String get noModels => 'Noch keine Modelle';

  @override
  String get tapSearchToDownload =>
      'Tippen Sie auf die Suchschaltfläche, um Modelle von HuggingFace herunterzuladen';

  @override
  String get downloading => 'Wird heruntergeladen';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get failed => 'Fehlgeschlagen';

  @override
  String get searchGgufModels => 'GGUF-Modelle suchen (z.B. llama, qwen, phi)';

  @override
  String get search => 'Suchen';

  @override
  String get searchFromHf => 'GGUF-Modelle vom HuggingFace-Spiegel suchen';

  @override
  String searchFailed(String error) {
    return 'Suche fehlgeschlagen: $error';
  }

  @override
  String get noModelsFound => 'Keine passenden Modelle gefunden';

  @override
  String downloadsCount(String count) {
    return '$count Downloads';
  }

  @override
  String get ggufFiles => 'GGUF-Dateien';

  @override
  String get noGgufFiles => 'Keine GGUF-Dateien in diesem Repository';

  @override
  String availableMemory(String size) {
    return 'Verfügbarer Speicher: ~$size';
  }

  @override
  String likesCount(String count) {
    return '$count Likes';
  }

  @override
  String get suitabilityRecommended => 'Empfohlen';

  @override
  String get suitabilityOk => 'OK';

  @override
  String get suitabilityRisky => 'Riskant';

  @override
  String get suitabilityTooLarge => 'Zu groß';

  @override
  String alreadyInList(String name) {
    return '$name ist bereits in der Download-Liste';
  }

  @override
  String startDownloadWithVision(String name) {
    return 'Download von $name (mit Vision-Projektor)';
  }

  @override
  String startDownload(String name) {
    return 'Download von $name';
  }

  @override
  String get statusCompleted => 'Abgeschlossen';

  @override
  String get statusDownloading => 'Wird heruntergeladen';

  @override
  String get statusPending => 'Wartend';

  @override
  String get statusPaused => 'Pausiert';

  @override
  String get statusFailed => 'Fehlgeschlagen';

  @override
  String remaining(String time) {
    return '$time verbleibend';
  }

  @override
  String get paused => 'Pausiert';

  @override
  String get pauseAction => 'Pause';

  @override
  String get cancelDownload => 'Download abbrechen';

  @override
  String get resumeDownload => 'Fortsetzen';

  @override
  String get cancelDownloadTitle => 'Download abbrechen';

  @override
  String cancelDownloadContent(String name) {
    return 'Download von $name abbrechen?\nHeruntergeladene Dateien werden gelöscht.';
  }

  @override
  String get continueDownload => 'Fortsetzen';

  @override
  String get deleteModel => 'Modell löschen';

  @override
  String deleteModelContent(String name, String size) {
    return '$name löschen?\nDies gibt $size Speicherplatz frei.';
  }

  @override
  String get detailRepo => 'Repository';

  @override
  String get detailFilename => 'Dateiname';

  @override
  String get detailPath => 'Pfad';

  @override
  String get detailFileSize => 'Dateigröße';

  @override
  String get detailQuantType => 'Quantisierung';

  @override
  String get detailDownloadTime => 'Heruntergeladen am';

  @override
  String get networkUnavailable =>
      'Netzwerk nicht verfügbar, bitte Verbindung prüfen';

  @override
  String get downloadFailedGeneric => 'Download fehlgeschlagen';

  @override
  String get downloadCancelled => 'Download abgebrochen';

  @override
  String get insufficientMemory =>
      'Nicht genügend Speicher, um dieses Modell zu laden';

  @override
  String get modelNotFound => 'Modelldatei nicht gefunden';

  @override
  String get inferenceErrorGeneric =>
      'Während der Inferenz ist ein Fehler aufgetreten';

  @override
  String get databaseError => 'Datenbankoperation fehlgeschlagen';
}
