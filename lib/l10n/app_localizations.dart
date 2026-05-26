import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Dual N-Back'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Working memory trainer'**
  String get appTagline;

  /// No description provided for @homeStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get homeStartButton;

  /// No description provided for @homeInfoButton.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get homeInfoButton;

  /// No description provided for @homeStatisticsButton.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get homeStatisticsButton;

  /// No description provided for @homeSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsButton;

  /// No description provided for @infoTitle.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get infoTitle;

  /// No description provided for @infoSectionWhatIs.
  ///
  /// In en, this message translates to:
  /// **'What is N-back?'**
  String get infoSectionWhatIs;

  /// No description provided for @infoSectionWhatIsBody.
  ///
  /// In en, this message translates to:
  /// **'N-back is an exercise for your working memory. Cues appear one at a time on the screen (a letter, a colour, a position in a grid, and so on), and your job is to notice whether the current cue matches the one shown N steps back. The bigger N is, the harder it is to keep the sequence in mind.\n\nYou can train one channel at a time (Single — e.g. position only), two together (Dual — the classic version, usually position + sound), or all four (Quad). Each channel is judged on its own: a match in position doesn\'t mean a match in sound.'**
  String get infoSectionWhatIsBody;

  /// No description provided for @infoSectionJaeggi.
  ///
  /// In en, this message translates to:
  /// **'The Jaeggi study'**
  String get infoSectionJaeggi;

  /// No description provided for @infoSectionJaeggiBody.
  ///
  /// In en, this message translates to:
  /// **'In 2008, researchers led by Jaeggi published a study showing that about 19 days of daily Dual N-back training improved fluid intelligence (Gf) — the ability to solve new, unfamiliar problems. N-back has been a popular \'brain trainer\' ever since.\n\nThe app\'s default settings come from that same study: 20 trials per session, each cue shown for 500 ms, 2500 ms pause between cues, matches appear about 30% of the time. If adaptive mode is on, the N level goes up when per-channel accuracy is ≥90% and down when it\'s ≤70%.'**
  String get infoSectionJaeggiBody;

  /// No description provided for @infoSectionMetrics.
  ///
  /// In en, this message translates to:
  /// **'Score metrics'**
  String get infoSectionMetrics;

  /// No description provided for @infoMetricHits.
  ///
  /// In en, this message translates to:
  /// **'Hits — you pressed Match where there really was a match.'**
  String get infoMetricHits;

  /// No description provided for @infoMetricMisses.
  ///
  /// In en, this message translates to:
  /// **'Misses — there was a match, but you didn\'t catch it.'**
  String get infoMetricMisses;

  /// No description provided for @infoMetricFalseAlarms.
  ///
  /// In en, this message translates to:
  /// **'False + (false alarm) — you pressed Match, but there wasn\'t actually one.'**
  String get infoMetricFalseAlarms;

  /// No description provided for @infoMetricCorrectRejections.
  ///
  /// In en, this message translates to:
  /// **'Correct − (correct rejection) — there was no match, and you correctly didn\'t press.'**
  String get infoMetricCorrectRejections;

  /// No description provided for @infoMetricAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy — the share of your decisions that were right. Computed as hits ÷ (hits + misses + false alarms). It drops both from missed matches and from wrong presses.'**
  String get infoMetricAccuracy;

  /// No description provided for @infoMetricDPrime.
  ///
  /// In en, this message translates to:
  /// **'d′ (d-prime) — shows how well you tell real matches apart from non-matches. The higher it is, the more clearly you \'see\' the matches. It\'s a more honest measure than accuracy: you can\'t fool it by just pressing more or less often.'**
  String get infoMetricDPrime;

  /// No description provided for @infoSectionTips.
  ///
  /// In en, this message translates to:
  /// **'Practice tips'**
  String get infoSectionTips;

  /// No description provided for @infoSectionTipsBody.
  ///
  /// In en, this message translates to:
  /// **'• Train every day — a short daily session beats rare long ones.\n• Don\'t try to say the letters or positions out loud — let your memory do the work.\n• If your score stays flat for a few days, that\'s normal — the brain doesn\'t learn in a straight line. Just keep going.\n• Want N to adjust to your progress automatically? Turn on the Jaeggi adaptive mode in settings.'**
  String get infoSectionTipsBody;

  /// No description provided for @channelPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get channelPosition;

  /// No description provided for @channelAudio.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get channelAudio;

  /// No description provided for @channelColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get channelColor;

  /// No description provided for @channelShape.
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get channelShape;

  /// No description provided for @gameTitle.
  ///
  /// In en, this message translates to:
  /// **'N-back'**
  String get gameTitle;

  /// No description provided for @gameInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Match\" on each channel when the stimulus matches the one N steps ago.'**
  String get gameInstructions;

  /// No description provided for @gameChannelsLabel.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get gameChannelsLabel;

  /// No description provided for @gameLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level N: {n}'**
  String gameLevelLabel(int n);

  /// No description provided for @gameStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get gameStartButton;

  /// No description provided for @gameStartHintNoChannels.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one channel'**
  String get gameStartHintNoChannels;

  /// No description provided for @gameSoundOffWarning.
  ///
  /// In en, this message translates to:
  /// **'Phone sound is off'**
  String get gameSoundOffWarning;

  /// No description provided for @gameSoundLowWarning.
  ///
  /// In en, this message translates to:
  /// **'Low sound volume: {percent}%'**
  String gameSoundLowWarning(int percent);

  /// No description provided for @pauseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTooltip;

  /// No description provided for @pauseDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pauseDialogTitle;

  /// No description provided for @pauseDialogContent.
  ///
  /// In en, this message translates to:
  /// **'The session is paused.'**
  String get pauseDialogContent;

  /// No description provided for @pauseDialogResume.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get pauseDialogResume;

  /// No description provided for @pauseDialogHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get pauseDialogHome;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get resultTitle;

  /// No description provided for @resultAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'N={n}'**
  String resultAppBarTitle(int n);

  /// No description provided for @resultLevelUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Level up:'**
  String get resultLevelUpLabel;

  /// No description provided for @resultLevelDownLabel.
  ///
  /// In en, this message translates to:
  /// **'Level down:'**
  String get resultLevelDownLabel;

  /// No description provided for @resultLevelHold.
  ///
  /// In en, this message translates to:
  /// **'Level held: N = {n}'**
  String resultLevelHold(int n);

  /// No description provided for @resultAccuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get resultAccuracyLabel;

  /// No description provided for @resultClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get resultClose;

  /// No description provided for @resultAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get resultAgain;

  /// No description provided for @statHits.
  ///
  /// In en, this message translates to:
  /// **'hits'**
  String get statHits;

  /// No description provided for @statMisses.
  ///
  /// In en, this message translates to:
  /// **'misses'**
  String get statMisses;

  /// No description provided for @statFalseAlarms.
  ///
  /// In en, this message translates to:
  /// **'false +'**
  String get statFalseAlarms;

  /// No description provided for @statCorrectRejections.
  ///
  /// In en, this message translates to:
  /// **'correct -'**
  String get statCorrectRejections;

  /// No description provided for @statDPrime.
  ///
  /// In en, this message translates to:
  /// **'d\''**
  String get statDPrime;

  /// No description provided for @statEngaged.
  ///
  /// In en, this message translates to:
  /// **'engaged'**
  String get statEngaged;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsResetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetTooltip;

  /// No description provided for @settingsResetGroupTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset this group to defaults'**
  String get settingsResetGroupTooltip;

  /// No description provided for @settingsSectionDefaultChannels.
  ///
  /// In en, this message translates to:
  /// **'Default channels and button layout'**
  String get settingsSectionDefaultChannels;

  /// No description provided for @settingsLayoutHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to toggle a channel. Long-press a cell and drag onto another to swap.'**
  String get settingsLayoutHint;

  /// No description provided for @settingsSectionLevel.
  ///
  /// In en, this message translates to:
  /// **'Level N'**
  String get settingsSectionLevel;

  /// No description provided for @settingsSectionTimings.
  ///
  /// In en, this message translates to:
  /// **'Timings'**
  String get settingsSectionTimings;

  /// No description provided for @settingsInitialN.
  ///
  /// In en, this message translates to:
  /// **'Initial N'**
  String get settingsInitialN;

  /// No description provided for @settingsRangeN.
  ///
  /// In en, this message translates to:
  /// **'N range (min — max)'**
  String get settingsRangeN;

  /// No description provided for @settingsRangeNValue.
  ///
  /// In en, this message translates to:
  /// **'{min} — {max}'**
  String settingsRangeNValue(int min, int max);

  /// No description provided for @settingsAdaptive.
  ///
  /// In en, this message translates to:
  /// **'Adaptive mode'**
  String get settingsAdaptive;

  /// No description provided for @settingsAdaptiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Increase N at ≥{advance}% accuracy, decrease at ≤{regress}%'**
  String settingsAdaptiveSubtitle(int advance, int regress);

  /// No description provided for @settingsAdaptiveThresholds.
  ///
  /// In en, this message translates to:
  /// **'Accuracy thresholds'**
  String get settingsAdaptiveThresholds;

  /// No description provided for @settingsAdaptiveThresholdsValue.
  ///
  /// In en, this message translates to:
  /// **'{regress}% / {advance}%'**
  String settingsAdaptiveThresholdsValue(int regress, int advance);

  /// No description provided for @settingsMatchProbability.
  ///
  /// In en, this message translates to:
  /// **'Channel matches'**
  String get settingsMatchProbability;

  /// No description provided for @settingsMatchProbabilityJitter.
  ///
  /// In en, this message translates to:
  /// **'Added randomness'**
  String get settingsMatchProbabilityJitter;

  /// No description provided for @settingsMatchProbabilityHint.
  ///
  /// In en, this message translates to:
  /// **'Each channel in a session will have {matches} matches randomly distributed across {trials} trials.'**
  String settingsMatchProbabilityHint(int matches, int trials);

  /// No description provided for @settingsMatchProbabilityHintJitter.
  ///
  /// In en, this message translates to:
  /// **'Each channel in a session will have {matches}±{jitter} matches randomly distributed across {trials} trials.'**
  String settingsMatchProbabilityHintJitter(
    int matches,
    int jitter,
    int trials,
  );

  /// No description provided for @settingsMatchProbabilityHintMinMatch.
  ///
  /// In en, this message translates to:
  /// **'At least one match per channel.'**
  String get settingsMatchProbabilityHintMinMatch;

  /// No description provided for @settingsPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String settingsPercent(int value);

  /// No description provided for @settingsTrialsPerSession.
  ///
  /// In en, this message translates to:
  /// **'Trials per session'**
  String get settingsTrialsPerSession;

  /// No description provided for @settingsStimulusDuration.
  ///
  /// In en, this message translates to:
  /// **'Stimulus duration'**
  String get settingsStimulusDuration;

  /// No description provided for @settingsStimulusFade.
  ///
  /// In en, this message translates to:
  /// **'Stimulus fade-in/out'**
  String get settingsStimulusFade;

  /// No description provided for @settingsIsi.
  ///
  /// In en, this message translates to:
  /// **'Inter-stimulus interval (ISI)'**
  String get settingsIsi;

  /// No description provided for @settingsMs.
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String settingsMs(int ms);

  /// No description provided for @settingsEstimatedDuration.
  ///
  /// In en, this message translates to:
  /// **'Estimated session duration'**
  String get settingsEstimatedDuration;

  /// No description provided for @settingsSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String settingsSeconds(int seconds);

  /// No description provided for @settingsMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String settingsMinutesSeconds(int minutes, int seconds);

  /// No description provided for @settingsSectionGridStyle.
  ///
  /// In en, this message translates to:
  /// **'Grid style'**
  String get settingsSectionGridStyle;

  /// No description provided for @settingsGridStyleTile.
  ///
  /// In en, this message translates to:
  /// **'Tile'**
  String get settingsGridStyleTile;

  /// No description provided for @settingsGridStyleClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get settingsGridStyleClassic;

  /// No description provided for @settingsShowFixationCross.
  ///
  /// In en, this message translates to:
  /// **'Show fixation cross in the center'**
  String get settingsShowFixationCross;

  /// No description provided for @settingsAllowCenterPosition.
  ///
  /// In en, this message translates to:
  /// **'Add a ninth position-stimulus variant in the center of the grid'**
  String get settingsAllowCenterPosition;

  /// No description provided for @settingsAllowCenterPositionHint.
  ///
  /// In en, this message translates to:
  /// **'In the original Jaeggi test the stimulus never appears in the center, but you can enable this if you want. It slightly increases position-channel difficulty since there will be nine possible cells instead of eight.'**
  String get settingsAllowCenterPositionHint;

  /// No description provided for @settingsSectionSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSectionSound;

  /// No description provided for @settingsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsVolume;

  /// No description provided for @settingsVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get settingsVoice;

  /// No description provided for @settingsVoiceFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get settingsVoiceFemale;

  /// No description provided for @settingsVoiceMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get settingsVoiceMale;

  /// No description provided for @settingsLetters.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get settingsLetters;

  /// No description provided for @settingsLettersHint.
  ///
  /// In en, this message translates to:
  /// **'Recommended to pick eight letters, minimum four.'**
  String get settingsLettersHint;

  /// No description provided for @settingsSectionFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsSectionFeedback;

  /// No description provided for @settingsFeedbackVisualPress.
  ///
  /// In en, this message translates to:
  /// **'Visual button-colour feedback on match presses'**
  String get settingsFeedbackVisualPress;

  /// No description provided for @settingsFeedbackAudioPress.
  ///
  /// In en, this message translates to:
  /// **'Audio feedback on incorrect match press'**
  String get settingsFeedbackAudioPress;

  /// No description provided for @settingsFeedbackVisualMiss.
  ///
  /// In en, this message translates to:
  /// **'Visual button-colour feedback on missed matches'**
  String get settingsFeedbackVisualMiss;

  /// No description provided for @settingsFeedbackAudioMiss.
  ///
  /// In en, this message translates to:
  /// **'Audio feedback on missed match'**
  String get settingsFeedbackAudioMiss;

  /// No description provided for @settingsSectionDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily session goal'**
  String get settingsSectionDailyGoal;

  /// No description provided for @settingsDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Sessions per day'**
  String get settingsDailyGoal;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Show notifications'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsNotificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notification time'**
  String get settingsNotificationTime;

  /// No description provided for @settingsNotificationsRestDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Notifications won\'t fire on rest days, if any are selected.'**
  String get settingsNotificationsRestDaysHint;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to train!'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your daily N-back session is waiting.'**
  String get notificationBody;

  /// No description provided for @settingsRestDays.
  ///
  /// In en, this message translates to:
  /// **'Rest days'**
  String get settingsRestDays;

  /// No description provided for @settingsRestDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Rest days are excluded from the count of consecutive days where the daily session goal was met.'**
  String get settingsRestDaysHint;

  /// No description provided for @homeDailyProgress.
  ///
  /// In en, this message translates to:
  /// **'{count}/{goal}'**
  String homeDailyProgress(int count, int goal);

  /// No description provided for @homeStreakTooltip.
  ///
  /// In en, this message translates to:
  /// **'Days in a row the current session goal was met'**
  String get homeStreakTooltip;

  /// No description provided for @homeRestDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get homeRestDayLabel;

  /// No description provided for @homeDailyGoalTooltip.
  ///
  /// In en, this message translates to:
  /// **'Daily session goal progress'**
  String get homeDailyGoalTooltip;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageRu.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRu;

  /// No description provided for @settingsSectionTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsSectionTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset settings?'**
  String get settingsResetTitle;

  /// No description provided for @settingsResetContent.
  ///
  /// In en, this message translates to:
  /// **'All values will revert to defaults.'**
  String get settingsResetContent;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @statisticsClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get statisticsClearTooltip;

  /// No description provided for @statisticsClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear history?'**
  String get statisticsClearTitle;

  /// No description provided for @statisticsClearContent.
  ///
  /// In en, this message translates to:
  /// **'This action can\'t be undone.'**
  String get statisticsClearContent;

  /// No description provided for @statisticsExportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export history to file'**
  String get statisticsExportTooltip;

  /// No description provided for @statisticsImportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import history from file'**
  String get statisticsImportTooltip;

  /// No description provided for @statisticsExportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save history backup'**
  String get statisticsExportDialogTitle;

  /// No description provided for @statisticsExportEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to export — history is empty.'**
  String get statisticsExportEmpty;

  /// No description provided for @statisticsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Exported {count, plural, one{{count} session} other{{count} sessions}}.'**
  String statisticsExportSuccess(int count);

  /// No description provided for @statisticsExportError.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {message}'**
  String statisticsExportError(String message);

  /// No description provided for @statisticsImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace history?'**
  String get statisticsImportTitle;

  /// No description provided for @statisticsImportContent.
  ///
  /// In en, this message translates to:
  /// **'All current sessions ({count, plural, =0{no sessions yet} one{{count} session} other{{count} sessions}}) will be permanently deleted and replaced with the sessions from the chosen file. This action can\'t be undone.'**
  String statisticsImportContent(int count);

  /// No description provided for @statisticsImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get statisticsImportConfirm;

  /// No description provided for @statisticsImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count, plural, one{{count} session} other{{count} sessions}}.'**
  String statisticsImportSuccess(int count);

  /// No description provided for @statisticsImportFormatError.
  ///
  /// In en, this message translates to:
  /// **'Backup file is invalid: {message}'**
  String statisticsImportFormatError(String message);

  /// No description provided for @statisticsImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {message}'**
  String statisticsImportError(String message);

  /// No description provided for @statisticsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get statisticsEmptyTitle;

  /// No description provided for @statisticsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Finish your first session — the results will appear here.'**
  String get statisticsEmptySubtitle;

  /// No description provided for @statisticsSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'Sessions ({count})'**
  String statisticsSessionsCount(int count);

  /// No description provided for @statisticsPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get statisticsPeriodDay;

  /// No description provided for @statisticsPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get statisticsPeriodWeek;

  /// No description provided for @statisticsPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get statisticsPeriodMonth;

  /// No description provided for @statisticsPeriodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get statisticsPeriodYear;

  /// No description provided for @statisticsCursorCurrentWeek.
  ///
  /// In en, this message translates to:
  /// **'Current week'**
  String get statisticsCursorCurrentWeek;

  /// No description provided for @statisticsCursorWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} week ago, {year}} other{{count} weeks ago, {year}}}'**
  String statisticsCursorWeeksAgo(int count, int year);

  /// No description provided for @statisticsCursorWeeksAhead.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{In {count} week, {year}} other{In {count} weeks, {year}}}'**
  String statisticsCursorWeeksAhead(int count, int year);

  /// No description provided for @statisticsCursorYear.
  ///
  /// In en, this message translates to:
  /// **'{year}'**
  String statisticsCursorYear(int year);

  /// No description provided for @statisticsChartAvgAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Average accuracy, %'**
  String get statisticsChartAvgAccuracy;

  /// No description provided for @statisticsChartMaxN.
  ///
  /// In en, this message translates to:
  /// **'Max N'**
  String get statisticsChartMaxN;

  /// No description provided for @statisticsChartDprime.
  ///
  /// In en, this message translates to:
  /// **'Average d′'**
  String get statisticsChartDprime;

  /// No description provided for @statisticsChartChannelAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy by channel, %'**
  String get statisticsChartChannelAccuracy;

  /// No description provided for @statisticsChartHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get statisticsChartHeatmap;

  /// No description provided for @statisticsChartNDistribution.
  ///
  /// In en, this message translates to:
  /// **'Sessions per N'**
  String get statisticsChartNDistribution;

  /// No description provided for @statisticsSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Period summary'**
  String get statisticsSummaryTitle;

  /// No description provided for @statisticsSummaryBestSession.
  ///
  /// In en, this message translates to:
  /// **'Best session'**
  String get statisticsSummaryBestSession;

  /// No description provided for @statisticsSummaryBestSessionValue.
  ///
  /// In en, this message translates to:
  /// **'N{n} · {percent}% · {date}'**
  String statisticsSummaryBestSessionValue(int n, int percent, String date);

  /// No description provided for @statisticsSummaryBestSessionValueShort.
  ///
  /// In en, this message translates to:
  /// **'N{n} · {percent}%'**
  String statisticsSummaryBestSessionValueShort(int n, int percent);

  /// No description provided for @statisticsSummaryTotalTrials.
  ///
  /// In en, this message translates to:
  /// **'Total trials'**
  String get statisticsSummaryTotalTrials;

  /// No description provided for @statisticsSummaryTrainingTime.
  ///
  /// In en, this message translates to:
  /// **'Training time'**
  String get statisticsSummaryTrainingTime;

  /// No description provided for @statisticsSummaryDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get statisticsSummaryDailyGoal;

  /// No description provided for @statisticsSummaryDailyGoalValue.
  ///
  /// In en, this message translates to:
  /// **'{achieved} / {total} ({percent}%)'**
  String statisticsSummaryDailyGoalValue(int achieved, int total, int percent);

  /// No description provided for @statisticsSummaryHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String statisticsSummaryHoursMinutes(int hours, int minutes);

  /// No description provided for @statisticsSummaryMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String statisticsSummaryMinutes(int minutes);

  /// No description provided for @statisticsSummaryNone.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get statisticsSummaryNone;

  /// No description provided for @statisticsSessionPlural.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 sessions} one{{count} session} other{{count} sessions}}'**
  String statisticsSessionPlural(int count);

  /// No description provided for @statisticsSessionOverallLabel.
  ///
  /// In en, this message translates to:
  /// **'Overall accuracy'**
  String get statisticsSessionOverallLabel;

  /// No description provided for @statisticsSessionOverallValue.
  ///
  /// In en, this message translates to:
  /// **'{hits}/{engaged} = {percent}%'**
  String statisticsSessionOverallValue(int hits, int engaged, int percent);

  /// No description provided for @statisticsSessionOverallFormulaHint.
  ///
  /// In en, this message translates to:
  /// **'= sum of hits across channels / sum of engaged across channels (engaged = hits + misses + false alarms; correct rejections excluded)'**
  String get statisticsSessionOverallFormulaHint;

  /// No description provided for @statisticsSessionAdaptiveChangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Adaptive N:'**
  String get statisticsSessionAdaptiveChangeLabel;

  /// No description provided for @statisticsSessionDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get statisticsSessionDeleteTooltip;

  /// No description provided for @statisticsSessionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this session?'**
  String get statisticsSessionDeleteTitle;

  /// No description provided for @statisticsSessionDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'This action can\'t be undone.'**
  String get statisticsSessionDeleteContent;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @statisticsDebugFillButton.
  ///
  /// In en, this message translates to:
  /// **'Debug: fill 2 years of random data'**
  String get statisticsDebugFillButton;

  /// No description provided for @statisticsDebugFillProgress.
  ///
  /// In en, this message translates to:
  /// **'Generating data…'**
  String get statisticsDebugFillProgress;

  /// No description provided for @statisticsDebugFillDone.
  ///
  /// In en, this message translates to:
  /// **'Filled {count} sessions'**
  String statisticsDebugFillDone(int count);

  /// No description provided for @statisticsChartN.
  ///
  /// In en, this message translates to:
  /// **'Level N'**
  String get statisticsChartN;

  /// No description provided for @statisticsChartAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Overall accuracy, %'**
  String get statisticsChartAccuracy;

  /// No description provided for @statisticsTrialCountSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count} trials'**
  String statisticsTrialCountSuffix(int count);

  /// No description provided for @statisticsErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String statisticsErrorPrefix(String message);

  /// No description provided for @homeAchievementsButton.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get homeAchievementsButton;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target}'**
  String achProgressLabel(int current, int target);

  /// No description provided for @achEarnedBadge.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get achEarnedBadge;

  /// No description provided for @resultDailyGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Daily goal reached!'**
  String get resultDailyGoalReached;

  /// No description provided for @resultAchievementsUnlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Achievement unlocked!} other{{count} achievements unlocked!}}'**
  String resultAchievementsUnlockedTitle(int count);

  /// No description provided for @achGroupMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get achGroupMilestones;

  /// No description provided for @achGroupPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get achGroupPerformance;

  /// No description provided for @achGroupConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get achGroupConsistency;

  /// No description provided for @achGroupResilience.
  ///
  /// In en, this message translates to:
  /// **'Resilience'**
  String get achGroupResilience;

  /// No description provided for @achGroupExploration.
  ///
  /// In en, this message translates to:
  /// **'Exploration'**
  String get achGroupExploration;

  /// No description provided for @achCenturionTitle.
  ///
  /// In en, this message translates to:
  /// **'Centurion'**
  String get achCenturionTitle;

  /// No description provided for @achCenturionDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 1,000 sessions'**
  String get achCenturionDesc;

  /// No description provided for @achLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get achLegendTitle;

  /// No description provided for @achLegendDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 2,500 sessions'**
  String get achLegendDesc;

  /// No description provided for @achImmortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Immortal'**
  String get achImmortalTitle;

  /// No description provided for @achImmortalDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 5,000 sessions'**
  String get achImmortalDesc;

  /// No description provided for @achAscendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Ascended'**
  String get achAscendedTitle;

  /// No description provided for @achAscendedDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 10,000 sessions'**
  String get achAscendedDesc;

  /// No description provided for @achPractitionerTitle.
  ///
  /// In en, this message translates to:
  /// **'Practitioner'**
  String get achPractitionerTitle;

  /// No description provided for @achPractitionerDesc.
  ///
  /// In en, this message translates to:
  /// **'Play 5,000 trials in total'**
  String get achPractitionerDesc;

  /// No description provided for @achTrainedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trained'**
  String get achTrainedTitle;

  /// No description provided for @achTrainedDesc.
  ///
  /// In en, this message translates to:
  /// **'Play 10,000 trials in total'**
  String get achTrainedDesc;

  /// No description provided for @achSeasonedTitle.
  ///
  /// In en, this message translates to:
  /// **'Seasoned'**
  String get achSeasonedTitle;

  /// No description provided for @achSeasonedDesc.
  ///
  /// In en, this message translates to:
  /// **'Play 50,000 trials in total'**
  String get achSeasonedDesc;

  /// No description provided for @achTrials100kTitle.
  ///
  /// In en, this message translates to:
  /// **'100,000 Trials'**
  String get achTrials100kTitle;

  /// No description provided for @achTrials100kDesc.
  ///
  /// In en, this message translates to:
  /// **'Play 100,000 trials in total'**
  String get achTrials100kDesc;

  /// No description provided for @achTitanTitle.
  ///
  /// In en, this message translates to:
  /// **'Titan'**
  String get achTitanTitle;

  /// No description provided for @achTitanDesc.
  ///
  /// In en, this message translates to:
  /// **'Play 150,000 trials in total'**
  String get achTitanDesc;

  /// No description provided for @achSteelResolveTitle.
  ///
  /// In en, this message translates to:
  /// **'Steel Resolve'**
  String get achSteelResolveTitle;

  /// No description provided for @achSteelResolveDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit the daily goal 60 days in a row'**
  String get achSteelResolveDesc;

  /// No description provided for @achFlawlessQuarterTitle.
  ///
  /// In en, this message translates to:
  /// **'Flawless Quarter'**
  String get achFlawlessQuarterTitle;

  /// No description provided for @achFlawlessQuarterDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit the daily goal 90 days in a row'**
  String get achFlawlessQuarterDesc;

  /// No description provided for @achFlawlessHalfYearTitle.
  ///
  /// In en, this message translates to:
  /// **'Flawless Half-Year'**
  String get achFlawlessHalfYearTitle;

  /// No description provided for @achFlawlessHalfYearDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit the daily goal 180 days in a row'**
  String get achFlawlessHalfYearDesc;

  /// No description provided for @achPerfectYearTitle.
  ///
  /// In en, this message translates to:
  /// **'Perfect Year'**
  String get achPerfectYearTitle;

  /// No description provided for @achPerfectYearDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit the daily goal 365 days in a row'**
  String get achPerfectYearDesc;

  /// No description provided for @achVeteranTitle.
  ///
  /// In en, this message translates to:
  /// **'Veteran'**
  String get achVeteranTitle;

  /// No description provided for @achVeteranDesc.
  ///
  /// In en, this message translates to:
  /// **'Use the app for 1 year'**
  String get achVeteranDesc;

  /// No description provided for @achSharpBrainTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharp Brain'**
  String get achSharpBrainTitle;

  /// No description provided for @achSharpBrainDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach N≥3 with ≥90% accuracy'**
  String get achSharpBrainDesc;

  /// No description provided for @achMuscularBrainTitle.
  ///
  /// In en, this message translates to:
  /// **'Muscular Brain'**
  String get achMuscularBrainTitle;

  /// No description provided for @achMuscularBrainDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach N≥4 with ≥90% accuracy'**
  String get achMuscularBrainDesc;

  /// No description provided for @achOlympicBrainTitle.
  ///
  /// In en, this message translates to:
  /// **'Olympic Brain'**
  String get achOlympicBrainTitle;

  /// No description provided for @achOlympicBrainDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach N≥5 with ≥90% accuracy'**
  String get achOlympicBrainDesc;

  /// No description provided for @achGeniusBrainTitle.
  ///
  /// In en, this message translates to:
  /// **'Genius Brain'**
  String get achGeniusBrainTitle;

  /// No description provided for @achGeniusBrainDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach N≥6 with ≥90% accuracy'**
  String get achGeniusBrainDesc;

  /// No description provided for @achCognitiveEliteTitle.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Elite'**
  String get achCognitiveEliteTitle;

  /// No description provided for @achCognitiveEliteDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach N≥7 with ≥90% accuracy'**
  String get achCognitiveEliteDesc;

  /// No description provided for @achCosmicMindTitle.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Mind'**
  String get achCosmicMindTitle;

  /// No description provided for @achCosmicMindDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach N≥8 with ≥90% accuracy'**
  String get achCosmicMindDesc;

  /// No description provided for @achMythicMindTitle.
  ///
  /// In en, this message translates to:
  /// **'Mythic Mind'**
  String get achMythicMindTitle;

  /// No description provided for @achMythicMindDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach N≥9 with ≥90% accuracy'**
  String get achMythicMindDesc;

  /// No description provided for @achSuperhumanTitle.
  ///
  /// In en, this message translates to:
  /// **'Superhuman'**
  String get achSuperhumanTitle;

  /// No description provided for @achSuperhumanDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach N≥10 with ≥90% accuracy'**
  String get achSuperhumanDesc;

  /// No description provided for @achSniperTitle.
  ///
  /// In en, this message translates to:
  /// **'Sniper'**
  String get achSniperTitle;

  /// No description provided for @achSniperDesc.
  ///
  /// In en, this message translates to:
  /// **'≥90% overall accuracy at N≥4'**
  String get achSniperDesc;

  /// No description provided for @achSurgicalPrecisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Surgical Precision'**
  String get achSurgicalPrecisionTitle;

  /// No description provided for @achSurgicalPrecisionDesc.
  ///
  /// In en, this message translates to:
  /// **'≥95% overall accuracy at N≥4'**
  String get achSurgicalPrecisionDesc;

  /// No description provided for @achLaserTitle.
  ///
  /// In en, this message translates to:
  /// **'Laser'**
  String get achLaserTitle;

  /// No description provided for @achLaserDesc.
  ///
  /// In en, this message translates to:
  /// **'≥98% overall accuracy at N≥5'**
  String get achLaserDesc;

  /// No description provided for @achUntouchableTitle.
  ///
  /// In en, this message translates to:
  /// **'Untouchable'**
  String get achUntouchableTitle;

  /// No description provided for @achUntouchableDesc.
  ///
  /// In en, this message translates to:
  /// **'Perfect session (no errors) at N≥5'**
  String get achUntouchableDesc;

  /// No description provided for @achDprimeMasterTitle.
  ///
  /// In en, this message translates to:
  /// **'d′ Master'**
  String get achDprimeMasterTitle;

  /// No description provided for @achDprimeMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach d′ > 3.0 in a session at N≥4'**
  String get achDprimeMasterDesc;

  /// No description provided for @achAwakenedNeuronTitle.
  ///
  /// In en, this message translates to:
  /// **'Awakened Neuron'**
  String get achAwakenedNeuronTitle;

  /// No description provided for @achAwakenedNeuronDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first session'**
  String get achAwakenedNeuronDesc;

  /// No description provided for @achFoundationTitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation'**
  String get achFoundationTitle;

  /// No description provided for @achFoundationDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 50 sessions'**
  String get achFoundationDesc;

  /// No description provided for @achPillarBronzeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pillar (Bronze)'**
  String get achPillarBronzeTitle;

  /// No description provided for @achPillarBronzeDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 100 sessions'**
  String get achPillarBronzeDesc;

  /// No description provided for @achPillarSilverTitle.
  ///
  /// In en, this message translates to:
  /// **'Pillar (Silver)'**
  String get achPillarSilverTitle;

  /// No description provided for @achPillarSilverDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 250 sessions'**
  String get achPillarSilverDesc;

  /// No description provided for @achPillarGoldTitle.
  ///
  /// In en, this message translates to:
  /// **'Pillar (Gold)'**
  String get achPillarGoldTitle;

  /// No description provided for @achPillarGoldDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 500 sessions'**
  String get achPillarGoldDesc;

  /// No description provided for @achFirstDayTitle.
  ///
  /// In en, this message translates to:
  /// **'First Day'**
  String get achFirstDayTitle;

  /// No description provided for @achFirstDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit the daily goal'**
  String get achFirstDayDesc;

  /// No description provided for @achNascentRitualTitle.
  ///
  /// In en, this message translates to:
  /// **'Nascent Ritual'**
  String get achNascentRitualTitle;

  /// No description provided for @achNascentRitualDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit the daily goal 3 days in a row'**
  String get achNascentRitualDesc;

  /// No description provided for @achDailyRitualTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Ritual'**
  String get achDailyRitualTitle;

  /// No description provided for @achDailyRitualDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit the daily goal 7 days in a row'**
  String get achDailyRitualDesc;

  /// No description provided for @achAnchoredHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Anchored Habit'**
  String get achAnchoredHabitTitle;

  /// No description provided for @achAnchoredHabitDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit the daily goal 14 days in a row'**
  String get achAnchoredHabitDesc;

  /// No description provided for @achIronDisciplineTitle.
  ///
  /// In en, this message translates to:
  /// **'Iron Discipline'**
  String get achIronDisciplineTitle;

  /// No description provided for @achIronDisciplineDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit the daily goal 30 days in a row'**
  String get achIronDisciplineDesc;

  /// No description provided for @achEarlyBirdTitle.
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get achEarlyBirdTitle;

  /// No description provided for @achEarlyBirdDesc.
  ///
  /// In en, this message translates to:
  /// **'Train before 8am on 5 different days'**
  String get achEarlyBirdDesc;

  /// No description provided for @achNightOwlTitle.
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get achNightOwlTitle;

  /// No description provided for @achNightOwlDesc.
  ///
  /// In en, this message translates to:
  /// **'Train after 10pm on 5 different days'**
  String get achNightOwlDesc;

  /// No description provided for @achSteadyHandsTitle.
  ///
  /// In en, this message translates to:
  /// **'Steady Hands'**
  String get achSteadyHandsTitle;

  /// No description provided for @achSteadyHandsDesc.
  ///
  /// In en, this message translates to:
  /// **'No false inputs in a session at N≥4 with ≥80% accuracy'**
  String get achSteadyHandsDesc;

  /// No description provided for @achPersistentTitle.
  ///
  /// In en, this message translates to:
  /// **'Persistent'**
  String get achPersistentTitle;

  /// No description provided for @achPersistentDesc.
  ///
  /// In en, this message translates to:
  /// **'Play 3 more sessions the same day after a failed one'**
  String get achPersistentDesc;

  /// No description provided for @achAudiophileTitle.
  ///
  /// In en, this message translates to:
  /// **'Audiophile'**
  String get achAudiophileTitle;

  /// No description provided for @achAudiophileDesc.
  ///
  /// In en, this message translates to:
  /// **'Audio >80% but Position <70% in one session at N≥4'**
  String get achAudiophileDesc;

  /// No description provided for @achEagleEyeTitle.
  ///
  /// In en, this message translates to:
  /// **'Eagle Eye'**
  String get achEagleEyeTitle;

  /// No description provided for @achEagleEyeDesc.
  ///
  /// In en, this message translates to:
  /// **'Position >80% but Audio <70% in one session at N≥4'**
  String get achEagleEyeDesc;

  /// No description provided for @achSynchronizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Synchronized'**
  String get achSynchronizedTitle;

  /// No description provided for @achSynchronizedDesc.
  ///
  /// In en, this message translates to:
  /// **'Position and Audio within 5% at N≥4 (overall ≥60%)'**
  String get achSynchronizedDesc;

  /// No description provided for @achDualMasterTitle.
  ///
  /// In en, this message translates to:
  /// **'Dual Master'**
  String get achDualMasterTitle;

  /// No description provided for @achDualMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Position and Audio >85% in one session at N≥4 (overall ≥60%)'**
  String get achDualMasterDesc;

  /// No description provided for @achDualEliteTitle.
  ///
  /// In en, this message translates to:
  /// **'Dual Elite'**
  String get achDualEliteTitle;

  /// No description provided for @achDualEliteDesc.
  ///
  /// In en, this message translates to:
  /// **'Position and Audio >90% in one session at N≥4 (overall ≥60%)'**
  String get achDualEliteDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
