import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/calendar/calendar_bloc.dart';
import '../../blocs/journal/journal_bloc.dart';
import '../../blocs/streak/streak_bloc.dart';
import '../../blocs/trade/trade_bloc.dart';
import '../../blocs/user_profile/user_profile_bloc.dart';
import '../../models/trade.dart';
import '../../utils/uuid_generator.dart';
import '../../utils/formatters.dart';
import '../../theme/app_colors.dart';
import '../../widgets/image_picker_widget.dart';
import '../../services/file_service.dart';

class TradeDetailScreen extends StatefulWidget {
  const TradeDetailScreen({super.key, required this.tradeId});
  final String? tradeId;

  @override
  State<TradeDetailScreen> createState() => _TradeDetailScreenState();
}

class _TradeDetailScreenState extends State<TradeDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get isEdit => widget.tradeId != null;

  // Controllers
  final _marketCtrl = TextEditingController();
  final _entryCtrl = TextEditingController();
  final _exitCtrl = TextEditingController();
  final _pnlCtrl = TextEditingController();
  final _riskCtrl = TextEditingController();
  final _rewardCtrl = TextEditingController();
  final _strategyCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();

  PositionType _positionType = PositionType.long;
  RulesFollowed _rulesFollowed = RulesFollowed.yes;
  DateTime _dateTime = DateTime.now();
  List<String> _tags = [];
  String? _entryImagePath;
  String? _resultImagePath;
  bool _pnlPositive = true;
  Trade? _originalTrade;

  @override
  void initState() {
    super.initState();
    if (isEdit) _loadTrade();
  }

  void _loadTrade() {
    final state = context.read<TradeBloc>().state;
    List<Trade> trades = [];
    if (state is TradesLoaded) trades = state.trades;
    if (state is TradeOperationSuccess) trades = state.trades;

    var trade = trades.firstWhereOrNull((t) => t.id == widget.tradeId);
    if (trade == null) {
      final journalState = context.read<JournalBloc>().state;
      if (journalState is JournalLoaded) {
        trade = journalState.allTrades.firstWhereOrNull(
          (t) => t.id == widget.tradeId,
        );
      }
    }

    if (trade != null) _populateForm(trade);
  }

  void _populateForm(Trade trade) {
    _originalTrade = trade;
    _marketCtrl.text = trade.market;
    _entryCtrl.text = trade.entryPrice.toString();
    _exitCtrl.text = trade.exitPrice.toString();
    _pnlCtrl.text = trade.pnl.abs().toString();
    _riskCtrl.text = trade.riskAmount.toString();
    _rewardCtrl.text = trade.rewardAmount.toString();
    _strategyCtrl.text = trade.entryStrategy;
    _commentsCtrl.text = trade.comments;
    _positionType = trade.positionType;
    _rulesFollowed = trade.rulesFollowed;
    _dateTime = trade.dateTimeTaken;
    _tags = List.from(trade.tags);
    _entryImagePath = trade.entryImagePath;
    _resultImagePath = trade.resultImagePath;
    _pnlPositive = trade.pnl >= 0;
    setState(() {});
  }

  @override
  void dispose() {
    _marketCtrl.dispose();
    _entryCtrl.dispose();
    _exitCtrl.dispose();
    _pnlCtrl.dispose();
    _riskCtrl.dispose();
    _rewardCtrl.dispose();
    _strategyCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Trade' : 'New Trade'),
        leading: const BackButton(),
      ),
      body: BlocConsumer<TradeBloc, TradeState>(
        listener: (context, state) {
          if (state is TradeOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.profit,
              ),
            );
            _refreshRelatedData();
            context.pop();
          } else if (state is TradeOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.loss,
              ),
            );
          } else if (state is TradeExported && state.filePath.isNotEmpty) {
            FileService.instance.shareFile(
                filePath: state.filePath,
                subject: 'Trade Export',
                mimeType: 'text/csv');
          }
        },
        builder: (context, state) {
          final isLoading = state is TradeOperationInProgress;
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date picker
                    _SectionLabel('Date & Time'),
                    InkWell(
                      onTap: _pickDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18),
                            const SizedBox(width: 12),
                            Text(AppFormatters.dateTime(_dateTime)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Market
                    _SectionLabel('Market'),
                    TextFormField(
                      controller: _marketCtrl,
                      decoration: const InputDecoration(
                          hintText: 'e.g. EURUSD, SPY, BTC/USD'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Market required' : null,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),

                    // Position type
                    _SectionLabel('Position Type'),
                    SegmentedButton<PositionType>(
                      segments: const [
                        ButtonSegment(
                            value: PositionType.long,
                            label: Text('Long'),
                            icon: Icon(Icons.arrow_upward_rounded)),
                        ButtonSegment(
                            value: PositionType.short,
                            label: Text('Short'),
                            icon: Icon(Icons.arrow_downward_rounded)),
                      ],
                      selected: {_positionType},
                      onSelectionChanged: (s) =>
                          setState(() => _positionType = s.first),
                    ),
                    const SizedBox(height: 16),

                    // Entry / Exit prices
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionLabel('Entry Price'),
                              TextFormField(
                                controller: _entryCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration:
                                    const InputDecoration(hintText: '0.00'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionLabel('Exit Price'),
                              TextFormField(
                                controller: _exitCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration:
                                    const InputDecoration(hintText: '0.00'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // PnL
                    _SectionLabel('PnL'),
                    Row(
                      children: [
                        // +/- toggle
                        GestureDetector(
                          onTap: () =>
                              setState(() => _pnlPositive = !_pnlPositive),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 15),
                            decoration: BoxDecoration(
                              color: (_pnlPositive
                                      ? AppColors.profit
                                      : AppColors.loss)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _pnlPositive
                                      ? AppColors.profit
                                      : AppColors.loss),
                            ),
                            child: Text(
                              _pnlPositive ? '+' : '-',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _pnlPositive
                                    ? AppColors.profit
                                    : AppColors.loss,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _pnlCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                                hintText: '0.00', prefixText: '\$'),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'PnL required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Risk / Reward
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionLabel('Risk (\$)'),
                              TextFormField(
                                controller: _riskCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration:
                                    const InputDecoration(hintText: '0.00'),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionLabel('Reward (\$)'),
                              TextFormField(
                                controller: _rewardCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration:
                                    const InputDecoration(hintText: '0.00'),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // R:R auto display
                    if (_riskCtrl.text.isNotEmpty &&
                        _rewardCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'R:R = ${_calcRR()}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Rules followed
                    _SectionLabel('Rules Followed'),
                    SegmentedButton<RulesFollowed>(
                      segments: const [
                        ButtonSegment(
                            value: RulesFollowed.yes, label: Text('Yes')),
                        ButtonSegment(
                            value: RulesFollowed.partial,
                            label: Text('Partial')),
                        ButtonSegment(
                            value: RulesFollowed.no, label: Text('No')),
                      ],
                      selected: {_rulesFollowed},
                      onSelectionChanged: (s) =>
                          setState(() => _rulesFollowed = s.first),
                    ),
                    const SizedBox(height: 16),

                    // Entry Strategy
                    _SectionLabel('Entry Strategy'),
                    TextFormField(
                      controller: _strategyCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          hintText: 'Describe your setup...'),
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    _SectionLabel('Tags'),
                    _TagsInput(
                      tags: _tags,
                      onChanged: (t) => setState(() => _tags = t),
                    ),
                    const SizedBox(height: 16),

                    // Comments
                    _SectionLabel('Comments'),
                    TextFormField(
                      controller: _commentsCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          hintText: 'Additional notes...'),
                    ),
                    const SizedBox(height: 16),

                    // Images
                    ImagePickerWidget(
                      label: 'Entry Screenshot',
                      imagePath: _entryImagePath,
                      onImagePicked: (p) => setState(() => _entryImagePath = p),
                      onImageRemoved: () =>
                          setState(() => _entryImagePath = null),
                    ),
                    const SizedBox(height: 16),
                    ImagePickerWidget(
                      label: 'Result Screenshot',
                      imagePath: _resultImagePath,
                      onImagePicked: (p) =>
                          setState(() => _resultImagePath = p),
                      onImageRemoved: () =>
                          setState(() => _resultImagePath = null),
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _save,
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(isEdit ? 'Update Trade' : 'Save Trade'),
                          ),
                        ),
                        if (isEdit) ...[
                          const SizedBox(width: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.loss,
                                side: const BorderSide(color: AppColors.loss)),
                            onPressed: isLoading ? null : _confirmDelete,
                            child: const Text('Delete'),
                          ),
                        ],
                      ],
                    ),
                    if (isEdit) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<TradeBloc>()
                            .add(ExportSingleTrade(widget.tradeId!)),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Export CSV'),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _calcRR() {
    final risk = double.tryParse(_riskCtrl.text) ?? 0;
    final reward = double.tryParse(_rewardCtrl.text) ?? 0;
    if (risk <= 0) return '—';
    return '${(reward / risk).toStringAsFixed(2)}R';
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null) return;
    setState(() {
      _dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final profileState = context.read<UserProfileBloc>().state;
    if (profileState is! ProfileSelected) return;

    final pnlValue =
        (double.tryParse(_pnlCtrl.text) ?? 0) * (_pnlPositive ? 1 : -1);

    final trade = Trade(
      id: isEdit ? widget.tradeId! : UuidGenerator.generate(),
      userId: profileState.selectedProfile.id,
      dateTimeTaken: _dateTime,
      market: _marketCtrl.text.trim(),
      positionType: _positionType,
      entryPrice: double.tryParse(_entryCtrl.text) ?? 0,
      exitPrice: double.tryParse(_exitCtrl.text) ?? 0,
      pnl: pnlValue,
      riskAmount: double.tryParse(_riskCtrl.text) ?? 0,
      rewardAmount: double.tryParse(_rewardCtrl.text) ?? 0,
      entryStrategy: _strategyCtrl.text,
      tags: _tags,
      comments: _commentsCtrl.text,
      rulesFollowed: _rulesFollowed,
      entryImagePath: _entryImagePath,
      resultImagePath: _resultImagePath,
      createdAt: isEdit
          ? (_originalTrade?.createdAt ?? DateTime.now())
          : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isEdit) {
      context.read<TradeBloc>().add(UpdateTrade(trade));
    } else {
      context.read<TradeBloc>().add(AddTrade(trade));
    }
  }

  void _refreshRelatedData() {
    final profileState = context.read<UserProfileBloc>().state;
    if (profileState is! ProfileSelected) return;
    final userId = profileState.selectedProfile.id;
    context.read<JournalBloc>().add(LoadJournal(userId));
    context.read<AnalyticsBloc>().add(RefreshAnalytics(userId));
    context.read<StreakBloc>().add(LoadStreaks(userId));
    final now = DateTime.now();
    context.read<CalendarBloc>().add(LoadCalendarMonth(
          userId: userId,
          year: now.year,
          month: now.month,
        ));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Trade'),
        content:
            const Text('This trade will be permanently deleted. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.loss),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<TradeBloc>().add(DeleteTrade(widget.tradeId!));
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.labelMedium),
      );
}

class _TagsInput extends StatefulWidget {
  const _TagsInput({required this.tags, required this.onChanged});
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_TagsInput> createState() => _TagsInputState();
}

class _TagsInputState extends State<_TagsInput> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...widget.tags.map((tag) => Chip(
              label: Text(tag),
              onDeleted: () {
                final updated = List<String>.from(widget.tags)..remove(tag);
                widget.onChanged(updated);
              },
            )),
        SizedBox(
          width: 120,
          child: TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              hintText: '+ Add tag',
              border: InputBorder.none,
              isDense: true,
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                final updated = List<String>.from(widget.tags)..add(val.trim());
                widget.onChanged(updated);
                _ctrl.clear();
              }
            },
          ),
        ),
      ],
    );
  }
}
