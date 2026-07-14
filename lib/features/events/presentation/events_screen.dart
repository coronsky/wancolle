import 'package:dog_friend_manager/core/utils/date_utils.dart';
import 'package:dog_friend_manager/data/models/dog_profile.dart';
import 'package:dog_friend_manager/features/dogs/viewmodels/dogs_controller.dart';
import 'package:dog_friend_manager/shared/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduledDogEvent {
  const ScheduledDogEvent({
    required this.title,
    required this.date,
    required this.place,
    required this.category,
    required this.region,
    required this.attendeeDogIds,
    required this.items,
    this.memo = '',
  });

  final String title;
  final DateTime date;
  final String place;
  final String category;
  final String region;
  final List<String> attendeeDogIds;
  final List<String> items;
  final String memo;
}

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dogs = ref.watch(dogsControllerProvider).valueOrNull ?? [];
    final now = DateTime.now();
    final events = _sampleEvents;
    final monthDays = _buildMonthDays(now);

    return ListView(
      key: const ValueKey('events'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Text('イベントスケジュール', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          '会う予定、誕生日、持ち物をひとまとめに管理できます。',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('${now.year}年 ${now.month}月', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  const Icon(Icons.calendar_month_rounded),
                ],
              ),
              const SizedBox(height: 14),
              const _WeekHeader(),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: monthDays.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final day = monthDays[index];
                  final dayEvents = events.where((event) => _isSameDay(event.date, day)).toList();
                  final isToday = _isSameDay(day, now);

                  return Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${day.day}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (dayEvents.isNotEmpty)
                          ...dayEvents.take(2).map(
                            (event) => Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _categoryColor(event.category).withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  event.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeader('今後のイベント'),
        const SizedBox(height: 12),
        ...events.map(
          (event) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _EventCard(
              event: event,
              dogs: dogs,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SectionHeader('おすすめ機能'),
        const SizedBox(height: 12),
        const GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FeatureLine('参加予定の犬友チェック', 'イベントごとに会えそうな子を事前に整理できます。'),
              _FeatureLine('再会リマインド通知', '3か月・6か月会っていない犬友を自動でお知らせ。'),
              _FeatureLine('イベント別アルバム', 'DOGFES や旅行ごとに写真と思い出をまとめられます。'),
              _FeatureLine('持ち物チェック', 'おやつ、水、名刺、マナー袋を忘れにくくします。'),
              _FeatureLine('チェックイン記録', '現地で誰に会えたかをその場で残せます。'),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader();

  @override
  Widget build(BuildContext context) {
    const labels = ['月', '火', '水', '木', '金', '土', '日'];
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.dogs,
  });

  final ScheduledDogEvent event;
  final List<DogProfile> dogs;

  @override
  Widget build(BuildContext context) {
    final attendees = dogs
        .where((dog) => event.attendeeDogIds.contains(dog.id))
        .map((dog) => dog.name)
        .toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _categoryColor(event.category).withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(event.category),
              ),
              const Spacer(),
              Text(AppDateUtils.formatDate(event.date)),
            ],
          ),
          const SizedBox(height: 12),
          Text(event.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${event.place}  •  ${event.region}'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: attendees
                .map(
                  (name) => Chip(
                    avatar: const Icon(Icons.pets_rounded, size: 16),
                    label: Text(name),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text('持ち物', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: event.items
                .map(
                  (item) => Chip(
                    label: Text(item),
                    avatar: const Icon(Icons.checkroom_rounded, size: 16),
                  ),
                )
                .toList(),
          ),
          if (event.memo.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('メモ: ${event.memo}'),
          ],
        ],
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.auto_awesome_rounded, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '$title\n',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<DateTime> _buildMonthDays(DateTime focus) {
  final firstDay = DateTime(focus.year, focus.month, 1);
  final lastDay = DateTime(focus.year, focus.month + 1, 0);
  final leading = firstDay.weekday - 1;
  final total = leading + lastDay.day;
  final cells = total <= 35 ? 35 : 42;

  return List.generate(
    cells,
    (index) => firstDay.subtract(Duration(days: leading)).add(Duration(days: index)),
  );
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

Color _categoryColor(String category) {
  switch (category) {
    case '旅行':
      return const Color(0xFFAABDD6);
    case 'オフ会':
      return const Color(0xFFF9E7A7);
    case 'フェス':
      return const Color(0xFFBFE5D6);
    default:
      return const Color(0xFFE9D8C3);
  }
}

final _sampleEvents = <ScheduledDogEvent>[
  ScheduledDogEvent(
    title: 'DOGFES 2026 夏',
    date: DateTime(2026, 7, 20),
    place: '深谷テラス',
    category: 'フェス',
    region: '埼玉',
    attendeeDogIds: ['sample-1', 'sample-3'],
    items: ['名刺', 'おやつ', 'お水', '保冷バッグ'],
    memo: '午前は暑いので 9:30 集合。フォトブースもチェック。',
  ),
  ScheduledDogEvent(
    title: '軽井沢わんこ旅',
    date: DateTime(2026, 7, 27),
    place: '軽井沢アウトレット',
    category: '旅行',
    region: '長野',
    attendeeDogIds: ['sample-1', 'sample-3'],
    items: ['カート', 'レインコート', '宿メモ'],
    memo: 'ランチはテラス席優先。雨なら室内候補へ切り替え。',
  ),
  ScheduledDogEvent(
    title: '代々木ラン朝会',
    date: DateTime(2026, 8, 3),
    place: '代々木公園ドッグラン',
    category: 'オフ会',
    region: '東京',
    attendeeDogIds: ['sample-2'],
    items: ['ボール', '給水ボトル', 'LINE交換メモ'],
  ),
];
