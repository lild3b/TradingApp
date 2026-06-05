import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'secure_storage_service.dart';

class EconomicNewsService {
  EconomicNewsService({http.Client? client}) : _client = client ?? http.Client();

  static const String _cacheStorageKey = 'economic_news_weekly_cache_v1';

  static final Uri _forexFactoryCalendarJsonUri =
      Uri.parse('https://nfs.faireconomy.media/ff_calendar_thisweek.json');
  static final Uri _forexFactoryCalendarXmlUri =
      Uri.parse('https://nfs.faireconomy.media/ff_calendar_thisweek.xml');

  final http.Client _client;
  static Future<List<EconomicNewsEvent>>? _inFlightRequest;
  static List<EconomicNewsEvent> _cachedEvents = const [];
  static DateTime? _lastSuccessfulFetch;
  static DateTime? _rateLimitedUntil;
  static DateTime? _retryAfterFailure;
  static String? _lastFailureMessage;
  static bool _loadedStoredCache = false;

  Future<List<EconomicNewsEvent>> fetchCalendar({
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    final lastSuccessfulFetch = _lastSuccessfulFetch;
    if (!forceRefresh &&
        _cachedEvents.isNotEmpty &&
        lastSuccessfulFetch != null &&
        _weekKey(lastSuccessfulFetch) == _weekKey(now)) {
      return _cachedEvents;
    }

    final storedEvents = await _loadStoredWeeklyCache();
    if (!forceRefresh && storedEvents.isNotEmpty) return storedEvents;

    final rateLimitedUntil = _rateLimitedUntil;
    if (!forceRefresh &&
        rateLimitedUntil != null &&
        now.isBefore(rateLimitedUntil)) {
      if (_cachedEvents.isNotEmpty) return _cachedEvents;
      throw EconomicNewsException(
        'Forex Factory rate limited the news feed. Try again after '
        '${DateFormat('HH:mm').format(rateLimitedUntil)}.',
      );
    }

    final retryAfterFailure = _retryAfterFailure;
    if (!forceRefresh &&
        retryAfterFailure != null &&
        now.isBefore(retryAfterFailure)) {
      if (_cachedEvents.isNotEmpty) return _cachedEvents;
      throw EconomicNewsException(
        _lastFailureMessage ??
            'Economic news recently failed to load. Try again after '
                '${DateFormat('HH:mm').format(retryAfterFailure)}.',
      );
    }

    final activeRequest = _inFlightRequest;
    if (activeRequest != null) return activeRequest;

    final request = _fetchForexFactoryCalendar();
    _inFlightRequest = request;
    try {
      final events = await request;
      if (events.isNotEmpty) {
        _cachedEvents = events;
        _lastSuccessfulFetch = DateTime.now();
        _rateLimitedUntil = null;
        _retryAfterFailure = null;
        _lastFailureMessage = null;
        await _saveStoredWeeklyCache(events);
      }
      return events;
    } catch (e) {
      _rememberFailure(e);
      if (_cachedEvents.isNotEmpty) return _cachedEvents;
      rethrow;
    } finally {
      _inFlightRequest = null;
    }
  }

  Future<List<EconomicNewsEvent>> _fetchForexFactoryCalendar() async {
    Object? lastError;
    for (final source in _forexFactoryCalendarSources()) {
      try {
        debugPrint('Economic news feed attempt: ${source.label} ${source.uri}');
        final response = await _client
            .get(
              source.uri,
              headers: {
                'Accept': source.format.acceptHeader,
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                    '(KHTML, like Gecko) Chrome/125.0 Safari/537.36',
              },
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode != 200) {
          if (response.statusCode == 429) {
            _rateLimitedUntil = DateTime.now().add(const Duration(minutes: 30));
            throw EconomicNewsException.rateLimited(
              'Forex Factory rate limited the news feed. The app will stop '
              'retrying until ${DateFormat('HH:mm').format(_rateLimitedUntil!)}.',
            );
          }
          throw EconomicNewsException(
            '${source.label} returned HTTP ${response.statusCode}: '
            '${_trimForError(response.body)}',
          );
        }

        final events = _decodeEvents(response.body, source);
        debugPrint(
          'Economic news feed loaded ${events.length} events from '
          '${source.label}.',
        );
        return events;
      } catch (e) {
        debugPrint('Economic news feed failed: $e');
        lastError = e;
        if (e is EconomicNewsException && e.isRateLimited) break;
      }
    }

    if (lastError is EconomicNewsException && lastError.isRateLimited) {
      throw EconomicNewsException.rateLimited(lastError.message);
    }

    throw EconomicNewsException(
      'All Forex Factory feed sources failed. Last error: $lastError',
    );
  }

  Future<List<EconomicNewsEvent>> _loadStoredWeeklyCache() async {
    if (_loadedStoredCache) {
      return _cachedEvents.isNotEmpty &&
              _lastSuccessfulFetch != null &&
              _weekKey(_lastSuccessfulFetch!) == _weekKey(DateTime.now())
          ? _cachedEvents
          : const [];
    }

    _loadedStoredCache = true;
    try {
      final stored = await SecureStorageService.instance.read(_cacheStorageKey);
      if (stored == null || stored.trim().isEmpty) return const [];

      final decoded = jsonDecode(stored);
      if (decoded is! Map<String, dynamic>) return const [];
      if (decoded['weekKey'] != _weekKey(DateTime.now())) return const [];

      final eventsJson = decoded['events'];
      if (eventsJson is! List) return const [];

      final events = eventsJson
          .whereType<Map>()
          .map((eventJson) => EconomicNewsEvent.fromCacheJson(
                Map<String, dynamic>.fromEntries(
                  eventJson.entries.map(
                    (entry) => MapEntry(entry.key.toString(), entry.value),
                  ),
                ),
              ))
          .toList()
        ..sort((a, b) {
          final aDate = a.dateTime;
          final bDate = b.dateTime;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return aDate.compareTo(bDate);
        });

      if (events.isEmpty) return const [];

      _cachedEvents = events;
      _lastSuccessfulFetch = DateTime.tryParse(
            (decoded['fetchedAt'] ?? '').toString(),
          ) ??
          DateTime.now();
      debugPrint('Economic news loaded ${events.length} events from storage.');
      return events;
    } catch (e) {
      debugPrint('Economic news stored cache failed: $e');
      return const [];
    }
  }

  Future<void> _saveStoredWeeklyCache(List<EconomicNewsEvent> events) async {
    try {
      final payload = jsonEncode({
        'weekKey': _weekKey(DateTime.now()),
        'fetchedAt': DateTime.now().toIso8601String(),
        'events': events.map((event) => event.toCacheJson()).toList(),
      });
      await SecureStorageService.instance.write(_cacheStorageKey, payload);
      debugPrint('Economic news stored ${events.length} weekly events.');
    } catch (e) {
      debugPrint('Economic news stored cache save failed: $e');
    }
  }

  void _rememberFailure(Object error) {
    if (error is EconomicNewsException && error.isRateLimited) return;
    _retryAfterFailure = DateTime.now().add(const Duration(minutes: 10));
    _lastFailureMessage = 'Economic news recently failed to load. The app will '
        'retry after ${DateFormat('HH:mm').format(_retryAfterFailure!)}.\n\n'
        'Last error: $error';
  }

  String _weekKey(DateTime date) {
    final local = date.toLocal();
    final monday = DateTime(
      local.year,
      local.month,
      local.day,
    ).subtract(Duration(days: local.weekday - DateTime.monday));
    return DateFormat('yyyy-MM-dd').format(monday);
  }

  List<_NewsFeedSource> _forexFactoryCalendarSources() {
    final directSources = [
      _NewsFeedSource(
        'Forex Factory direct JSON feed',
        _forexFactoryCalendarJsonUri,
        _NewsFeedFormat.json,
      ),
    ];
    final webXmlSource = _NewsFeedSource(
      'Forex Factory direct XML feed',
      _forexFactoryCalendarXmlUri,
      _NewsFeedFormat.xml,
    );

    _NewsFeedSource proxied(
      _NewsFeedSource source,
      String label,
      Uri Function(String encodedSource) uriBuilder, {
      bool wrapsContents = false,
    }) {
      return _NewsFeedSource(
        '$label ${source.format.label}',
        uriBuilder(Uri.encodeComponent(source.uri.toString())),
        source.format,
        wrapsContents: wrapsContents,
      );
    }

    return [
      if (!kIsWeb) ...directSources,
      if (kIsWeb) ...[
        proxied(
          directSources.first,
          'AllOrigins raw proxy',
          (encodedSource) =>
              Uri.parse('https://api.allorigins.win/raw?url=$encodedSource'),
        ),
        proxied(
          directSources.first,
          'AllOrigins wrapped proxy',
          (encodedSource) =>
              Uri.parse('https://api.allorigins.win/get?url=$encodedSource'),
          wrapsContents: true,
        ),
        proxied(
          directSources.first,
          'CodeTabs proxy',
          (encodedSource) => Uri.parse(
            'https://api.codetabs.com/v1/proxy?quest=$encodedSource',
          ),
        ),
        ...directSources,
        proxied(
          webXmlSource,
          'AllOrigins raw proxy',
          (encodedSource) =>
              Uri.parse('https://api.allorigins.win/raw?url=$encodedSource'),
        ),
        proxied(
          webXmlSource,
          'AllOrigins wrapped proxy',
          (encodedSource) =>
              Uri.parse('https://api.allorigins.win/get?url=$encodedSource'),
          wrapsContents: true,
        ),
        proxied(
          webXmlSource,
          'CodeTabs proxy',
          (encodedSource) => Uri.parse(
            'https://api.codetabs.com/v1/proxy?quest=$encodedSource',
          ),
        ),
        webXmlSource,
      ],
    ];
  }

  List<EconomicNewsEvent> _decodeEvents(String body, _NewsFeedSource source) {
    final feedBody = _unwrapSourceResponse(body, source);
    final events = switch (source.format) {
      _NewsFeedFormat.json => _mapAndSort(_extractList(jsonDecode(feedBody))),
      _NewsFeedFormat.xml => _mapAndSort(_extractXmlEvents(feedBody)),
    };
    if (kIsWeb && events.isEmpty) {
      throw EconomicNewsException(
        '${source.label} returned an empty calendar feed.',
      );
    }
    return events;
  }

  String _unwrapSourceResponse(String body, _NewsFeedSource source) {
    if (!source.wrapsContents) return body;

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final contents = decoded['contents'];
      if (contents is String && contents.trim().isNotEmpty) {
        return contents;
      }
    }

    throw EconomicNewsException(
      '${source.label} response did not include feed contents.',
    );
  }

  List<dynamic> _extractXmlEvents(String xml) {
    final eventMatches = RegExp(
      r'<event\b[^>]*>([\s\S]*?)<\/event>',
      caseSensitive: false,
    ).allMatches(xml);

    return eventMatches.map((match) {
      final block = match.group(1) ?? '';
      return {
        'title': _xmlTagText(block, 'title'),
        'country': _xmlTagText(block, 'country'),
        'date': _xmlTagText(block, 'date'),
        'time': _xmlTagText(block, 'time'),
        'impact': _xmlTagText(block, 'impact'),
        'forecast': _xmlTagText(block, 'forecast'),
        'previous': _xmlTagText(block, 'previous'),
        'actual': _xmlTagText(block, 'actual'),
      };
    }).toList();
  }

  String _xmlTagText(String block, String tagName) {
    final match = RegExp(
      '<$tagName[^>]*>([\\s\\S]*?)<\\/$tagName>',
      caseSensitive: false,
    ).firstMatch(block);
    final value = match?.group(1) ?? '';
    return value
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  List<EconomicNewsEvent> _mapAndSort(List<dynamic> items) {
    return items
        .whereType<Map>()
        .map((item) => EconomicNewsEvent.fromJson(
              Map<String, dynamic>.fromEntries(
                item.entries.map(
                  (entry) => MapEntry(entry.key.toString(), entry.value),
                ),
              ),
            ))
        .toList()
      ..sort((a, b) {
        final aDate = a.dateTime;
        final bDate = b.dateTime;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      for (final key in const [
        'calendar',
        'events',
        'data',
        'results',
        'news',
      ]) {
        final value = decoded[key];
        if (value is List) return value;
      }
    }
    throw const EconomicNewsException(
      'News feed response did not contain a calendar event list.',
    );
  }

  void dispose() {
    // The news service keeps a process-wide cache/in-flight request so tab
    // switches do not cancel a working feed request or throw away loaded news.
  }
}

enum _NewsFeedFormat {
  json('JSON', 'application/json'),
  xml('XML', 'application/xml,text/xml');

  const _NewsFeedFormat(this.label, this.acceptHeader);

  final String label;
  final String acceptHeader;
}

class _NewsFeedSource {
  const _NewsFeedSource(
    this.label,
    this.uri,
    this.format, {
    this.wrapsContents = false,
  });

  final String label;
  final Uri uri;
  final _NewsFeedFormat format;
  final bool wrapsContents;
}

String _trimForError(String body) {
  final compact = body.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (compact.length <= 240) return compact;
  return '${compact.substring(0, 240)}...';
}

class EconomicNewsException implements Exception {
  const EconomicNewsException(this.message) : isRateLimited = false;
  const EconomicNewsException.rateLimited(this.message) : isRateLimited = true;

  final String message;
  final bool isRateLimited;

  @override
  String toString() => message;
}

class EconomicNewsEvent {
  const EconomicNewsEvent({
    required this.title,
    required this.currency,
    required this.category,
    required this.impact,
    required this.actual,
    required this.forecast,
    required this.previous,
    required this.outcome,
    required this.strength,
    required this.quality,
    required this.projection,
    required this.rawDate,
    required this.rawTime,
    required this.dateTime,
  });

  final String title;
  final String currency;
  final String category;
  final String impact;
  final String actual;
  final String forecast;
  final String previous;
  final String outcome;
  final String strength;
  final String quality;
  final String projection;
  final String rawDate;
  final String rawTime;
  final DateTime? dateTime;

  factory EconomicNewsEvent.fromJson(Map<String, dynamic> json) {
    final rawDate = _firstText(json, const [
      'date',
      'Date',
      'datetime',
      'time',
      'release_time',
    ]);
    final rawTime = _firstText(json, const ['time', 'Time']);

    return EconomicNewsEvent(
      title: _firstText(json, const ['name', 'Name', 'event', 'Event', 'title']),
      currency: _firstText(json, const [
        'currency',
        'Currency',
        'country',
        'Country',
      ]),
      category: _firstText(json, const ['category', 'Category']),
      impact: _firstText(json, const ['impact', 'Impact', 'importance']),
      actual: _firstText(json, const ['actual', 'Actual']),
      forecast: _firstText(json, const ['forecast', 'Forecast']),
      previous: _firstText(json, const ['previous', 'Previous']),
      outcome: _firstText(json, const ['outcome', 'Outcome']),
      strength: _firstText(json, const ['strength', 'Strength']),
      quality: _firstText(json, const ['quality', 'Quality']),
      projection: _firstText(json, const ['projection', 'Projection']),
      rawDate: rawDate,
      rawTime: rawTime,
      dateTime: _parseDateTime(rawDate, rawTime),
    );
  }

  factory EconomicNewsEvent.fromCacheJson(Map<String, dynamic> json) {
    return EconomicNewsEvent(
      title: (json['title'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      impact: (json['impact'] ?? '').toString(),
      actual: (json['actual'] ?? '').toString(),
      forecast: (json['forecast'] ?? '').toString(),
      previous: (json['previous'] ?? '').toString(),
      outcome: (json['outcome'] ?? '').toString(),
      strength: (json['strength'] ?? '').toString(),
      quality: (json['quality'] ?? '').toString(),
      projection: (json['projection'] ?? '').toString(),
      rawDate: (json['rawDate'] ?? '').toString(),
      rawTime: (json['rawTime'] ?? '').toString(),
      dateTime: DateTime.tryParse((json['dateTime'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'title': title,
      'currency': currency,
      'category': category,
      'impact': impact,
      'actual': actual,
      'forecast': forecast,
      'previous': previous,
      'outcome': outcome,
      'strength': strength,
      'quality': quality,
      'projection': projection,
      'rawDate': rawDate,
      'rawTime': rawTime,
      'dateTime': dateTime?.toIso8601String(),
    };
  }

  static String _firstText(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return '';
  }

  static DateTime? _parseDateTime(String date, String time) {
    final combined = [date, time]
        .where((part) => part.trim().isNotEmpty)
        .join(' ')
        .trim();
    for (final candidate in [date, combined]) {
      final normalized = candidate.trim();
      if (normalized.isEmpty) continue;
      final normalizedPeriod = normalized.replaceAllMapped(
        RegExp(r'\b(am|pm)\b', caseSensitive: false),
        (match) => match.group(0)!.toUpperCase(),
      );

      final parsed = DateTime.tryParse(normalizedPeriod);
      if (parsed != null) return parsed;

      for (final format in _dateFormats) {
        try {
          return format.parseStrict(normalizedPeriod);
        } catch (_) {
          // Try the next known Forex Factory date shape.
        }
      }
    }
    return null;
  }

  static final List<DateFormat> _dateFormats = [
    DateFormat('MM-dd-yyyy h:mma', 'en_US'),
    DateFormat('MM-dd-yyyy ha', 'en_US'),
    DateFormat('MM-dd-yyyy HH:mm', 'en_US'),
    DateFormat('M-d-yyyy h:mma', 'en_US'),
    DateFormat('M-d-yyyy ha', 'en_US'),
    DateFormat('M-d-yyyy HH:mm', 'en_US'),
    DateFormat('MM-dd-yyyy', 'en_US'),
    DateFormat('M-d-yyyy', 'en_US'),
    DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US'),
    DateFormat('yyyy-MM-dd HH:mm', 'en_US'),
    DateFormat('yyyy-MM-dd', 'en_US'),
    DateFormat('MMM d, yyyy h:mma', 'en_US'),
    DateFormat('MMM d, yyyy HH:mm', 'en_US'),
    DateFormat('MMM d, yyyy', 'en_US'),
    DateFormat('EEE MMM d h:mma yyyy', 'en_US'),
    DateFormat('EEE MMM d yyyy', 'en_US'),
    DateFormat('EEEE MMM d h:mma yyyy', 'en_US'),
    DateFormat('EEEE MMM d yyyy', 'en_US'),
    DateFormat('EEE, MMM d h:mma yyyy', 'en_US'),
    DateFormat('EEE, MMM d yyyy', 'en_US'),
    DateFormat('EEEE, MMM d h:mma yyyy', 'en_US'),
    DateFormat('EEEE, MMM d yyyy', 'en_US'),
  ];
}
