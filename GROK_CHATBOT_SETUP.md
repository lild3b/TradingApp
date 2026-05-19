# Groq AI Trading Chatbot Setup

## Overview
Your trading app now features a **Groq-powered trading chatbot** that:
- ✅ Answers any trading-related question
- ✅ Analyzes your trade journals automatically
- ✅ Exports and reads trading data
- ✅ Provides actionable trading insights
- ✅ Learns from conversation history

## Setup Instructions

### 1. Get Your Groq API Key
1. Visit https://console.groq.com/
2. Sign up or log in to your account
3. Create an API key
4. Copy your API key

### 2. Initialize Groq in Your App
```dart
import 'package:trading_journal/services/ai_trading_service.dart';

// Create Groq service
final aiService = GrokTradingService();

// Set your Groq API key
aiService.setGrokApiKey('your-groq-api-key-here');

// Set the model name entered by the user
aiService.setModel('user-entered-model-name');

// Use in your BLoC
final chatBloc = ChatBloc(aiService: aiService);
```

## Usage

### Ask Trading Questions
```dart
// Send message via BLoC
context.read<ChatBloc>().add(
  SendChatMessageEvent('What is the best risk management strategy?'),
);
```

### Analyze Trade Journals

#### Option 1: Direct Content Analysis
```dart
context.read<ChatBloc>().add(
  AnalyzeJournalEvent('''
Trade 1: BUY EURUSD at 1.0950
Entry Time: 2024-01-15 10:30
Exit Time: 2024-01-15 11:45
Stop Loss: 1.0920
Take Profit: 1.0980
Result: WIN +30 pips
'''),
);
```

#### Option 2: Analyze from File
```dart
// Automatically reads and analyzes your journal file
context.read<ChatBloc>().add(
  AnalyzeJournalFileEvent('/path/to/trading_journal.csv'),
);
```

## Features

### Trading Questions Answered
- ✅ Risk management strategies
- ✅ Technical analysis techniques
- ✅ Trading psychology advice
- ✅ Portfolio management tips
- ✅ Market trend analysis
- ✅ Position sizing strategies

### Journal Analysis
Groq provides:
- **Summary Statistics**: Total trades, win rate, P/L
- **Pattern Analysis**: Best/worst setups
- **Risk Assessment**: Stop loss adherence, sizing
- **Actionable Recommendations**: Specific improvements

## System Prompt
The assistant operates with specialized instructions to:
- Provide practical, data-driven trading advice
- Emphasize risk management (1-2% per trade)
- Analyze journals with detailed metrics
- Focus on sustainable long-term improvements
- Deliver clear, concise, actionable insights

## API Configuration
- **Base URL**: https://api.groq.com/openai/v1/chat/completions
- **Model**: Entered by the user
- **Temperature**: 0.7 (balanced creativity & consistency)
- **Max Tokens**: 2000 per response
- **Timeout**: 30 seconds

## Fallback Mode
If API key isn't set, the app provides:
- Relevant trading tips
- Reasonable default advice
- Local journal analysis
- No API calls needed

## Files Modified
- `lib/services/ai_trading_service.dart` - Groq chat completion implementation
- `lib/blocs/chat_bloc.dart` - Journal analysis events
- `pubspec.yaml` - Added http package

## Quick Integration Example
```dart
// In your main.dart or app initialization
void main() {
  final grokService = GrokTradingService();
  grokService.setGrokApiKey('your-groq-api-key');
  grokService.setModel('user-entered-model-name');
  
  runApp(MyApp(aiService: grokService));
}

// In your widget
BlocProvider(
  create: (context) => ChatBloc(aiService: grokService),
  child: ChatScreen(),
)
```

## Error Handling
- Gracefully falls back if API is unavailable
- Handles missing files with clear messages
- Supports CSV and plain text formats
- 30-second timeout prevents hanging requests

---

**Ready to use!** Just add your Groq API key and a model name, then start chatting with your AI trading assistant.
