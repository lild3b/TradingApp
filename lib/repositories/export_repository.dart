import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';
import '../services/file_service.dart';

class ExportRepository {
  ExportRepository({required FileService fileService})
      : _fileService = fileService;

  final FileService _fileService;

  static const List<String> _headers = [
    'Trade ID',
    'Date',
    'Time',
    'Market',
    'Position Type',
    'Entry Price',
    'Exit Price',
    'PnL',
    'Risk',
    'Reward',
    'R:R Ratio',
    'Entry Strategy',
    'Tags',
    'Comments',
    'Rules Followed',
    'Entry Image Path',
    'Result Image Path',
  ];

  Future<String> exportTrades(List<Trade> trades, String filename,
      {String? directory}) async {
    final csv = buildTradesCsv(trades);
    final bytes = utf8.encode(csv);
    final path = await _fileService.saveFile(
      filename: filename,
      bytes: bytes,
      mimeType: 'text/csv',
      directory: directory,
    );
    return path ?? '';
  }

  String buildTradesCsv(List<Trade> trades) {
    final rows = <List<dynamic>>[_headers];
    final dateFmt = DateFormat('yyyy-MM-dd');
    final timeFmt = DateFormat('HH:mm:ss');

    for (final t in trades) {
      rows.add([
        t.id,
        dateFmt.format(t.dateTimeTaken),
        timeFmt.format(t.dateTimeTaken),
        t.market,
        t.positionType == PositionType.long ? 'Long' : 'Short',
        t.entryPrice.toStringAsFixed(5),
        t.exitPrice.toStringAsFixed(5),
        t.pnl.toStringAsFixed(2),
        t.riskAmount.toStringAsFixed(2),
        t.rewardAmount.toStringAsFixed(2),
        t.rrRatio.toStringAsFixed(2),
        t.entryStrategy,
        t.tags.join(', '),
        t.comments,
        _rulesFollowedLabel(t.rulesFollowed),
        t.entryImagePath ?? '',
        t.resultImagePath ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  String _rulesFollowedLabel(RulesFollowed r) {
    switch (r) {
      case RulesFollowed.yes:
        return 'Yes';
      case RulesFollowed.partial:
        return 'Partial';
      case RulesFollowed.no:
        return 'No';
    }
  }
}
