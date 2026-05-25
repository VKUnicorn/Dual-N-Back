import 'package:dual_n_back/features/achievements/application/achievement.dart';
import 'package:dual_n_back/features/achievements/domain/achievement_group.dart';
import 'package:dual_n_back/features/achievements/domain/achievement_helpers.dart';
import 'package:dual_n_back/features/achievements/domain/achievement_progress.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:flutter/material.dart';

/// All achievements known to the app. Order within a group is the order
/// they appear on screen. Groups themselves are ordered by their declaration
/// in [AchievementGroup].
///
/// Default icon `Icons.stars_rounded` per the project decision; per-entry
/// override is allowed via the `icon` parameter.
List<Achievement> buildAchievementsCatalog() => [
      // ──────────────── Milestones ────────────────
      Achievement(
        id: 'centurion',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achCenturionTitle,
        localizedDescription: (l) => l.achCenturionDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: ctx.sessions.length,
          target: 1000,
        ),
      ),
      Achievement(
        id: 'legend',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achLegendTitle,
        localizedDescription: (l) => l.achLegendDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: ctx.sessions.length,
          target: 2500,
        ),
      ),
      Achievement(
        id: 'immortal',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achImmortalTitle,
        localizedDescription: (l) => l.achImmortalDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: ctx.sessions.length,
          target: 5000,
        ),
      ),
      Achievement(
        id: 'ascended',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achAscendedTitle,
        localizedDescription: (l) => l.achAscendedDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: ctx.sessions.length,
          target: 10000,
        ),
      ),
      Achievement(
        id: 'practitioner',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achPractitionerTitle,
        localizedDescription: (l) => l.achPractitionerDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: _totalTrials(ctx),
          target: 5000,
        ),
      ),
      Achievement(
        id: 'trained',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achTrainedTitle,
        localizedDescription: (l) => l.achTrainedDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: _totalTrials(ctx),
          target: 10000,
        ),
      ),
      Achievement(
        id: 'seasoned',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achSeasonedTitle,
        localizedDescription: (l) => l.achSeasonedDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: _totalTrials(ctx),
          target: 50000,
        ),
      ),
      Achievement(
        id: 'trials_100k',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achTrials100kTitle,
        localizedDescription: (l) => l.achTrials100kDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: _totalTrials(ctx),
          target: 100000,
        ),
      ),
      Achievement(
        id: 'titan',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achTitanTitle,
        localizedDescription: (l) => l.achTitanDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: _totalTrials(ctx),
          target: 150000,
        ),
      ),
      Achievement(
        id: 'steel_resolve',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achSteelResolveTitle,
        localizedDescription: (l) => l.achSteelResolveDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current:
              AchievementHelpers.bestStreakEver(
                ctx.sessions, ctx.dailyGoal, ctx.restDays,),
          target: 60,
        ),
      ),
      Achievement(
        id: 'flawless_quarter',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achFlawlessQuarterTitle,
        localizedDescription: (l) => l.achFlawlessQuarterDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current:
              AchievementHelpers.bestStreakEver(
                ctx.sessions, ctx.dailyGoal, ctx.restDays,),
          target: 90,
        ),
      ),
      Achievement(
        id: 'flawless_half_year',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achFlawlessHalfYearTitle,
        localizedDescription: (l) => l.achFlawlessHalfYearDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current:
              AchievementHelpers.bestStreakEver(
                ctx.sessions, ctx.dailyGoal, ctx.restDays,),
          target: 180,
        ),
      ),
      Achievement(
        id: 'perfect_year',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achPerfectYearTitle,
        localizedDescription: (l) => l.achPerfectYearDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current:
              AchievementHelpers.bestStreakEver(
                ctx.sessions, ctx.dailyGoal, ctx.restDays,),
          target: 365,
        ),
      ),
      Achievement(
        id: 'veteran',
        group: AchievementGroup.milestones,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achVeteranTitle,
        localizedDescription: (l) => l.achVeteranDesc,
        evaluate: (ctx) {
          if (ctx.sessions.isEmpty) {
            return const AchievementProgress.tracked(current: 0, target: 365);
          }
          final earliest = ctx.sessions
              .map((s) => s.startedAt)
              .reduce((a, b) => a.isBefore(b) ? a : b);
          final days = ctx.now.difference(earliest).inDays;
          return AchievementProgress.tracked(
            current: days < 0 ? 0 : days,
            target: 365,
          );
        },
      ),

      // ──────────────── Performance ────────────────
      Achievement(
        id: 'sharp_brain',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achSharpBrainTitle,
        localizedDescription: (l) => l.achSharpBrainDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned:
              ctx.sessions.any((s) => s.n >= 3 && s.overallAccuracy >= 0.9),
        ),
      ),
      Achievement(
        id: 'muscular_brain',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achMuscularBrainTitle,
        localizedDescription: (l) => l.achMuscularBrainDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned:
              ctx.sessions.any((s) => s.n >= 4 && s.overallAccuracy >= 0.9),
        ),
      ),
      Achievement(
        id: 'olympic_brain',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achOlympicBrainTitle,
        localizedDescription: (l) => l.achOlympicBrainDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned:
              ctx.sessions.any((s) => s.n >= 5 && s.overallAccuracy >= 0.9),
        ),
      ),
      Achievement(
        id: 'genius_brain',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achGeniusBrainTitle,
        localizedDescription: (l) => l.achGeniusBrainDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned:
              ctx.sessions.any((s) => s.n >= 6 && s.overallAccuracy >= 0.9),
        ),
      ),
      Achievement(
        id: 'cognitive_elite',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achCognitiveEliteTitle,
        localizedDescription: (l) => l.achCognitiveEliteDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned:
              ctx.sessions.any((s) => s.n >= 7 && s.overallAccuracy >= 0.9),
        ),
      ),
      Achievement(
        id: 'cosmic_mind',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achCosmicMindTitle,
        localizedDescription: (l) => l.achCosmicMindDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned:
              ctx.sessions.any((s) => s.n >= 8 && s.overallAccuracy >= 0.9),
        ),
      ),
      Achievement(
        id: 'mythic_mind',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achMythicMindTitle,
        localizedDescription: (l) => l.achMythicMindDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned:
              ctx.sessions.any((s) => s.n >= 9 && s.overallAccuracy >= 0.9),
        ),
      ),
      Achievement(
        id: 'superhuman',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achSuperhumanTitle,
        localizedDescription: (l) => l.achSuperhumanDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned:
              ctx.sessions.any((s) => s.n >= 10 && s.overallAccuracy >= 0.9),
        ),
      ),
      Achievement(
        id: 'sniper',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achSniperTitle,
        localizedDescription: (l) => l.achSniperDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned:
              ctx.sessions.any((s) => s.n >= 4 && s.overallAccuracy >= 0.9),
        ),
      ),
      Achievement(
        id: 'surgical_precision',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achSurgicalPrecisionTitle,
        localizedDescription: (l) => l.achSurgicalPrecisionDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned:
              ctx.sessions.any((s) => s.n >= 4 && s.overallAccuracy >= 0.95),
        ),
      ),
      Achievement(
        id: 'laser',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achLaserTitle,
        localizedDescription: (l) => l.achLaserDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned:
              ctx.sessions.any((s) => s.n >= 5 && s.overallAccuracy >= 0.98),
        ),
      ),
      Achievement(
        id: 'untouchable',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achUntouchableTitle,
        localizedDescription: (l) => l.achUntouchableDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned: ctx.sessions.any((s) => s.n >= 5 && s.isPerfect),
        ),
      ),
      Achievement(
        id: 'dprime_master',
        group: AchievementGroup.performance,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achDprimeMasterTitle,
        localizedDescription: (l) => l.achDprimeMasterDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned: ctx.sessions.any((s) => s.n >= 4 && s.maxDPrime > 3.0),
        ),
      ),

      // ──────────────── Consistency ────────────────
      Achievement(
        id: 'awakened_neuron',
        group: AchievementGroup.consistency,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achAwakenedNeuronTitle,
        localizedDescription: (l) => l.achAwakenedNeuronDesc,
        evaluate: (ctx) =>
            AchievementProgress.binary(earned: ctx.sessions.isNotEmpty),
      ),
      Achievement(
        id: 'foundation',
        group: AchievementGroup.consistency,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achFoundationTitle,
        localizedDescription: (l) => l.achFoundationDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: ctx.sessions.length,
          target: 50,
        ),
      ),
      Achievement(
        id: 'pillar_bronze',
        group: AchievementGroup.consistency,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achPillarBronzeTitle,
        localizedDescription: (l) => l.achPillarBronzeDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: ctx.sessions.length,
          target: 100,
        ),
      ),
      Achievement(
        id: 'pillar_silver',
        group: AchievementGroup.consistency,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achPillarSilverTitle,
        localizedDescription: (l) => l.achPillarSilverDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: ctx.sessions.length,
          target: 250,
        ),
      ),
      Achievement(
        id: 'pillar_gold',
        group: AchievementGroup.consistency,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achPillarGoldTitle,
        localizedDescription: (l) => l.achPillarGoldDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: ctx.sessions.length,
          target: 500,
        ),
      ),
      Achievement(
        id: 'first_day',
        group: AchievementGroup.consistency,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achFirstDayTitle,
        localizedDescription: (l) => l.achFirstDayDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned: AchievementHelpers.bestStreakEver(
                ctx.sessions, ctx.dailyGoal, ctx.restDays,) >=
              1,
        ),
      ),
      Achievement(
        id: 'nascent_ritual',
        group: AchievementGroup.consistency,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achNascentRitualTitle,
        localizedDescription: (l) => l.achNascentRitualDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current:
              AchievementHelpers.bestStreakEver(
                ctx.sessions, ctx.dailyGoal, ctx.restDays,),
          target: 3,
        ),
      ),
      Achievement(
        id: 'daily_ritual',
        group: AchievementGroup.consistency,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achDailyRitualTitle,
        localizedDescription: (l) => l.achDailyRitualDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current:
              AchievementHelpers.bestStreakEver(
                ctx.sessions, ctx.dailyGoal, ctx.restDays,),
          target: 7,
        ),
      ),
      Achievement(
        id: 'anchored_habit',
        group: AchievementGroup.consistency,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achAnchoredHabitTitle,
        localizedDescription: (l) => l.achAnchoredHabitDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current:
              AchievementHelpers.bestStreakEver(
                ctx.sessions, ctx.dailyGoal, ctx.restDays,),
          target: 14,
        ),
      ),
      Achievement(
        id: 'iron_discipline',
        group: AchievementGroup.consistency,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achIronDisciplineTitle,
        localizedDescription: (l) => l.achIronDisciplineDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current:
              AchievementHelpers.bestStreakEver(
                ctx.sessions, ctx.dailyGoal, ctx.restDays,),
          target: 30,
        ),
      ),
      Achievement(
        id: 'early_bird',
        group: AchievementGroup.consistency,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achEarlyBirdTitle,
        localizedDescription: (l) => l.achEarlyBirdDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: AchievementHelpers.daysWithMatchingSession(
            ctx.sessions,
            (s) => s.startedAt.hour < 8,
          ),
          target: 5,
        ),
      ),
      Achievement(
        id: 'night_owl',
        group: AchievementGroup.consistency,
        icon: Icons.stars_rounded,
        tracksProgress: true,
        localizedTitle: (l) => l.achNightOwlTitle,
        localizedDescription: (l) => l.achNightOwlDesc,
        evaluate: (ctx) => AchievementProgress.tracked(
          current: AchievementHelpers.daysWithMatchingSession(
            ctx.sessions,
            (s) => s.startedAt.hour >= 22,
          ),
          target: 5,
        ),
      ),

      // ──────────────── Resilience ────────────────
      Achievement(
        id: 'steady_hands',
        group: AchievementGroup.resilience,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achSteadyHandsTitle,
        localizedDescription: (l) => l.achSteadyHandsDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned: ctx.sessions.any(
            (s) =>
                s.n >= 4 &&
                s.overallAccuracy >= 0.8 &&
                s.perChannel.values.every((cs) => cs.falseAlarms == 0),
          ),
        ),
      ),
      Achievement(
        id: 'persistent',
        group: AchievementGroup.resilience,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achPersistentTitle,
        localizedDescription: (l) => l.achPersistentDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned: AchievementHelpers.hasComebackDay(ctx.sessions),
        ),
      ),

      // ──────────────── Exploration ────────────────
      Achievement(
        id: 'audiophile',
        group: AchievementGroup.exploration,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achAudiophileTitle,
        localizedDescription: (l) => l.achAudiophileDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned: ctx.sessions.any((s) {
            if (s.n < 4) return false;
            final pos = s.perChannel[ChannelType.position];
            final aud = s.perChannel[ChannelType.audio];
            if (pos == null || aud == null) return false;
            return aud.accuracy > 0.8 && pos.accuracy < 0.7;
          }),
        ),
      ),
      Achievement(
        id: 'eagle_eye',
        group: AchievementGroup.exploration,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achEagleEyeTitle,
        localizedDescription: (l) => l.achEagleEyeDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned: ctx.sessions.any((s) {
            if (s.n < 4) return false;
            final pos = s.perChannel[ChannelType.position];
            final aud = s.perChannel[ChannelType.audio];
            if (pos == null || aud == null) return false;
            return pos.accuracy > 0.8 && aud.accuracy < 0.7;
          }),
        ),
      ),
      Achievement(
        id: 'synchronized',
        group: AchievementGroup.exploration,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achSynchronizedTitle,
        localizedDescription: (l) => l.achSynchronizedDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned: ctx.sessions.any((s) {
            if (s.n < 4) return false;
            final pos = s.perChannel[ChannelType.position];
            final aud = s.perChannel[ChannelType.audio];
            if (pos == null || aud == null) return false;
            return s.overallAccuracy >= 0.6 &&
                (pos.accuracy - aud.accuracy).abs() <= 0.05;
          }),
        ),
      ),
      Achievement(
        id: 'dual_master',
        group: AchievementGroup.exploration,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achDualMasterTitle,
        localizedDescription: (l) => l.achDualMasterDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned: ctx.sessions.any((s) {
            if (s.n < 4) return false;
            final pos = s.perChannel[ChannelType.position];
            final aud = s.perChannel[ChannelType.audio];
            if (pos == null || aud == null) return false;
            return s.overallAccuracy >= 0.6 &&
                pos.accuracy > 0.85 &&
                aud.accuracy > 0.85;
          }),
        ),
      ),
      Achievement(
        id: 'dual_elite',
        group: AchievementGroup.exploration,
        icon: Icons.stars_rounded,
        tracksProgress: false,
        localizedTitle: (l) => l.achDualEliteTitle,
        localizedDescription: (l) => l.achDualEliteDesc,
        evaluate: (ctx) => AchievementProgress.binary(
          earned: ctx.sessions.any((s) {
            if (s.n < 4) return false;
            final pos = s.perChannel[ChannelType.position];
            final aud = s.perChannel[ChannelType.audio];
            if (pos == null || aud == null) return false;
            return s.overallAccuracy >= 0.6 &&
                pos.accuracy > 0.9 &&
                aud.accuracy > 0.9;
          }),
        ),
      ),
    ];

int _totalTrials(EvalContext ctx) =>
    ctx.sessions.fold<int>(0, (a, s) => a + s.totalTrials);
