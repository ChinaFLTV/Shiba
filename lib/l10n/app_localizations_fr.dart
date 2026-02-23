// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Shiba';

  @override
  String get preparingEnvironment =>
      'Préparation de l\'environnement d\'inférence locale…';

  @override
  String get bootFailed => 'Échec du démarrage';

  @override
  String get tabChat => 'Discussion';

  @override
  String get tabModels => 'Modèles';

  @override
  String get tabSettings => 'Paramètres';

  @override
  String get settings => 'Paramètres';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeMode => 'Mode de thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get language => 'Langue';

  @override
  String get languageSetting => 'Langue d\'affichage';

  @override
  String get ttsSection => 'Synthèse vocale (TTS)';

  @override
  String get ttsModelTitle => 'Modèle vocal MeloTTS chinois-anglais';

  @override
  String get ttsChecking => 'Vérification...';

  @override
  String ttsDownloaded(String size) {
    return 'Téléchargé · $size';
  }

  @override
  String get ttsNotDownloaded => 'Non téléchargé · ~182 Mo';

  @override
  String get ttsDeleteTitle => 'Supprimer le modèle vocal';

  @override
  String get ttsDeleteContent =>
      'Voulez-vous vraiment supprimer le modèle vocal TTS ?\nLa lecture à voix haute sera indisponible jusqu\'au re-téléchargement.';

  @override
  String get ttsDownloadTitle => 'Télécharger le modèle vocal';

  @override
  String get ttsDownloadPrompt =>
      'Le modèle vocal TTS n\'est pas encore téléchargé (~182 Mo).\nTélécharger maintenant ?';

  @override
  String get ttsDownloadComplete => 'Téléchargement du modèle vocal terminé';

  @override
  String get ttsDownloadFailed =>
      'Échec du téléchargement, vérifiez votre réseau et réessayez';

  @override
  String get ttsAutoSwitch => 'Changement automatique de source si trop lent';

  @override
  String get ttsSpeakFailed => 'Échec de la lecture, veuillez réessayer';

  @override
  String get ttsSpeed => 'Vitesse';

  @override
  String get download => 'Télécharger';

  @override
  String get downloadComplete => 'Téléchargement terminé';

  @override
  String get downloadModel => 'Télécharger le modèle vocal';

  @override
  String get imageSection => 'Traitement d\'images';

  @override
  String get compressImage => 'Compresser les images';

  @override
  String get maxResolution => 'Résolution max';

  @override
  String get imageQuality => 'Qualité d\'image';

  @override
  String get chatDefaultsSection => 'Paramètres par défaut';

  @override
  String get defaultSystemPrompt => 'Prompt système par défaut';

  @override
  String get defaultSystemPromptHint =>
      'Utilisé pour les nouvelles discussions ; modifiable par conversation';

  @override
  String get maxGenerationLength => 'Longueur max de génération';

  @override
  String get historyRounds => 'Tours d\'historique';

  @override
  String get historyRoundsAll => 'Tout';

  @override
  String get historyRoundsHint =>
      'Tours d\'historique par défaut pour les nouvelles discussions ; 0 = tout l\'historique';

  @override
  String get restoreDefaults => 'Restaurer les valeurs par défaut';

  @override
  String get save => 'Enregistrer';

  @override
  String get defaultsSaved => 'Paramètres par défaut enregistrés';

  @override
  String get aboutSection => 'À propos';

  @override
  String version(String v) {
    return 'Version $v';
  }

  @override
  String get inferenceEngine => 'Moteur d\'inférence';

  @override
  String get modelSource => 'Source des modèles';

  @override
  String get modelSourceValue => 'hf-mirror.com (Miroir HuggingFace)';

  @override
  String get allInferenceOnDevice =>
      'Shiba · Toute l\'inférence s\'exécute sur l\'appareil';

  @override
  String copied(String text) {
    return 'Copié : $text';
  }

  @override
  String get conversations => 'Discussions';

  @override
  String loadFailed(String error) {
    return 'Échec du chargement : $error';
  }

  @override
  String get noConversations => 'Aucune discussion';

  @override
  String get tapToStartChat =>
      'Appuyez sur le bouton ci-dessous pour démarrer une discussion';

  @override
  String get newChat => 'Nouvelle discussion';

  @override
  String get pleaseDownloadModel => 'Veuillez d\'abord télécharger un modèle';

  @override
  String get selectModel => 'Sélectionner un modèle';

  @override
  String get deleteConversation => 'Supprimer la discussion';

  @override
  String get deleteConversationConfirm =>
      'Voulez-vous vraiment supprimer cette discussion ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'OK';

  @override
  String get close => 'Fermer';

  @override
  String get retry => 'Réessayer';

  @override
  String get renameConversation => 'Renommer la discussion';

  @override
  String get enterNewTitle => 'Entrez un nouveau titre';

  @override
  String modelDeleted(String name) {
    return 'Le modèle $name a été supprimé, veuillez le re-télécharger';
  }

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(int count) {
    return 'Il y a $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'Il y a $count h';
  }

  @override
  String daysAgo(int count) {
    return 'Il y a $count j';
  }

  @override
  String get noModelSelected => 'Aucun modèle sélectionné';

  @override
  String modelFileNotExist(String path) {
    return 'Le fichier modèle n\'existe pas, veuillez le re-télécharger\nChemin : $path';
  }

  @override
  String get visionProjectorFailed =>
      'Échec du chargement du projecteur de vision, vérifiez la compatibilité mmproj';

  @override
  String get visionProjectorMissing =>
      'Ce modèle prend en charge les images mais le fichier mmproj est manquant. Téléchargez-le depuis le dépôt du modèle';

  @override
  String selectedCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get deleteSelected => 'Supprimer la sélection';

  @override
  String get conversationSettings => 'Paramètres de discussion';

  @override
  String get inferenceError => 'Erreur d\'inférence';

  @override
  String get details => 'Détails';

  @override
  String get errorCopied => 'Erreur copiée dans le presse-papiers';

  @override
  String get errorDetails => 'Détails de l\'erreur';

  @override
  String get copy => 'Copier';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get startConversation => 'Démarrer une discussion';

  @override
  String get chatWithShiba => 'Posez votre question pour discuter avec Shiba';

  @override
  String get deleteMessage => 'Supprimer le message';

  @override
  String deleteMessageConfirm(String content) {
    return 'Supprimer ce message ?\n\n\"$content\"';
  }

  @override
  String get batchDelete => 'Suppression groupée';

  @override
  String batchDeleteConfirm(int count) {
    return 'Supprimer les $count messages sélectionnés ? Cette action est irréversible.';
  }

  @override
  String get modelLoadFailedUnknown =>
      'Échec du chargement du modèle (erreur inconnue)';

  @override
  String get modelLoadFailed => 'Échec du chargement du modèle';

  @override
  String get conversationSettingsTitle => 'Paramètres de discussion';

  @override
  String get conversationTitle => 'Titre de la discussion';

  @override
  String get systemPrompt => 'Prompt système';

  @override
  String get systemPromptHint => 'Ex : Vous êtes un traducteur professionnel';

  @override
  String get historyRoundsDescription =>
      'Pour assembler les messages d\'historique ; 0 = tout l\'historique';

  @override
  String get copyAction => 'Copier';

  @override
  String get editAndResend => 'Modifier et renvoyer';

  @override
  String get deleteAction => 'Supprimer';

  @override
  String get stopReading => 'Arrêter la lecture';

  @override
  String get readAloud => 'Lire à voix haute';

  @override
  String get selectImage => 'Sélectionner une image';

  @override
  String get inputMessage => 'Saisissez un message...';

  @override
  String get modelLoading => 'Chargement du modèle...';

  @override
  String get saveImageCopy => 'Enregistrer une copie';

  @override
  String get imageNotExist => 'Le fichier image n\'existe pas';

  @override
  String get imageSavedAndroid => 'Image enregistrée dans Pictures/Shiba';

  @override
  String imageSavedIos(String name) {
    return 'Image enregistrée sous $name';
  }

  @override
  String saveFailed(String error) {
    return 'Échec de l\'enregistrement : $error';
  }

  @override
  String get models => 'Modèles';

  @override
  String get searchModels => 'Rechercher des modèles';

  @override
  String get noModels => 'Aucun modèle';

  @override
  String get tapSearchToDownload =>
      'Appuyez sur le bouton de recherche pour télécharger des modèles depuis HuggingFace';

  @override
  String get downloading => 'Téléchargement';

  @override
  String get completed => 'Terminé';

  @override
  String get failed => 'Échoué';

  @override
  String get searchGgufModels =>
      'Rechercher des modèles GGUF (ex : llama, qwen, phi)';

  @override
  String get search => 'Rechercher';

  @override
  String get searchFromHf =>
      'Rechercher des modèles GGUF depuis le miroir HuggingFace';

  @override
  String searchFailed(String error) {
    return 'Échec de la recherche : $error';
  }

  @override
  String get noModelsFound => 'Aucun modèle correspondant trouvé';

  @override
  String downloadsCount(String count) {
    return '$count téléchargements';
  }

  @override
  String get ggufFiles => 'Fichiers GGUF';

  @override
  String get noGgufFiles => 'Aucun fichier GGUF dans ce dépôt';

  @override
  String availableMemory(String size) {
    return 'Mémoire disponible : ~$size';
  }

  @override
  String likesCount(String count) {
    return '$count j\'aime';
  }

  @override
  String get suitabilityRecommended => 'Recommandé';

  @override
  String get suitabilityOk => 'OK';

  @override
  String get suitabilityRisky => 'Risqué';

  @override
  String get suitabilityTooLarge => 'Trop volumineux';

  @override
  String alreadyInList(String name) {
    return '$name est déjà dans la liste de téléchargement';
  }

  @override
  String startDownloadWithVision(String name) {
    return 'Téléchargement de $name (avec projecteur de vision)';
  }

  @override
  String startDownload(String name) {
    return 'Téléchargement de $name';
  }

  @override
  String get statusCompleted => 'Terminé';

  @override
  String get statusDownloading => 'Téléchargement';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusPaused => 'En pause';

  @override
  String get statusFailed => 'Échoué';

  @override
  String remaining(String time) {
    return '$time restant';
  }

  @override
  String get paused => 'En pause';

  @override
  String get pauseAction => 'Pause';

  @override
  String get cancelDownload => 'Annuler le téléchargement';

  @override
  String get resumeDownload => 'Reprendre';

  @override
  String get cancelDownloadTitle => 'Annuler le téléchargement';

  @override
  String cancelDownloadContent(String name) {
    return 'Annuler le téléchargement de $name ?\nLes fichiers téléchargés seront supprimés.';
  }

  @override
  String get continueDownload => 'Continuer';

  @override
  String get deleteModel => 'Supprimer le modèle';

  @override
  String deleteModelContent(String name, String size) {
    return 'Supprimer $name ?\nCela libérera $size d\'espace de stockage.';
  }

  @override
  String get detailRepo => 'Dépôt';

  @override
  String get detailFilename => 'Nom de fichier';

  @override
  String get detailPath => 'Chemin';

  @override
  String get detailFileSize => 'Taille du fichier';

  @override
  String get detailQuantType => 'Quantification';

  @override
  String get detailDownloadTime => 'Téléchargé le';

  @override
  String get networkUnavailable =>
      'Réseau indisponible, vérifiez votre connexion';

  @override
  String get downloadFailedGeneric => 'Échec du téléchargement';

  @override
  String get downloadCancelled => 'Téléchargement annulé';

  @override
  String get insufficientMemory =>
      'Mémoire insuffisante pour charger ce modèle';

  @override
  String get modelNotFound => 'Fichier modèle introuvable';

  @override
  String get inferenceErrorGeneric =>
      'Une erreur s\'est produite lors de l\'inférence';

  @override
  String get databaseError => 'Échec de l\'opération de base de données';
}
