import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';

const _chatMessageUuid = Uuid();

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String id;

  ChatMessage({
    String? id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  }) : id = id ?? _chatMessageUuid.v4();
}

class AiTradingServiceException implements Exception {
  const AiTradingServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AiTradingService {
  Future<String> getTradingAdvice(String query,
      {List<ChatMessage>? conversationHistory});
  Future<String> analyzeTradeJournal(String journalContent);
  Future<String> analyzeTradeJournalFromFile(String filePath);
  Future<void> dispose();
  bool get isApiKeySet;
  void setGrokApiKey(String apiKey);
}

class GrokTradingService implements AiTradingService {
  static const String _groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  final String _systemPrompt =
      '''You are an expert AI trading assistant. Your primary responsibilities are:

1. **Answer Trading Questions**: Provide clear, actionable trading advice covering:
   - Risk management strategies and position sizing
   - Technical and fundamental analysis techniques
   - Trading psychology and emotional control
   - Market analysis and trend identification
   - Portfolio management and diversification

2. **Analyze Trade Journals Automatically**: When analyzing trading journals:
   - Extract and analyze all trades from the provided data
   - Calculate key metrics (win rate, risk-reward ratio, profit factor)
   - Identify patterns in winning and losing trades
   - Highlight strengths and areas for improvement
   - Provide specific, actionable recommendations

3. **Key Guidelines**:
   - Always emphasize risk management (risk no more than 1-2% per trade)
   - Use data-driven analysis when evaluating performance
   - Identify trading patterns and provide constructive feedback
   - Focus on long-term sustainable trading improvements
   - Be encouraging but honest about performance issues

When analyzing journals, always provide:
- Summary statistics (total trades, win rate, average profit/loss)
- Pattern analysis (best and worst performing setups)
- Risk assessment (position sizing, stop loss adherence)
- Specific recommendations for improvement

Remember: You are an expert trading AI. Be concise, practical, and focused on actionable insights.''';

  String? _apiKey;
  String? _model;
  final List<ChatMessage> _conversationHistory = [];

  @override
  bool get isApiKeySet => _apiKey != null && _apiKey!.isNotEmpty;

  @override
  void setGrokApiKey(String apiKey) {
    final trimmedApiKey = apiKey.trim();
    _apiKey = trimmedApiKey.isEmpty ? null : trimmedApiKey;
  }

  void setModel(String model) {
    final trimmedModel = model.trim();
    _model = trimmedModel.isEmpty ? null : trimmedModel;
  }

  String? getModel() => _model;

  @override
  Future<String> getTradingAdvice(String query,
      {List<ChatMessage>? conversationHistory}) async {
    if (!isApiKeySet) {
      return _getFallbackResponse(query);
    }

    try {
      if (_model == null || _model!.isEmpty) {
        throw const AiTradingServiceException(
          'Please enter a model name before using the Groq API.',
        );
      }

      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': _systemPrompt},
        ...?conversationHistory?.map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            }),
        {'role': 'user', 'content': query},
      ];

      final response = await http
          .post(
            Uri.parse(_groqBaseUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'max_completion_tokens': 1024,
              'temperature': 1,
              //'reasoning_effort': 'medium',
              'stop': null,
              'top_p': 1,
              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final content = _extractAssistantContent(response.body).trim();
        if (content.isEmpty) {
          if (kDebugMode) {
            print('Groq API returned an empty assistant message: '
                '${response.body}');
          }
          throw const AiTradingServiceException(
            'Groq returned an empty response. Try again or use a model that returns final message content.',
          );
        }

        _conversationHistory.add(ChatMessage(
          content: query,
          isUser: true,
          timestamp: DateTime.now(),
        ));
        _conversationHistory.add(ChatMessage(
          content: content,
          isUser: false,
          timestamp: DateTime.now(),
        ));

        return content;
      } else {
        final errorMessage = _formatApiError(response);
        if (kDebugMode) {
          print(errorMessage);
        }
        throw AiTradingServiceException(errorMessage);
      }
    } on AiTradingServiceException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error calling Groq API: $e');
      }
      throw AiTradingServiceException('Unable to reach Groq API: $e');
    }
  }

  String _formatApiError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final error = data['error'];
        final code = data['code'];
        final details =
            error is String && error.isNotEmpty ? error : response.body;
        return code is String && code.isNotEmpty
            ? 'Groq API Error ${response.statusCode}: $details ($code)'
            : 'Groq API Error ${response.statusCode}: $details';
      }
    } catch (_) {
      // Use the raw body below when the API does not return JSON.
    }

    return 'Groq API Error ${response.statusCode}: ${response.body}';
  }

  String _extractAssistantContent(String body) {
    final trimmedBody = body.trim();
    if (trimmedBody.startsWith('data:')) {
      final buffer = StringBuffer();
      final dataLines = const LineSplitter()
          .convert(trimmedBody)
          .map((line) => line.trim())
          .where((line) => line.startsWith('data:'))
          .map((line) => line.substring('data:'.length).trim())
          .where((line) => line.isNotEmpty && line != '[DONE]');

      for (final dataLine in dataLines) {
        final data = jsonDecode(dataLine) as Map<String, dynamic>;
        final choices = data['choices'];
        if (choices is! List || choices.isEmpty) continue;

        final choice = choices.first;
        if (choice is! Map<String, dynamic>) continue;

        final delta = choice['delta'];
        if (delta is Map<String, dynamic>) {
          final deltaContent = delta['content'];
          if (deltaContent is String) buffer.write(deltaContent);
        }

        final message = choice['message'];
        if (message is Map<String, dynamic>) {
          final messageContent = message['content'];
          if (messageContent is String) buffer.write(messageContent);
        }
      }

      return buffer.toString();
    }

    final data = jsonDecode(trimmedBody) as Map<String, dynamic>;
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) return '';

    final choice = choices.first;
    if (choice is! Map<String, dynamic>) return '';

    final message = choice['message'];
    if (message is Map<String, dynamic>) {
      final content = message['content'];
      if (content is String) return content;

      if (content is List) {
        return content
            .whereType<Map<String, dynamic>>()
            .map((part) => part['text'])
            .whereType<String>()
            .join();
      }
    }

    final text = choice['text'];
    return text is String ? text : '';
  }

  @override
  Future<String> analyzeTradeJournal(String journalContent) async {
    if (journalContent.isEmpty) {
      return 'No journal content provided for analysis.';
    }

    final analysisPrompt =
        '''Please analyze the following trading journal data and provide comprehensive insights:

$journalContent

Provide analysis including:
1. Summary Statistics (total trades, win rate, average profit/loss)
2. Pattern Analysis (best and worst performing setups)
3. Risk Assessment (position sizing, stop loss adherence)
4. Strengths and Weaknesses
5. Specific Recommendations for Improvement

Return the final analysis as visible assistant message content.''';

    return getTradingAdvice(analysisPrompt);
  }

  @override
  Future<String> analyzeTradeJournalFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return 'Journal file not found at path: $filePath';
      }

      final content = await file.readAsString();

      // Try to parse as CSV for structured data
      String formattedContent = content;
      try {
        final rows = const CsvToListConverter().convert(content);
        formattedContent = _formatJournalData(rows);
      } catch (e) {
        // If CSV parsing fails, use raw content
        formattedContent = content;
      }

      return analyzeTradeJournal(formattedContent);
    } catch (e) {
      return 'Error reading journal file: $e';
    }
  }

  String _formatJournalData(List<List<dynamic>> rows) {
    if (rows.isEmpty) return '';

    final StringBuffer buffer = StringBuffer();

    // Assume first row is headers
    final headers = rows[0].map((h) => h.toString()).toList();
    buffer.writeln('Trading Journal Analysis:');
    buffer.writeln('Columns: ${headers.join(", ")}');
    buffer.writeln('\nTrades:');

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      buffer.writeln('Trade ${i}:');
      for (int j = 0; j < headers.length && j < row.length; j++) {
        buffer.writeln('  ${headers[j]}: ${row[j]}');
      }
    }

    return buffer.toString();
  }

  String _getFallbackResponse(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('risk') ||
        lowerQuery.contains('stop loss') ||
        lowerQuery.contains('manage')) {
      return '📊 Risk Management:\n\n'
          'Risk management is the cornerstone of successful trading. Key principles:\n'
          '• Risk only 1-2% of your account per trade\n'
          '• Always use stop losses to define maximum risk\n'
          '• Use position sizing to control trade risk\n'
          '• Risk-reward ratio should be at least 1:2\n'
          '• Never risk capital you cannot afford to lose\n\n'
          'This protects your account and allows you to survive losing streaks.';
    } else if (lowerQuery.contains('psychology') ||
        lowerQuery.contains('emotion') ||
        lowerQuery.contains('fear')) {
      return '🧠 Trading Psychology:\n\n'
          'Emotional control is critical for trading success:\n'
          '• Fear leads to missed opportunities and premature exits\n'
          '• Greed causes over-leveraging and excessive risk\n'
          '• Stick to your trading plan regardless of market noise\n'
          '• Keep a trading journal to track emotional triggers\n'
          '• Take breaks after big wins or losses\n'
          '• Practice discipline and patience\n\n'
          'Remember: emotions are your biggest enemy in trading.';
    } else if (lowerQuery.contains('journal') || lowerQuery.contains('track')) {
      return '📝 Trading Journal Benefits:\n\n'
          'A trading journal is your path to improvement:\n'
          '• Record entry and exit reasons for every trade\n'
          '• Document market conditions and your emotional state\n'
          '• Track what worked and what didn\'t\n'
          '• Review regularly to identify patterns\n'
          '• Learn from both winning and losing trades\n'
          '• Build a personal trading playbook\n\n'
          'Traders who keep journals consistently outperform those who don\'t.';
    } else if (lowerQuery.contains('trend') ||
        lowerQuery.contains('chart') ||
        lowerQuery.contains('analysis')) {
      return '📈 Technical Analysis:\n\n'
          'Effective chart analysis involves:\n'
          '• Identify the primary trend direction\n'
          '• Find support and resistance levels\n'
          '• Use indicators like moving averages, RSI, MACD\n'
          '• Look for pattern confirmations\n'
          '• Trade WITH the trend, not against it\n'
          '• Combine technical with fundamental analysis\n\n'
          'The trend is your friend - trading aligned with it has better odds.';
    } else if (lowerQuery.contains('win') ||
        lowerQuery.contains('loss') ||
        lowerQuery.contains('ratio')) {
      return '💰 Profitability Metrics:\n\n'
          'Focus on these key metrics:\n'
          '• Win Rate: Percentage of winning trades\n'
          '• Risk-Reward Ratio: Average profit vs average loss\n'
          '• Profit Factor: Gross profit ÷ Gross loss\n'
          '• Expectancy: Average profit per trade\n\n'
          'A 40% win rate with 1:3 risk-reward is highly profitable.\n'
          'Consistency matters more than home runs.';
    } else if (lowerQuery.contains('analyze') ||
        lowerQuery.contains('journal')) {
      return '📊 Journal Analysis Ready:\n\n'
          'I can analyze your trading journal to provide:\n'
          '• Win rate and success metrics\n'
          '• Pattern identification in your trades\n'
          '• Risk assessment and position sizing review\n'
          '• Strengths and improvement areas\n'
          '• Specific actionable recommendations\n\n'
          'Share your journal data or export it for automatic analysis.';
    }

    // Default response
    return '💡 Trading Tip:\n\n'
        'Success in trading comes from:\n'
        '• Consistent risk management\n'
        '• Disciplined strategy execution\n'
        '• Continuous learning and adaptation\n'
        '• Detailed record keeping in a trading journal\n'
        '• Patient capital preservation\n\n'
        'Focus on the process, and profits will follow. Ask me about any specific trading topic!';
  }

  @override
  Future<void> dispose() async {
    _conversationHistory.clear();
  }
}
