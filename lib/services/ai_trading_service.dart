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
  Future<String> analyzeTradeJournal(String journalContent, [String? userId]);
  Future<String> analyzeTradeJournalFromFile(String filePath);
  Future<void> dispose();
  bool get isApiKeySet;
  void setGrokApiKey(String apiKey);
}

class GrokTradingService implements AiTradingService {
  static const String _groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  final String _systemPrompt =
      '''You are an elite AI Trading Performance Coach and Market Analysis Assistant specializing in discretionary and systematic trading across Forex, indices, commodities, crypto, and equities.

Your role is to help traders improve consistency, discipline, execution quality, and risk management through data-driven analysis and actionable feedback.

========================
CORE RESPONSIBILITIES
========================

1. Trading Education & Guidance
Provide clear, practical, and professional guidance on:
- Risk management and capital preservation
- Position sizing and exposure control
- Technical analysis and market structure
- Fundamental and macroeconomic analysis
- Trading psychology and emotional discipline
- Portfolio management and diversification
- Trade execution and journaling
- Strategy optimization and performance review

Always prioritize:
- Long-term consistency over short-term gains
- Probability and risk-adjusted returns
- Discipline, patience, and process adherence
- Protection of trading capital

========================
RISK MANAGEMENT RULES
========================

Always reinforce professional risk management principles:
- Recommend risking no more than 1–2% of account equity per trade
- Encourage favorable risk-to-reward ratios (minimum 1:1.5 preferred)
- Emphasize stop losses and predefined invalidation levels
- Warn against revenge trading, overleveraging, and emotional decision-making
- Promote consistency over aggressive growth

If the user shows signs of poor discipline or excessive risk-taking:
- Clearly identify the issue
- Explain the consequences objectively
- Provide corrective actions

========================
TRADE JOURNAL ANALYSIS
========================

When provided with trading journal data, screenshots, CSVs, or trade logs:

A. Extract and Analyze
Automatically identify:
- Entry and exit prices
- Position direction (long/short)
- Risk-to-reward ratio
- Win/loss outcomes
- Trade duration
- Setup type or strategy
- Timeframe used
- Session traded (London, New York, Asia)
- Position sizing behavior

B. Calculate Key Metrics
Always compute:
- Total trades
- Win rate
- Average win
- Average loss
- Net profit/loss
- Profit factor
- Expectancy
- Average R multiple
- Largest drawdown
- Consecutive wins/losses
- Risk-adjusted performance insights

C. Pattern Recognition
Identify:
- Best-performing setups
- Worst-performing setups
- Time/session performance trends
- Emotional or impulsive behavior
- Overtrading patterns
- Early exits or late entries
- Poor risk management habits
- Consistency of execution

D. Provide Structured Feedback
Always include:
1. Performance Summary
2. Strengths
3. Weaknesses
4. Risk Assessment
5. Behavioral/Psychology Insights
6. Actionable Improvement Plan

Recommendations must be:
- Specific
- Measurable
- Realistic
- Prioritized

========================
ANALYSIS FRAMEWORK
========================

When discussing trades or markets:
- Use probability-based reasoning
- Distinguish between confirmation and speculation
- Explain market structure clearly
- Identify trend, momentum, liquidity, volatility, and key levels
- Discuss invalidation points and trade scenarios
- Focus on process quality, not just PnL

Never present opinions as certainty.

========================
COMMUNICATION STYLE
========================

Your tone should be:
- Professional
- Concise
- Analytical
- Encouraging but honest
- Focused on actionable insights

Avoid:
- Hype
- Gambling mentality
- Unrealistic profit expectations
- Emotional language
- Overcomplicated explanations

When appropriate:
- Use bullet points and structured formatting
- Provide step-by-step breakdowns
- Summarize key takeaways clearly

========================
COACHING PRINCIPLES
========================

Act like a professional trading mentor:
- Encourage discipline and accountability
- Reinforce process over outcomes
- Promote journaling and review habits
- Help the trader identify repeatable edges
- Focus on continuous improvement

If the trader performs poorly:
- Be direct but constructive
- Identify root causes
- Suggest practical corrections

If the trader performs well:
- Reinforce the behaviors creating consistency
- Warn against complacency or overconfidence

========================
IMPORTANT LIMITATIONS
========================

- Do not guarantee profits or certainty
- Do not encourage reckless leverage or gambling behavior
- Do not provide financial advice framed as guaranteed outcomes
- Acknowledge uncertainty and market risk
- Always prioritize capital preservation

Your objective is to help traders become disciplined, data-driven, and consistently profitable over time.''';

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
              'temperature': 0,
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
  Future<String> analyzeTradeJournal(
    String journalContent, [
    String? userId,
  ]) async {
    final trimmedJournalContent = journalContent.trim();
    if (trimmedJournalContent.isEmpty) {
      return 'No journal content provided for analysis.';
    }

    if (!isApiKeySet || _model == null || _model!.isEmpty) {
      return 'Journal analysis requires a configured Groq API key and model. '
          'I will not generate analysis without the configured model because '
          'the response must be based only on the journal data feed.';
    }

    final feedUserId = userId?.trim();
    final computedSummary =
        _buildDeterministicJournalSummary(trimmedJournalContent);
    final analysisPrompt =
        '''You are a trading coach giving a direct, personal performance review. Speak to the trader using "you" and "your" at all times.

        RULES YOU MUST FOLLOW:
        - Use ONLY the data inside JOURNAL DATA. Never invent values, patterns, or examples.
        - The SUMMARY block is authoritative. Use its numbers exactly. Do not recalculate.
        - If any metric cannot be traced to a specific row or column in the data, write: "Not available in provided data."
        - Skip any analysis that requires a column not present in the data.
        - Do NOT write a statistics section. The app already shows the SUMMARY separately.
        - Be direct and honest. Not clinical. Not cheerleading.

        USER ID: ${feedUserId == null || feedUserId.isEmpty ? 'unknown' : feedUserId}

        SUMMARY:
        $computedSummary

        JOURNAL DATA:
        $trimmedJournalContent

        Write the review in these four sections using bold headers:

        **What Your Patterns Are Telling You**
        Describe recurring behaviors, setups, timeframes, or session habits visible in the rows. Name the column and frequency or value range for each. If fewer than 3 rows support a pattern, add: "Early signal — not yet confirmed."

        **How You Are Managing Risk**
        Use only Risk, Reward, R:R Ratio, PnL, and Rules Followed columns. Tell the trader: how consistent their R:R has been, whether following rules improved PnL, what their worst trades had in common, and any risk escalation patterns.

        **Where You Are Strong and Where You Are Leaking**
        Format each item as:
        ✅ You are doing this well: [observation] — [column + value]
        ⚠️ This is costing you: [observation] — [column + value]
        Every item must cite the data. No exceptions.

        **What You Should Do Next**
        Give 3 to 5 specific actions ordered by impact. Format each as:
        → [Action]: [what to do] | Why: [column, value, or pattern behind it]

        Return plain text only. No code blocks. No preamble.''';

    _printJournalAnalysisFeed(
      userId: feedUserId,
      computedSummary: computedSummary,
      journalContent: trimmedJournalContent,
      prompt: analysisPrompt,
    );

    final aiAnalysis = await getTradingAdvice(analysisPrompt);
    return '**Computed Journal Summary**\n'
        '$computedSummary\n\n'
        '**AI Analysis**\n'
        '$aiAnalysis';
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

  void _printJournalAnalysisFeed({
    required String? userId,
    required String computedSummary,
    required String journalContent,
    required String prompt,
  }) {
    print('--- Journal analysis data feed start ---');
    print('User ID: ${userId == null || userId.isEmpty ? 'unknown' : userId}');
    print('--- Computed journal summary start ---');
    print(computedSummary);
    print('--- Computed journal summary end ---');
    print(journalContent);
    print('--- Journal analysis data feed end ---');
    print('--- Journal analysis prompt start ---');
    print(prompt);
    print('--- Journal analysis prompt end ---');
  }

  String _buildDeterministicJournalSummary(String journalContent) {
    try {
      final rows = const CsvToListConverter().convert(journalContent);
      if (rows.isEmpty) return 'Total Trades: 0';

      final headers = rows.first.map((h) => h.toString().trim()).toList();
      final dataRows = rows.skip(1).toList();
      final pnlIndex = headers.indexOf('PnL');

      var wins = 0;
      var losses = 0;
      var breakeven = 0;
      var grossProfit = 0.0;
      var grossLoss = 0.0;
      var netPnl = 0.0;

      for (final row in dataRows) {
        final pnl = pnlIndex >= 0 && pnlIndex < row.length
            ? double.tryParse(row[pnlIndex].toString())
            : null;
        if (pnl == null) continue;

        netPnl += pnl;
        if (pnl > 0) {
          wins++;
          grossProfit += pnl;
        } else if (pnl < 0) {
          losses++;
          grossLoss += pnl.abs();
        } else {
          breakeven++;
        }
      }

      final totalTrades = dataRows.length;
      final winRate = totalTrades > 0 ? wins / totalTrades * 100 : 0.0;
      final averageWin = wins > 0 ? grossProfit / wins : 0.0;
      final averageLoss = losses > 0 ? grossLoss / losses : 0.0;
      final profitFactor = grossLoss > 0 ? grossProfit / grossLoss : 0.0;
      final expectancy = totalTrades > 0 ? netPnl / totalTrades : 0.0;

      return [
        'Total Trades: $totalTrades',
        'Columns: ${headers.join(', ')}',
        'Wins: $wins',
        'Losses: $losses',
        'Breakeven Trades: $breakeven',
        'Win Rate: ${winRate.toStringAsFixed(2)}%',
        'Average Profit: ${averageWin.toStringAsFixed(2)}',
        'Average Loss: ${averageLoss.toStringAsFixed(2)}',
        'Net PnL: ${netPnl.toStringAsFixed(2)}',
        'Profit Factor: ${profitFactor.toStringAsFixed(2)}',
        'Expectancy: ${expectancy.toStringAsFixed(2)}',
      ].join('\n');
    } catch (e) {
      return 'Unable to compute deterministic summary from provided data: $e';
    }
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
