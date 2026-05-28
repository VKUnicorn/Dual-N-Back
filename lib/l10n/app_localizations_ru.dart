// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Dual N-Back';

  @override
  String get appTagline => 'Тренажёр рабочей памяти';

  @override
  String get homeStartButton => 'Начать сессию';

  @override
  String get homeInfoButton => 'Информация';

  @override
  String get homeStatisticsButton => 'Статистика';

  @override
  String get homeSettingsButton => 'Настройки';

  @override
  String get infoTitle => 'Информация';

  @override
  String get infoSectionWhatIs => 'Что такое N-back?';

  @override
  String get infoSectionWhatIsBody =>
      'N-back — упражнение для рабочей памяти. На экране по очереди появляются подсказки (буква, цвет, позиция в сетке и так далее), и твоя задача — заметить, совпадает ли текущая подсказка с той, что была N шагов назад. Чем больше N, тем сложнее удерживать последовательность в голове.\n\nМожно тренировать один канал (Single — например, только позицию), два сразу (Dual — самый известный вариант, обычно позиция + звук) или все четыре (Quad). Каждый канал проверяется отдельно: совпадение позиции не означает совпадение звука.';

  @override
  String get infoSectionJaeggi => 'Исследование Jaeggi';

  @override
  String get infoSectionJaeggiBody =>
      'В 2008 году учёные под руководством Jaeggi опубликовали исследование, в котором примерно 19 дней ежедневных тренировок Dual N-back улучшили текучий интеллект (Gf) — способность решать новые, незнакомые задачи. С тех пор N-back стал популярным «тренажёром для мозга».\n\nНастройки по умолчанию в этом приложении взяты из того же исследования: 20 трайлов в сессии, стимул показывается 500 мс, пауза между стимулами 2500 мс, совпадения попадаются примерно в 30% случаев. Если включить адаптивный режим, уровень N будет повышаться при точности ≥90% по каждому каналу и понижаться при ≤70%.';

  @override
  String get infoSectionMetrics => 'Метрики результата';

  @override
  String get infoMetricHits =>
      'Hits — ты нажал «совпадение» там, где совпадение действительно было.';

  @override
  String get infoMetricMisses =>
      'Misses — совпадение было, но ты его пропустил.';

  @override
  String get infoMetricFalseAlarms =>
      'False + (ложная тревога) — ты нажал «совпадение», но на самом деле его не было.';

  @override
  String get infoMetricCorrectRejections =>
      'Correct − (правильный пропуск) — совпадения не было, и ты правильно не стал нажимать.';

  @override
  String get infoMetricAccuracy =>
      'Accuracy (точность) — какая доля решений оказалась правильной. Считается как hits ÷ (hits + misses + false alarms). Падает и от пропущенных совпадений, и от ложных нажатий.';

  @override
  String get infoMetricDPrime =>
      'd′ (d-прайм) — показывает, насколько хорошо ты отличаешь настоящие совпадения от их отсутствия. Чем выше, тем чётче ты «видишь» совпадения. Это более честный показатель, чем accuracy: его не обманешь, если просто часто или редко жать кнопку.';

  @override
  String get infoSectionTips => 'Советы по тренировке';

  @override
  String get infoSectionTipsBody =>
      '• Тренируйся каждый день — короткая сессия каждый день полезнее, чем редкие долгие.\n• Не пытайся проговаривать буквы и позиции вслух — пусть память работает сама.\n• Если результат не растёт несколько дней — это нормально, мозг учится не сразу. Просто продолжай.\n• Хочешь, чтобы уровень N подстраивался автоматически под твой прогресс? Включи адаптивный режим Jaeggi в настройках.';

  @override
  String get channelPosition => 'Позиция';

  @override
  String get channelAudio => 'Звук';

  @override
  String get channelColor => 'Цвет';

  @override
  String get channelShape => 'Форма';

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
  String get settingsSectionColors => 'Цвета';

  @override
  String get settingsColors => 'Цвета';

  @override
  String get settingsColorsHint => 'Тап по цвету откроет окно выбора цвета.';

  @override
  String get settingsColorPickerTitle => 'Выбор цвета';

  @override
  String get settingsColorPickerHue => 'Оттенок';

  @override
  String get settingsColorPickerSaturation => 'Насыщенность';

  @override
  String get settingsColorPickerValue => 'Яркость';

  @override
  String gameInstructions(int n) {
    return 'Нажимай соответствующую кнопку канала, когда стимул совпадает с тем, что был N, то есть $n шагов назад.';
  }

  @override
  String get gameChannelsLabel => 'Каналы';

  @override
  String gameLevelLabel(int n) {
    return 'Уровень N: $n';
  }

  @override
  String gameInitialLevelLabel(int n) {
    return 'Начальный уровень N: $n';
  }

  @override
  String get gameStartButton => 'Старт';

  @override
  String get gameStartHintNoChannels => 'Выбери хотя бы один канал';

  @override
  String get gameSoundOffWarning => 'На телефоне выключен звук';

  @override
  String gameSoundLowWarning(int percent) {
    return 'Тихая громкость звука: $percent%';
  }

  @override
  String get pauseTooltip => 'Пауза';

  @override
  String get pauseDialogTitle => 'Пауза';

  @override
  String get pauseDialogContent => 'Сессия приостановлена.';

  @override
  String get pauseDialogResume => 'Продолжить';

  @override
  String get pauseDialogHome => 'Главная';

  @override
  String get resultTitle => 'Сессия завершена';

  @override
  String resultAppBarTitle(int n) {
    return 'N=$n';
  }

  @override
  String get resultLevelUpLabel => 'Уровень N повышен:';

  @override
  String get resultLevelDownLabel => 'Уровень N понижен:';

  @override
  String resultLevelHold(int n) {
    return 'Уровень N сохранён: $n';
  }

  @override
  String get resultAccuracyLabel => 'Точность';

  @override
  String get resultClose => 'Закрыть';

  @override
  String get resultAgain => 'Ещё раз';

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
  String get settingsTitle => 'Настройки';

  @override
  String get settingsResetTooltip => 'Сбросить';

  @override
  String get settingsResetGroupTooltip =>
      'Сбросить эту группу к значениям по умолчанию';

  @override
  String get settingsSectionDefaultChannels =>
      'Каналы по умолчанию и расположение кнопок';

  @override
  String get settingsLayoutHint =>
      'Нажми, чтобы включить или выключить канал. Зажми и перетащи на другую ячейку, чтобы поменять местами.';

  @override
  String get settingsSectionLevel => 'Уровень N';

  @override
  String get settingsSectionTimings => 'Тайминги';

  @override
  String get settingsInitialN => 'Начальный N';

  @override
  String get settingsRangeN => 'Диапазон N (мин — макс)';

  @override
  String settingsRangeNValue(int min, int max) {
    return '$min — $max';
  }

  @override
  String get settingsAdaptive => 'Адаптивный режим';

  @override
  String settingsAdaptiveSubtitle(int advance, int regress) {
    return 'Повышать N при ≥$advance% точности, понижать при ≤$regress%';
  }

  @override
  String get settingsAdaptiveThresholds => 'Пороги точности';

  @override
  String settingsAdaptiveThresholdsValue(int regress, int advance) {
    return '$regress% / $advance%';
  }

  @override
  String get settingsMatchProbability => 'Совпадение канала';

  @override
  String get settingsMatchProbabilityJitter => 'Добавленная случайность';

  @override
  String settingsMatchProbabilityHint(int matches, int trials) {
    return 'Во время игровой сессии по каждому каналу будет $matches совпадений, случайно распределённых по $trials trials.';
  }

  @override
  String settingsMatchProbabilityHintJitter(
    int matches,
    int jitter,
    int trials,
  ) {
    return 'Во время игровой сессии по каждому каналу будет $matches±$jitter совпадений, случайно распределённых по $trials trials.';
  }

  @override
  String get settingsMatchProbabilityHintMinMatch =>
      'Минимум одно совпадение на канал.';

  @override
  String settingsPercent(int value) {
    return '$value%';
  }

  @override
  String get settingsTrialsPerSession => 'Trial\'ов в сессии';

  @override
  String get settingsStimulusDuration => 'Длительность стимула';

  @override
  String get settingsStimulusFade => 'Время появления стимула';

  @override
  String get settingsIsi => 'Интервал между стимулами (ISI)';

  @override
  String settingsMs(int ms) {
    return '$ms мс';
  }

  @override
  String get settingsEstimatedDuration => 'Расчётная длительность сессии';

  @override
  String settingsSeconds(int seconds) {
    return '$seconds сек';
  }

  @override
  String settingsMinutesSeconds(int minutes, int seconds) {
    return '$minutes мин $seconds сек';
  }

  @override
  String get settingsSectionGridStyle => 'Стили сетки';

  @override
  String get settingsGridStyleTile => 'Плитка';

  @override
  String get settingsGridStyleClassic => 'Классический';

  @override
  String get settingsShowFixationCross => 'Показывать крест фиксации в центре';

  @override
  String get settingsAllowCenterPosition =>
      'Добавить девятый вариант стимула позиции в центре сетки';

  @override
  String get settingsAllowCenterPositionHint =>
      'В оригинальном тесте Jaeggi стимул не появляется в центре, но вы можете включить это при необходимости. Это слегка увеличит сложность запоминания стимула позиции так как будет девять возможных вариантов, а не восемь.';

  @override
  String get settingsSectionSound => 'Звук';

  @override
  String get settingsVolume => 'Громкость';

  @override
  String get settingsVoice => 'Голос';

  @override
  String get settingsVoiceFemale => 'Женский';

  @override
  String get settingsVoiceMale => 'Мужской';

  @override
  String get settingsLetters => 'Буквы';

  @override
  String get settingsLettersHint =>
      'Рекомендуется выбрать восемь букв, минимум четыре.';

  @override
  String get settingsSectionFeedback => 'Отдача';

  @override
  String get settingsFeedbackVisualPress =>
      'Визуальная отдача цвета кнопок при совпадениях';

  @override
  String get settingsFeedbackAudioPress =>
      'Звуковая отдача цвета кнопок при ошибке совпадения';

  @override
  String get settingsFeedbackVisualMiss =>
      'Визуальная отдача цвета кнопок при ошибочном пропуске совпадения';

  @override
  String get settingsFeedbackAudioMiss =>
      'Звуковая отдача при ошибочном пропуске совпадения';

  @override
  String get settingsSectionDailyGoal => 'Дневная цель сессий';

  @override
  String get settingsDailyGoal => 'Сессий в день';

  @override
  String get settingsSectionNotifications => 'Уведомления';

  @override
  String get settingsNotificationsEnabled => 'Показывать уведомления';

  @override
  String get settingsNotificationTime => 'Время уведомлений';

  @override
  String get settingsNotificationsRestDaysHint =>
      'Уведомления не будут показаны в дни отдыха, если они выбраны.';

  @override
  String get notificationTitle => 'Пора потренироваться!';

  @override
  String get notificationBody => 'Ежедневная сессия N-back ждёт тебя.';

  @override
  String get settingsRestDays => 'Дни отдыха';

  @override
  String get settingsRestDaysHint =>
      'Дни отдыха не учитываются в расчёте количества дней, в которых мы достигали дневную цель игровых сессий.';

  @override
  String homeDailyProgress(int count, int goal) {
    return '$count/$goal';
  }

  @override
  String get homeStreakTooltip =>
      'Сколько дней подряд поддерживали текущую цель игровых сессий';

  @override
  String get homeRestDayLabel => 'День отдыха';

  @override
  String get homeDailyGoalTooltip => 'Прогресс дневной цели игровых сессий';

  @override
  String get settingsSectionLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'Системный';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageRu => 'Русский';

  @override
  String get settingsSectionTheme => 'Тема';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsResetTitle => 'Сбросить настройки?';

  @override
  String get settingsResetContent =>
      'Все значения вернутся к значениям по умолчанию.';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonReset => 'Сбросить';

  @override
  String get commonClear => 'Очистить';

  @override
  String get statisticsTitle => 'Статистика';

  @override
  String get statisticsClearTooltip => 'Очистить историю';

  @override
  String get statisticsClearTitle => 'Очистить историю?';

  @override
  String get statisticsClearContent => 'Это действие нельзя отменить.';

  @override
  String get statisticsExportTooltip => 'Экспорт истории в файл';

  @override
  String get statisticsImportTooltip => 'Импорт истории из файла';

  @override
  String get statisticsExportDialogTitle => 'Сохранить резервную копию';

  @override
  String get statisticsExportEmpty => 'Нечего экспортировать — история пуста.';

  @override
  String statisticsExportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сессии',
      many: '$count сессий',
      few: '$count сессии',
      one: '$count сессия',
    );
    return 'Экспортировано $_temp0.';
  }

  @override
  String statisticsExportError(String message) {
    return 'Ошибка экспорта: $message';
  }

  @override
  String get statisticsImportTitle => 'Заменить историю?';

  @override
  String statisticsImportContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сессии',
      many: '$count сессий',
      few: '$count сессии',
      one: '$count сессия',
      zero: 'пока нет ни одной',
    );
    return 'Все текущие сессии ($_temp0) будут безвозвратно удалены и заменены сессиями из выбранного файла. Это действие нельзя отменить.';
  }

  @override
  String get statisticsImportConfirm => 'Заменить';

  @override
  String statisticsImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сессии',
      many: '$count сессий',
      few: '$count сессии',
      one: '$count сессия',
    );
    return 'Импортировано $_temp0.';
  }

  @override
  String statisticsImportFormatError(String message) {
    return 'Файл резервной копии повреждён: $message';
  }

  @override
  String statisticsImportError(String message) {
    return 'Ошибка импорта: $message';
  }

  @override
  String get statisticsEmptyTitle => 'История пока пуста';

  @override
  String get statisticsEmptySubtitle =>
      'Заверши первую сессию — её результаты появятся здесь.';

  @override
  String statisticsSessionsCount(int count) {
    return 'Сессии ($count)';
  }

  @override
  String get statisticsPeriodDay => 'День';

  @override
  String get statisticsPeriodWeek => 'Неделя';

  @override
  String get statisticsPeriodMonth => 'Месяц';

  @override
  String get statisticsPeriodYear => 'Год';

  @override
  String get statisticsCursorCurrentWeek => 'Текущая неделя';

  @override
  String statisticsCursorWeeksAgo(int count, int year) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count недели назад, $year',
      many: '$count недель назад, $year',
      few: '$count недели назад, $year',
      one: '$count неделя назад, $year',
    );
    return '$_temp0';
  }

  @override
  String statisticsCursorWeeksAhead(int count, int year) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Через $count недели, $year',
      many: 'Через $count недель, $year',
      few: 'Через $count недели, $year',
      one: 'Через $count неделю, $year',
    );
    return '$_temp0';
  }

  @override
  String statisticsCursorYear(int year) {
    return '$year год';
  }

  @override
  String get statisticsChartAvgAccuracy => 'Средняя точность, %';

  @override
  String get statisticsChartMaxN => 'Максимальный N';

  @override
  String get statisticsChartDprime => 'Среднее d′';

  @override
  String get statisticsChartChannelAccuracy => 'Точность по каналам, %';

  @override
  String get statisticsChartHeatmap => 'Активность';

  @override
  String get statisticsChartNDistribution => 'Сессии по уровню N';

  @override
  String get statisticsSummaryTitle => 'Сводка за период';

  @override
  String get statisticsSummaryBestSession => 'Лучшая сессия';

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
  String get statisticsSummaryTotalTrials => 'Всего trial\'ов';

  @override
  String get statisticsSummaryTrainingTime => 'Время тренировки';

  @override
  String get statisticsSummaryDailyGoal => 'Дневная цель';

  @override
  String statisticsSummaryDailyGoalValue(int achieved, int total, int percent) {
    return '$achieved / $total ($percent%)';
  }

  @override
  String statisticsSummaryHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String statisticsSummaryMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get statisticsSummaryNone => '—';

  @override
  String statisticsSessionPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сессии',
      many: '$count сессий',
      few: '$count сессии',
      one: '$count сессия',
      zero: '0 сессий',
    );
    return '$_temp0';
  }

  @override
  String get statisticsSessionOverallLabel => 'Общая точность';

  @override
  String statisticsSessionOverallValue(int hits, int engaged, int percent) {
    return '$hits/$engaged = $percent%';
  }

  @override
  String get statisticsSessionOverallFormulaHint =>
      '= сумма hits по всем каналам / сумма engaged по всем каналам (engaged = hits + misses + false +; correct − не учитывается)';

  @override
  String get statisticsSessionAdaptiveChangeLabel => 'Адаптация N:';

  @override
  String get statisticsSessionDeleteTooltip => 'Удалить сессию';

  @override
  String get statisticsSessionDeleteTitle => 'Удалить эту сессию?';

  @override
  String get statisticsSessionDeleteContent => 'Это действие нельзя отменить.';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get statisticsDebugFillButton =>
      'Отладка: заполнить 2 года случайными данными';

  @override
  String get statisticsDebugFillProgress => 'Генерация данных…';

  @override
  String statisticsDebugFillDone(int count) {
    return 'Создано $count сессий';
  }

  @override
  String get statisticsChartN => 'Уровень N';

  @override
  String get statisticsChartAccuracy => 'Общая точность, %';

  @override
  String statisticsTrialCountSuffix(int count) {
    return '$count trial';
  }

  @override
  String statisticsErrorPrefix(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get homeAchievementsButton => 'Достижения';

  @override
  String get achievementsTitle => 'Достижения';

  @override
  String achProgressLabel(int current, int target) {
    return '$current / $target';
  }

  @override
  String get achEarnedBadge => 'Получено';

  @override
  String get resultDailyGoalReached => 'Дневная цель достигнута!';

  @override
  String resultAchievementsUnlockedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Открыто $count достижения!',
      many: 'Открыто $count достижений!',
      few: 'Открыто $count достижения!',
      one: 'Открыто достижение!',
    );
    return '$_temp0';
  }

  @override
  String get achGroupMilestones => 'Вехи';

  @override
  String get achGroupPerformance => 'Результативность';

  @override
  String get achGroupConsistency => 'Постоянство';

  @override
  String get achGroupResilience => 'Стойкость';

  @override
  String get achGroupExploration => 'Исследование';

  @override
  String get achCenturionTitle => 'Центурион';

  @override
  String get achCenturionDesc => 'Заверши 1 000 сессий';

  @override
  String get achLegendTitle => 'Легенда';

  @override
  String get achLegendDesc => 'Заверши 2 500 сессий';

  @override
  String get achImmortalTitle => 'Бессмертный';

  @override
  String get achImmortalDesc => 'Заверши 5 000 сессий';

  @override
  String get achAscendedTitle => 'Вознесённый';

  @override
  String get achAscendedDesc => 'Заверши 10 000 сессий';

  @override
  String get achPractitionerTitle => 'Тренирующийся';

  @override
  String get achPractitionerDesc => 'Сыграй 5 000 trial\'ов в сумме';

  @override
  String get achTrainedTitle => 'Натренированный';

  @override
  String get achTrainedDesc => 'Сыграй 10 000 trial\'ов в сумме';

  @override
  String get achSeasonedTitle => 'Опытный';

  @override
  String get achSeasonedDesc => 'Сыграй 50 000 trial\'ов в сумме';

  @override
  String get achTrials100kTitle => '100 000 Trial\'ов';

  @override
  String get achTrials100kDesc => 'Сыграй 100 000 trial\'ов в сумме';

  @override
  String get achTitanTitle => 'Титан';

  @override
  String get achTitanDesc => 'Сыграй 150 000 trial\'ов в сумме';

  @override
  String get achSteelResolveTitle => 'Стальная воля';

  @override
  String get achSteelResolveDesc => 'Достигай дневной цели 60 дней подряд';

  @override
  String get achFlawlessQuarterTitle => 'Безупречный квартал';

  @override
  String get achFlawlessQuarterDesc => 'Достигай дневной цели 90 дней подряд';

  @override
  String get achFlawlessHalfYearTitle => 'Безупречное полугодие';

  @override
  String get achFlawlessHalfYearDesc => 'Достигай дневной цели 180 дней подряд';

  @override
  String get achPerfectYearTitle => 'Идеальный год';

  @override
  String get achPerfectYearDesc => 'Достигай дневной цели 365 дней подряд';

  @override
  String get achVeteranTitle => 'Ветеран';

  @override
  String get achVeteranDesc => 'Используй приложение целый год';

  @override
  String get achSharpBrainTitle => 'Острый ум';

  @override
  String get achSharpBrainDesc => 'Возьми N≥3 с точностью ≥90%';

  @override
  String get achMuscularBrainTitle => 'Мощный ум';

  @override
  String get achMuscularBrainDesc => 'Возьми N≥4 с точностью ≥90%';

  @override
  String get achOlympicBrainTitle => 'Олимпийский ум';

  @override
  String get achOlympicBrainDesc => 'Возьми N≥5 с точностью ≥90%';

  @override
  String get achGeniusBrainTitle => 'Гениальный ум';

  @override
  String get achGeniusBrainDesc => 'Возьми N≥6 с точностью ≥90%';

  @override
  String get achCognitiveEliteTitle => 'Когнитивная элита';

  @override
  String get achCognitiveEliteDesc => 'Возьми N≥7 с точностью ≥90%';

  @override
  String get achCosmicMindTitle => 'Космический ум';

  @override
  String get achCosmicMindDesc => 'Возьми N≥8 с точностью ≥90%';

  @override
  String get achMythicMindTitle => 'Мифический ум';

  @override
  String get achMythicMindDesc => 'Возьми N≥9 с точностью ≥90%';

  @override
  String get achSuperhumanTitle => 'Сверхчеловек';

  @override
  String get achSuperhumanDesc => 'Возьми N≥10 с точностью ≥90%';

  @override
  String get achSniperTitle => 'Снайпер';

  @override
  String get achSniperDesc => 'Общая точность ≥90% при N≥4';

  @override
  String get achSurgicalPrecisionTitle => 'Хирургическая точность';

  @override
  String get achSurgicalPrecisionDesc => 'Общая точность ≥95% при N≥4';

  @override
  String get achLaserTitle => 'Лазер';

  @override
  String get achLaserDesc => 'Общая точность ≥98% при N≥5';

  @override
  String get achUntouchableTitle => 'Неприкасаемый';

  @override
  String get achUntouchableDesc => 'Идеальная сессия (без ошибок) при N≥5';

  @override
  String get achDprimeMasterTitle => 'Мастер d′';

  @override
  String get achDprimeMasterDesc => 'Достигни d′ > 3.0 за сессию при N≥4';

  @override
  String get achAwakenedNeuronTitle => 'Пробуждённый нейрон';

  @override
  String get achAwakenedNeuronDesc => 'Заверши свою первую сессию';

  @override
  String get achFoundationTitle => 'Фундамент';

  @override
  String get achFoundationDesc => 'Заверши 50 сессий';

  @override
  String get achPillarBronzeTitle => 'Опора (бронза)';

  @override
  String get achPillarBronzeDesc => 'Заверши 100 сессий';

  @override
  String get achPillarSilverTitle => 'Опора (серебро)';

  @override
  String get achPillarSilverDesc => 'Заверши 250 сессий';

  @override
  String get achPillarGoldTitle => 'Опора (золото)';

  @override
  String get achPillarGoldDesc => 'Заверши 500 сессий';

  @override
  String get achFirstDayTitle => 'Первый день';

  @override
  String get achFirstDayDesc => 'Достигни дневной цели';

  @override
  String get achNascentRitualTitle => 'Зарождающийся ритуал';

  @override
  String get achNascentRitualDesc => 'Достигай дневной цели 3 дня подряд';

  @override
  String get achDailyRitualTitle => 'Ежедневный ритуал';

  @override
  String get achDailyRitualDesc => 'Достигай дневной цели 7 дней подряд';

  @override
  String get achAnchoredHabitTitle => 'Укоренённая привычка';

  @override
  String get achAnchoredHabitDesc => 'Достигай дневной цели 14 дней подряд';

  @override
  String get achIronDisciplineTitle => 'Железная дисциплина';

  @override
  String get achIronDisciplineDesc => 'Достигай дневной цели 30 дней подряд';

  @override
  String get achEarlyBirdTitle => 'Ранняя пташка';

  @override
  String get achEarlyBirdDesc => 'Тренируйся до 8 утра в 5 разных дней';

  @override
  String get achNightOwlTitle => 'Сова';

  @override
  String get achNightOwlDesc => 'Тренируйся после 22:00 в 5 разных дней';

  @override
  String get achSteadyHandsTitle => 'Твёрдая рука';

  @override
  String get achSteadyHandsDesc =>
      'Ни одной ложной тревоги в сессии при N≥4 и точности ≥80%';

  @override
  String get achPersistentTitle => 'Упорство';

  @override
  String get achPersistentDesc =>
      'Сыграй ещё 3 сессии в тот же день после неудачной';

  @override
  String get achAudiophileTitle => 'Аудиофил';

  @override
  String get achAudiophileDesc =>
      'Звук >80%, но позиция <70% в одной сессии при N≥4';

  @override
  String get achEagleEyeTitle => 'Орлиный глаз';

  @override
  String get achEagleEyeDesc =>
      'Позиция >80%, но звук <70% в одной сессии при N≥4';

  @override
  String get achSynchronizedTitle => 'Синхронизация';

  @override
  String get achSynchronizedDesc =>
      'Позиция и звук в пределах 5% при N≥4 (общая ≥60%)';

  @override
  String get achDualMasterTitle => 'Дуал-мастер';

  @override
  String get achDualMasterDesc =>
      'Позиция и звук >85% в одной сессии при N≥4 (общая ≥60%)';

  @override
  String get achDualEliteTitle => 'Дуал-элита';

  @override
  String get achDualEliteDesc =>
      'Позиция и звук >90% в одной сессии при N≥4 (общая ≥60%)';
}
