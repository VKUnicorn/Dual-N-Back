// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dual N-Back';

  @override
  String get appTagline => 'Working memory trainer';

  @override
  String get homeStartButton => 'Start session';

  @override
  String get homeInfoButton => 'Information';

  @override
  String get homeStatisticsButton => 'Statistics';

  @override
  String get homeSettingsButton => 'Settings';

  @override
  String get infoTitle => 'Information';

  @override
  String get infoSectionWhatIs => 'What is N-back?';

  @override
  String get infoSectionWhatIsBody =>
      'N-back is an exercise for your working memory. Cues appear one at a time on the screen (a letter, a colour, a position in a grid, and so on), and your job is to notice whether the current cue matches the one shown N steps back. The bigger N is, the harder it is to keep the sequence in mind.\n\nYou can train one channel at a time (Single — e.g. position only), two together (Dual — the classic version, usually position + sound), or all four (Quad). Each channel is judged on its own: a match in position doesn\'t mean a match in sound.';

  @override
  String get infoSectionJaeggi => 'The Jaeggi study';

  @override
  String get infoSectionJaeggiBody =>
      'In 2008, researchers led by Jaeggi published a study showing that about 19 days of daily Dual N-back training improved fluid intelligence (Gf) — the ability to solve new, unfamiliar problems. N-back has been a popular \'brain trainer\' ever since.\n\nThe app\'s default settings come from that same study: 20 trials per session, each cue shown for 500 ms, 2500 ms pause between cues, matches appear about 30% of the time. If adaptive mode is on, the N level goes up when per-channel accuracy is ≥90% and down when it\'s ≤70%.';

  @override
  String get infoSectionMetrics => 'Score metrics';

  @override
  String get infoMetricHits =>
      'Hits — you pressed Match where there really was a match.';

  @override
  String get infoMetricMisses =>
      'Misses — there was a match, but you didn\'t catch it.';

  @override
  String get infoMetricFalseAlarms =>
      'False + (false alarm) — you pressed Match, but there wasn\'t actually one.';

  @override
  String get infoMetricCorrectRejections =>
      'Correct − (correct rejection) — there was no match, and you correctly didn\'t press.';

  @override
  String get infoMetricAccuracy =>
      'Accuracy — the share of your decisions that were right. Computed as hits ÷ (hits + misses + false alarms). It drops both from missed matches and from wrong presses.';

  @override
  String get infoMetricDPrime =>
      'd′ (d-prime) — shows how well you tell real matches apart from non-matches. The higher it is, the more clearly you \'see\' the matches. It\'s a more honest measure than accuracy: you can\'t fool it by just pressing more or less often.';

  @override
  String get infoSectionTips => 'Practice tips';

  @override
  String get infoSectionTipsBody =>
      '• Train every day — a short daily session beats rare long ones.\n• Don\'t try to say the letters or positions out loud — let your memory do the work.\n• If your score stays flat for a few days, that\'s normal — the brain doesn\'t learn in a straight line. Just keep going.\n• Want N to adjust to your progress automatically? Turn on the Jaeggi adaptive mode in settings.';

  @override
  String get channelPosition => 'Position';

  @override
  String get channelAudio => 'Sound';

  @override
  String get channelColor => 'Color';

  @override
  String get channelShape => 'Shape';

  @override
  String get gameTitle => 'N-back';

  @override
  String gameTitleSingle(int n) {
    return 'Single $n-back';
  }

  @override
  String gameTitleDual(int n) {
    return 'Dual $n-back';
  }

  @override
  String gameTitleTriple(int n) {
    return 'Triple $n-back';
  }

  @override
  String gameTitleQuad(int n) {
    return 'Quad $n-back';
  }

  @override
  String get settingsSectionColors => 'Colors';

  @override
  String get settingsColors => 'Colors';

  @override
  String get settingsColorsHint => 'Tap a swatch to open the color picker.';

  @override
  String get settingsColorPickerTitle => 'Pick a color';

  @override
  String get settingsColorPickerHue => 'Hue';

  @override
  String get settingsColorPickerSaturation => 'Saturation';

  @override
  String get settingsColorPickerValue => 'Brightness';

  @override
  String gameInstructions(int n) {
    return 'Tap the matching channel button when the stimulus matches the one from N (i.e., $n) steps ago.';
  }

  @override
  String get gameChannelsLabel => 'Channels';

  @override
  String gameLevelLabel(int n) {
    return 'Level N: $n';
  }

  @override
  String gameInitialLevelLabel(int n) {
    return 'Initial level N: $n';
  }

  @override
  String get gameStartButton => 'Start';

  @override
  String get gameStartHintNoChannels => 'Pick at least one channel';

  @override
  String get gameSoundOffWarning => 'Phone sound is off';

  @override
  String gameSoundLowWarning(int percent) {
    return 'Low sound volume: $percent%';
  }

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get pauseDialogTitle => 'Paused';

  @override
  String get pauseDialogContent => 'The session is paused.';

  @override
  String get pauseDialogResume => 'Continue';

  @override
  String get pauseDialogHome => 'Home';

  @override
  String get resultTitle => 'Session complete';

  @override
  String resultAppBarTitle(int n) {
    return 'N=$n';
  }

  @override
  String get resultLevelUpLabel => 'Level N up:';

  @override
  String get resultLevelDownLabel => 'Level N down:';

  @override
  String resultLevelHold(int n) {
    return 'Level N held: $n';
  }

  @override
  String get resultAccuracyLabel => 'Accuracy';

  @override
  String get resultClose => 'Close';

  @override
  String get resultAgain => 'Again';

  @override
  String get statHits => 'hits';

  @override
  String get statMisses => 'misses';

  @override
  String get statFalseAlarms => 'false +';

  @override
  String get statCorrectRejections => 'correct -';

  @override
  String get statDPrime => 'd\'';

  @override
  String get statEngaged => 'engaged';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsResetTooltip => 'Reset';

  @override
  String get settingsResetGroupTooltip => 'Reset this group to defaults';

  @override
  String get settingsSectionDefaultChannels =>
      'Active channels and button layout';

  @override
  String get settingsLayoutHint =>
      'Tap to toggle a channel. Long-press a cell and drag onto another to swap.';

  @override
  String get settingsSectionLevel => 'Level N';

  @override
  String get settingsSectionTimings => 'Timings';

  @override
  String get settingsInitialN => 'Initial N';

  @override
  String get settingsRangeN => 'N range (min — max)';

  @override
  String settingsRangeNValue(int min, int max) {
    return '$min — $max';
  }

  @override
  String get settingsAdaptive => 'Adaptive mode';

  @override
  String settingsAdaptiveSubtitle(int advance, int regress) {
    return 'Increase N at ≥$advance% accuracy, decrease at ≤$regress%';
  }

  @override
  String get settingsAdaptiveThresholds => 'Accuracy thresholds';

  @override
  String settingsAdaptiveThresholdsValue(int regress, int advance) {
    return '$regress% / $advance%';
  }

  @override
  String get settingsMatchProbability => 'Channel matches';

  @override
  String get settingsMatchProbabilityJitter => 'Added randomness';

  @override
  String settingsMatchProbabilityHint(int matches, int trials) {
    return 'Each channel in a session will have $matches matches randomly distributed across $trials trials.';
  }

  @override
  String settingsMatchProbabilityHintJitter(
    int matches,
    int jitter,
    int trials,
  ) {
    return 'Each channel in a session will have $matches±$jitter matches randomly distributed across $trials trials.';
  }

  @override
  String get settingsMatchProbabilityHintMinMatch =>
      'At least one match per channel.';

  @override
  String settingsPercent(int value) {
    return '$value%';
  }

  @override
  String get settingsTrialsPerSession => 'Trials per session';

  @override
  String get settingsStimulusDuration => 'Stimulus duration';

  @override
  String get settingsStimulusFade => 'Stimulus fade-in/out';

  @override
  String get settingsIsi => 'Inter-stimulus interval (ISI)';

  @override
  String settingsMs(int ms) {
    return '$ms ms';
  }

  @override
  String get settingsEstimatedDuration => 'Estimated session duration';

  @override
  String settingsSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String settingsMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String get settingsSectionGridStyle => 'Grid style';

  @override
  String get settingsGridStyleTile => 'Tile';

  @override
  String get settingsGridStyleClassic => 'Classic';

  @override
  String get settingsShowFixationCross => 'Show fixation cross in the center';

  @override
  String get settingsAllowCenterPosition =>
      'Add a ninth position-stimulus variant in the center of the grid';

  @override
  String get settingsAllowCenterPositionHint =>
      'In the original Jaeggi test the stimulus never appears in the center, but you can enable this if you want. It slightly increases position-channel difficulty since there will be nine possible cells instead of eight.';

  @override
  String get settingsSectionSound => 'Sound';

  @override
  String get settingsVolume => 'Volume';

  @override
  String get settingsVoice => 'Voice';

  @override
  String get settingsVoiceFemale => 'Female';

  @override
  String get settingsVoiceMale => 'Male';

  @override
  String get settingsLetters => 'Letters';

  @override
  String get settingsLettersHint =>
      'Recommended to pick eight letters, minimum four.';

  @override
  String get settingsSectionFeedback => 'Feedback';

  @override
  String get settingsFeedbackVisualPress =>
      'Visual button-colour feedback on match presses';

  @override
  String get settingsFeedbackAudioPress =>
      'Audio feedback on incorrect match press';

  @override
  String get settingsFeedbackVisualMiss =>
      'Visual button-colour feedback on missed matches';

  @override
  String get settingsFeedbackAudioMiss => 'Audio feedback on missed match';

  @override
  String get settingsSectionDailyGoal => 'Daily session goal';

  @override
  String get settingsDailyGoal => 'Sessions per day';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsNotificationsEnabled => 'Show notifications';

  @override
  String get settingsNotificationTime => 'Notification time';

  @override
  String get settingsNotificationsRestDaysHint =>
      'Notifications won\'t fire on rest days, if any are selected.';

  @override
  String get notificationTitle => 'Time to train!';

  @override
  String get notificationBody => 'Your daily N-back session is waiting.';

  @override
  String get settingsRestDays => 'Rest days';

  @override
  String get settingsRestDaysHint =>
      'Rest days are excluded from the count of consecutive days where the daily session goal was met.';

  @override
  String homeDailyProgress(int count, int goal) {
    return '$count/$goal';
  }

  @override
  String get homeStreakTooltip =>
      'Days in a row the current session goal was met';

  @override
  String get homeRestDayLabel => 'Rest day';

  @override
  String get homeDailyGoalTooltip => 'Daily session goal progress';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageRu => 'Русский';

  @override
  String get settingsSectionTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSectionPreset => 'Training profiles';

  @override
  String get presetSectionHint =>
      'All settings in the block below are saved in the training profile. You can add your own profiles.';

  @override
  String get presetDefaultName => 'Classic';

  @override
  String get presetAddTooltip => 'New profile';

  @override
  String get presetRenameTooltip => 'Rename profile';

  @override
  String get presetDeleteTooltip => 'Delete profile';

  @override
  String get presetCreateTitle => 'New profile';

  @override
  String get presetRenameTitle => 'Rename profile';

  @override
  String get presetNameLabel => 'Name';

  @override
  String get presetCreateConfirm => 'Create';

  @override
  String get presetRenameConfirm => 'Rename';

  @override
  String get presetDeleteTitle => 'Delete profile?';

  @override
  String presetDeleteContent(String name) {
    return 'Profile \"$name\" will be permanently removed.';
  }

  @override
  String get settingsResetTitle => 'Reset settings?';

  @override
  String get settingsResetContent =>
      'The active preset and global settings will revert to defaults. Other presets are kept.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonClear => 'Clear';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsProfileFilter => 'Training profile';

  @override
  String get statisticsProfileAll => 'All training profiles';

  @override
  String get statisticsClearTooltip => 'Clear history';

  @override
  String get statisticsClearTitle => 'Clear history?';

  @override
  String get statisticsClearContent => 'This action can\'t be undone.';

  @override
  String get statisticsExportTooltip => 'Export history to file';

  @override
  String get statisticsImportTooltip => 'Import history from file';

  @override
  String get statisticsExportDialogTitle => 'Save history backup';

  @override
  String get statisticsExportEmpty => 'Nothing to export — history is empty.';

  @override
  String statisticsExportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '$count session',
    );
    return 'Exported $_temp0.';
  }

  @override
  String statisticsExportError(String message) {
    return 'Export failed: $message';
  }

  @override
  String get statisticsImportTitle => 'Replace history?';

  @override
  String statisticsImportContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '$count session',
      zero: 'no sessions yet',
    );
    return 'All current sessions ($_temp0) will be permanently deleted and replaced with the sessions from the chosen file. This action can\'t be undone.';
  }

  @override
  String get statisticsImportConfirm => 'Replace';

  @override
  String statisticsImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '$count session',
    );
    return 'Imported $_temp0.';
  }

  @override
  String statisticsImportFormatError(String message) {
    return 'Backup file is invalid: $message';
  }

  @override
  String statisticsImportError(String message) {
    return 'Import failed: $message';
  }

  @override
  String get statisticsEmptyTitle => 'No history yet';

  @override
  String get statisticsEmptySubtitle =>
      'Finish your first session — the results will appear here.';

  @override
  String statisticsSessionsCount(int count) {
    return 'Sessions ($count)';
  }

  @override
  String get statisticsPeriodDay => 'Day';

  @override
  String get statisticsPeriodWeek => 'Week';

  @override
  String get statisticsPeriodMonth => 'Month';

  @override
  String get statisticsPeriodYear => 'Year';

  @override
  String get statisticsCursorCurrentWeek => 'Current week';

  @override
  String statisticsCursorWeeksAgo(int count, int year) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago, $year',
      one: '$count week ago, $year',
    );
    return '$_temp0';
  }

  @override
  String statisticsCursorWeeksAhead(int count, int year) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count weeks, $year',
      one: 'In $count week, $year',
    );
    return '$_temp0';
  }

  @override
  String statisticsCursorYear(int year) {
    return '$year';
  }

  @override
  String get statisticsChartAvgAccuracy => 'Average accuracy, %';

  @override
  String get statisticsChartMaxN => 'Max N';

  @override
  String get statisticsChartDprime => 'Average d′';

  @override
  String get statisticsChartChannelAccuracy => 'Accuracy by channel, %';

  @override
  String get statisticsChartHeatmap => 'Activity';

  @override
  String get statisticsChartNDistribution => 'Sessions per N';

  @override
  String get statisticsSummaryTitle => 'Period summary';

  @override
  String get statisticsSummaryBestSession => 'Best session';

  @override
  String statisticsSummaryBestSessionValue(
    String label,
    int percent,
    String date,
  ) {
    return '$label · $percent% · $date';
  }

  @override
  String statisticsSummaryBestSessionValueShort(String label, int percent) {
    return '$label · $percent%';
  }

  @override
  String get statisticsSummaryTotalTrials => 'Total trials';

  @override
  String get statisticsSummaryTrainingTime => 'Training time';

  @override
  String get statisticsSummaryDailyGoal => 'Daily goal';

  @override
  String statisticsSummaryDailyGoalValue(int achieved, int total, int percent) {
    return '$achieved / $total ($percent%)';
  }

  @override
  String statisticsSummaryHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String statisticsSummaryMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String get statisticsSummaryNone => '—';

  @override
  String statisticsSessionPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '$count session',
      zero: '0 sessions',
    );
    return '$_temp0';
  }

  @override
  String get statisticsSessionOverallLabel => 'Overall accuracy';

  @override
  String statisticsSessionOverallValue(int hits, int engaged, int percent) {
    return '$hits/$engaged = $percent%';
  }

  @override
  String get statisticsSessionOverallFormulaHint =>
      '= sum of hits across channels / sum of engaged across channels (engaged = hits + misses + false alarms; correct rejections excluded)';

  @override
  String get statisticsSessionAdaptiveChangeLabel => 'Adaptive N:';

  @override
  String get statisticsSessionDeleteTooltip => 'Delete session';

  @override
  String get statisticsSessionDeleteTitle => 'Delete this session?';

  @override
  String get statisticsSessionDeleteContent => 'This action can\'t be undone.';

  @override
  String get commonDelete => 'Delete';

  @override
  String get statisticsDebugFillButton => 'Debug: fill 2 years of random data';

  @override
  String get statisticsDebugFillProgress => 'Generating data…';

  @override
  String statisticsDebugFillDone(int count) {
    return 'Filled $count sessions';
  }

  @override
  String get statisticsChartN => 'Level N';

  @override
  String get statisticsChartAccuracy => 'Overall accuracy, %';

  @override
  String statisticsTrialCountSuffix(int count) {
    return '$count trials';
  }

  @override
  String statisticsErrorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get homeAchievementsButton => 'Achievements';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String achProgressLabel(int current, int target) {
    return '$current / $target';
  }

  @override
  String get achEarnedBadge => 'Earned';

  @override
  String get resultDailyGoalReached => 'Daily goal reached!';

  @override
  String resultAchievementsUnlockedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count achievements unlocked!',
      one: 'Achievement unlocked!',
    );
    return '$_temp0';
  }

  @override
  String get achGroupMilestones => 'Milestones';

  @override
  String get achGroupPerformance => 'Performance';

  @override
  String get achGroupConsistency => 'Consistency';

  @override
  String get achGroupResilience => 'Resilience';

  @override
  String get achGroupExploration => 'Exploration';

  @override
  String get achCenturionTitle => 'Centurion';

  @override
  String get achCenturionDesc => 'Complete 1,000 sessions';

  @override
  String get achLegendTitle => 'Legend';

  @override
  String get achLegendDesc => 'Complete 2,500 sessions';

  @override
  String get achImmortalTitle => 'Immortal';

  @override
  String get achImmortalDesc => 'Complete 5,000 sessions';

  @override
  String get achAscendedTitle => 'Ascended';

  @override
  String get achAscendedDesc => 'Complete 10,000 sessions';

  @override
  String get achPractitionerTitle => 'Practitioner';

  @override
  String get achPractitionerDesc => 'Play 5,000 trials in total';

  @override
  String get achTrainedTitle => 'Trained';

  @override
  String get achTrainedDesc => 'Play 10,000 trials in total';

  @override
  String get achSeasonedTitle => 'Seasoned';

  @override
  String get achSeasonedDesc => 'Play 50,000 trials in total';

  @override
  String get achTrials100kTitle => '100,000 Trials';

  @override
  String get achTrials100kDesc => 'Play 100,000 trials in total';

  @override
  String get achTitanTitle => 'Titan';

  @override
  String get achTitanDesc => 'Play 150,000 trials in total';

  @override
  String get achSteelResolveTitle => 'Steel Resolve';

  @override
  String get achSteelResolveDesc => 'Hit the daily goal 60 days in a row';

  @override
  String get achFlawlessQuarterTitle => 'Flawless Quarter';

  @override
  String get achFlawlessQuarterDesc => 'Hit the daily goal 90 days in a row';

  @override
  String get achFlawlessHalfYearTitle => 'Flawless Half-Year';

  @override
  String get achFlawlessHalfYearDesc => 'Hit the daily goal 180 days in a row';

  @override
  String get achPerfectYearTitle => 'Perfect Year';

  @override
  String get achPerfectYearDesc => 'Hit the daily goal 365 days in a row';

  @override
  String get achVeteranTitle => 'Veteran';

  @override
  String get achVeteranDesc => 'Use the app for 1 year';

  @override
  String get achSharpBrainTitle => 'Sharp Brain';

  @override
  String get achSharpBrainDesc => 'Reach N≥3 with ≥90% accuracy';

  @override
  String get achMuscularBrainTitle => 'Muscular Brain';

  @override
  String get achMuscularBrainDesc => 'Reach N≥4 with ≥90% accuracy';

  @override
  String get achOlympicBrainTitle => 'Olympic Brain';

  @override
  String get achOlympicBrainDesc => 'Reach N≥5 with ≥90% accuracy';

  @override
  String get achGeniusBrainTitle => 'Genius Brain';

  @override
  String get achGeniusBrainDesc => 'Reach N≥6 with ≥90% accuracy';

  @override
  String get achCognitiveEliteTitle => 'Cognitive Elite';

  @override
  String get achCognitiveEliteDesc => 'Reach N≥7 with ≥90% accuracy';

  @override
  String get achCosmicMindTitle => 'Cosmic Mind';

  @override
  String get achCosmicMindDesc => 'Reach N≥8 with ≥90% accuracy';

  @override
  String get achMythicMindTitle => 'Mythic Mind';

  @override
  String get achMythicMindDesc => 'Reach N≥9 with ≥90% accuracy';

  @override
  String get achSuperhumanTitle => 'Superhuman';

  @override
  String get achSuperhumanDesc => 'Reach N≥10 with ≥90% accuracy';

  @override
  String get achSniperTitle => 'Sniper';

  @override
  String get achSniperDesc => '≥90% overall accuracy at N≥4';

  @override
  String get achSurgicalPrecisionTitle => 'Surgical Precision';

  @override
  String get achSurgicalPrecisionDesc => '≥95% overall accuracy at N≥4';

  @override
  String get achLaserTitle => 'Laser';

  @override
  String get achLaserDesc => '≥98% overall accuracy at N≥5';

  @override
  String get achUntouchableTitle => 'Untouchable';

  @override
  String get achUntouchableDesc => 'Perfect session (no errors) at N≥5';

  @override
  String get achDprimeMasterTitle => 'd′ Master';

  @override
  String get achDprimeMasterDesc => 'Reach d′ > 3.0 in a session at N≥4';

  @override
  String get achAwakenedNeuronTitle => 'Awakened Neuron';

  @override
  String get achAwakenedNeuronDesc => 'Complete your first session';

  @override
  String get achFoundationTitle => 'Foundation';

  @override
  String get achFoundationDesc => 'Complete 50 sessions';

  @override
  String get achPillarBronzeTitle => 'Pillar (Bronze)';

  @override
  String get achPillarBronzeDesc => 'Complete 100 sessions';

  @override
  String get achPillarSilverTitle => 'Pillar (Silver)';

  @override
  String get achPillarSilverDesc => 'Complete 250 sessions';

  @override
  String get achPillarGoldTitle => 'Pillar (Gold)';

  @override
  String get achPillarGoldDesc => 'Complete 500 sessions';

  @override
  String get achFirstDayTitle => 'First Day';

  @override
  String get achFirstDayDesc => 'Hit the daily goal';

  @override
  String get achNascentRitualTitle => 'Nascent Ritual';

  @override
  String get achNascentRitualDesc => 'Hit the daily goal 3 days in a row';

  @override
  String get achDailyRitualTitle => 'Daily Ritual';

  @override
  String get achDailyRitualDesc => 'Hit the daily goal 7 days in a row';

  @override
  String get achAnchoredHabitTitle => 'Anchored Habit';

  @override
  String get achAnchoredHabitDesc => 'Hit the daily goal 14 days in a row';

  @override
  String get achIronDisciplineTitle => 'Iron Discipline';

  @override
  String get achIronDisciplineDesc => 'Hit the daily goal 30 days in a row';

  @override
  String get achEarlyBirdTitle => 'Early Bird';

  @override
  String get achEarlyBirdDesc => 'Train before 8am on 5 different days';

  @override
  String get achNightOwlTitle => 'Night Owl';

  @override
  String get achNightOwlDesc => 'Train after 10pm on 5 different days';

  @override
  String get achSteadyHandsTitle => 'Steady Hands';

  @override
  String get achSteadyHandsDesc =>
      'No false inputs in a session at N≥4 with ≥80% accuracy';

  @override
  String get achPersistentTitle => 'Persistent';

  @override
  String get achPersistentDesc =>
      'Play 3 more sessions the same day after a failed one';

  @override
  String get achAudiophileTitle => 'Audiophile';

  @override
  String get achAudiophileDesc =>
      'Audio >80% but Position <70% in one session at N≥4';

  @override
  String get achEagleEyeTitle => 'Eagle Eye';

  @override
  String get achEagleEyeDesc =>
      'Position >80% but Audio <70% in one session at N≥4';

  @override
  String get achSynchronizedTitle => 'Synchronized';

  @override
  String get achSynchronizedDesc =>
      'Position and Audio within 5% at N≥4 (overall ≥60%)';

  @override
  String get achDualMasterTitle => 'Dual Master';

  @override
  String get achDualMasterDesc =>
      'Position and Audio >85% in one session at N≥4 (overall ≥60%)';

  @override
  String get achDualEliteTitle => 'Dual Elite';

  @override
  String get achDualEliteDesc =>
      'Position and Audio >90% in one session at N≥4 (overall ≥60%)';
}
