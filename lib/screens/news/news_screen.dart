import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../services/economic_news_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _service = EconomicNewsService();
  final _dateFormat = DateFormat('MMM d, yyyy HH:mm');
  final _dayFormat = DateFormat('EEE, MMM d');

  Future<List<EconomicNewsEvent>>? _future;
  bool _loadingConfig = true;
  bool _loadingNews = false;
  DateTime _selectedDate = DateTime.now();
  bool _autoSelectedEventDate = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _loadConfig() {
    if (!mounted) return;
    setState(() {
      _loadingConfig = false;
      _future = _service.fetchCalendar();
    });
  }

  Future<void> _refresh() async {
    if (_loadingNews) return;
    setState(() {
      _loadingNews = true;
      _autoSelectedEventDate = false;
      _future = _service.fetchCalendar(forceRefresh: true);
    });
    try {
      await _future;
    } catch (_) {
      // The FutureBuilder renders the error state.
    } finally {
      if (mounted) {
        setState(() => _loadingNews = false);
      }
    }
  }

  void _changeSelectedDate(int days) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day + days,
      );
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Economic News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh news',
            onPressed: _loadingConfig || _loadingNews ? null : () => _refresh(),
          ),
        ],
      ),
      body: _loadingConfig
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    kIsWeb
                        ? 'Source: Stored weekly Forex Factory calendar feed. Web builds use CORS-safe proxy fallbacks when refreshing.'
                        : 'Source: Stored weekly Forex Factory calendar feed.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DateNavigator(
                    label: _dayFormat.format(_selectedDate),
                    isToday: _isSameDay(_selectedDate, DateTime.now()),
                    onPrevious: () => _changeSelectedDate(-1),
                    onToday: _goToToday,
                    onNext: () => _changeSelectedDate(1),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<EconomicNewsEvent>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return _NewsMessage(
                          icon: Icons.error_outline_rounded,
                          title: 'Unable to load economic news',
                          message: _formatError(snapshot.error),
                        );
                      }

                      final allEvents = snapshot.data ?? const [];
                      _autoSelectEventDate(allEvents);
                      final events = _eventsForSelectedDate(
                        allEvents,
                      );
                      if (events.isEmpty) {
                        final availableDates = _availableDateLabels(allEvents);
                        return _NewsMessage(
                          icon: Icons.event_busy_outlined,
                          title:
                              'No events for ${_dayFormat.format(_selectedDate)}',
                          message: availableDates.isEmpty
                              ? 'The loaded calendar did not include usable event dates.'
                              : 'Loaded dates: $availableDates',
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              '${events.length} event${events.length == 1 ? '' : 's'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                          ...events.map((event) => _NewsEventTile(
                                event: event,
                                dateFormat: _dateFormat,
                                isFinished: _isFinished(event),
                              )),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  String _formatError(Object? error) {
    final message = error.toString();
    final formatted = message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
    if (formatted.toLowerCase().contains('rate limited')) {
      return '$formatted\n\nForex Factory temporarily blocked repeated feed requests. Leave the News tab closed for the cooldown period, then refresh once.';
    }
    final environmentHint = kIsWeb
        ? 'Chrome/web builds depend on public CORS proxy availability because browsers block direct cross-site feed reads.'
        : 'The Windows app reads the Forex Factory feed directly, so this usually means the feed is temporarily blocked, offline, or unreachable from your network.';
    return '$formatted\n\n$environmentHint';
  }

  List<EconomicNewsEvent> _eventsForSelectedDate(
    List<EconomicNewsEvent> events,
  ) {
    final selectedEvents = events.where((event) {
      final dateTime = event.dateTime;
      if (dateTime == null) return false;
      return _isSameDay(dateTime.toLocal(), _selectedDate);
    }).toList();

    final now = DateTime.now();
    selectedEvents.sort((a, b) {
      final aDate = a.dateTime?.toLocal();
      final bDate = b.dateTime?.toLocal();
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      final aFinished = aDate.isBefore(now);
      final bFinished = bDate.isBefore(now);
      if (aFinished != bFinished) return aFinished ? 1 : -1;
      return aDate.compareTo(bDate);
    });

    return selectedEvents;
  }

  void _autoSelectEventDate(List<EconomicNewsEvent> events) {
    if (_autoSelectedEventDate || events.isEmpty) return;
    if (_eventsForSelectedDate(events).isNotEmpty) {
      _autoSelectedEventDate = true;
      return;
    }

    final targetDate = _nearestEventDate(events);
    if (targetDate == null) return;

    _autoSelectedEventDate = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedDate = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
        );
      });
    });
  }

  DateTime? _nearestEventDate(List<EconomicNewsEvent> events) {
    final eventDates = events
        .map((event) => event.dateTime?.toLocal())
        .whereType<DateTime>()
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort();
    if (eventDates.isEmpty) return null;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    for (final eventDate in eventDates) {
      if (!eventDate.isBefore(todayOnly)) return eventDate;
    }
    return eventDates.last;
  }

  String _availableDateLabels(List<EconomicNewsEvent> events) {
    final eventDates = events
        .map((event) => event.dateTime?.toLocal())
        .whereType<DateTime>()
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort();
    if (eventDates.isEmpty) return '';

    return eventDates
        .take(7)
        .map(_dayFormat.format)
        .join(', ');
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isFinished(EconomicNewsEvent event) {
    final dateTime = event.dateTime?.toLocal();
    if (dateTime == null) return false;
    return dateTime.isBefore(DateTime.now());
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.label,
    required this.isToday,
    required this.onPrevious,
    required this.onToday,
    required this.onNext,
  });

  final String label;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback onToday;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Previous day',
              onPressed: onPrevious,
            ),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ),
            TextButton(
              onPressed: isToday ? null : onToday,
              child: const Text('Today'),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Next day',
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsEventTile extends StatelessWidget {
  const _NewsEventTile({
    required this.event,
    required this.dateFormat,
    required this.isFinished,
  });

  final EconomicNewsEvent event;
  final DateFormat dateFormat;
  final bool isFinished;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = event.title.isEmpty ? 'Untitled event' : event.title;
    final dateText = event.dateTime != null
        ? dateFormat.format(event.dateTime!.toLocal())
        : [event.rawDate, event.rawTime]
            .where((part) => part.trim().isNotEmpty)
            .join(' ');

    final mutedColor = theme.hintColor;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isFinished
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CurrencyBadge(currency: event.currency),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isFinished ? mutedColor : null,
                        ),
                      ),
                      if (dateText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          isFinished ? '$dateText - Finished' : dateText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isFinished ? mutedColor : theme.hintColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (event.impact.isNotEmpty)
                  _ImpactBadge(
                    impact: event.impact,
                    muted: isFinished,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FactChip(
                  label: 'Actual',
                  value: event.actual,
                  muted: isFinished,
                ),
                _FactChip(
                  label: 'Forecast',
                  value: event.forecast,
                  muted: isFinished,
                ),
                _FactChip(
                  label: 'Previous',
                  value: event.previous,
                  muted: isFinished,
                ),
                _FactChip(
                  label: 'Outcome',
                  value: event.outcome,
                  muted: isFinished,
                ),
                _FactChip(
                  label: 'Strength',
                  value: event.strength,
                  muted: isFinished,
                ),
                _FactChip(
                  label: 'Quality',
                  value: event.quality,
                  muted: isFinished,
                ),
                _FactChip(
                  label: 'Projection',
                  value: event.projection,
                  muted: isFinished,
                ),
              ].where((chip) => chip.value.isNotEmpty).toList(),
            ),
            if (event.category.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                event.category,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImpactBadge extends StatelessWidget {
  const _ImpactBadge({
    required this.impact,
    this.muted = false,
  });

  final String impact;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = impact.trim().toLowerCase();
    final impactColor = switch (normalized) {
      'high' => Colors.red,
      'low' => Colors.amber,
      'medium' => Colors.orange,
      'holiday' => theme.hintColor,
      _ => theme.colorScheme.primary,
    };
    final color = muted ? theme.hintColor : impactColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        impact,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.end,
      ),
    );
  }
}

class _CurrencyBadge extends StatelessWidget {
  const _CurrencyBadge({required this.currency});

  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 44,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        currency.isEmpty ? '--' : currency,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({
    required this.label,
    required this.value,
    this.muted = false,
  });

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = muted ? theme.hintColor : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: muted ? 0.45 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelSmall?.copyWith(color: textColor),
      ),
    );
  }
}

class _NewsMessage extends StatelessWidget {
  const _NewsMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(icon, size: 44, color: theme.hintColor),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
