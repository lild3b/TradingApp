import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/calendar/calendar_bloc.dart';
import '../../blocs/journal/journal_bloc.dart';
import '../../blocs/trade/trade_bloc.dart';
import '../../blocs/user_profile/user_profile_bloc.dart';
import '../../blocs/streak/streak_bloc.dart';
import '../../models/trade.dart';
import '../../utils/uuid_generator.dart';
import '../../utils/formatters.dart';
import '../../theme/app_colors.dart';
import '../../widgets/image_picker_widget.dart';
import '../../services/file_service.dart';

class TradeDetailModal extends StatefulWidget {
  const TradeDetailModal({super.key, required this.tradeId});
  final String? tradeId;

  @override
  State<TradeDetailModal> createState() => _TradeDetailModalState();
}

class _TradeDetailModalState extends State<TradeDetailModal> {
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
    final trade = trades.where((t) => t.id == widget.tradeId).firstOrNull;
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
    return BlocConsumer<TradeBloc, TradeState>(
      listener: (context, state) {
        if (state is TradeOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.profit,
            ),
          );
          _refreshRelatedData();
          Navigator.of(context).pop(); // Close modal on success
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
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEdit ? 'Edit Trade' : 'New Trade',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: isLoading ? null : _saveTrade,
                        child: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(isEdit ? 'Update' : 'Save'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Form content
                Expanded(
                  child: Form(
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
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .fillColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 18),
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
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Market required'
                                  : null,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _SectionLabel('Entry Price'),
                                      TextFormField(
                                        controller: _entryCtrl,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                            hintText: '0.00'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _SectionLabel('Exit Price'),
                                      TextFormField(
                                        controller: _exitCtrl,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                            hintText: '0.00'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // PnL
                            _SectionLabel('P&L'),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _pnlCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration:
                                        const InputDecoration(hintText: '0.00'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SegmentedButton<bool>(
                                  segments: const [
                                    ButtonSegment(
                                        value: true,
                                        label: Text('Profit'),
                                        icon: Icon(Icons.trending_up)),
                                    ButtonSegment(
                                        value: false,
                                        label: Text('Loss'),
                                        icon: Icon(Icons.trending_down)),
                                  ],
                                  selected: {_pnlPositive},
                                  onSelectionChanged: (s) =>
                                      setState(() => _pnlPositive = s.first),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Risk / Reward
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _SectionLabel('Risk Amount'),
                                      TextFormField(
                                        controller: _riskCtrl,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                            hintText: '0.00'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _SectionLabel('Reward Amount'),
                                      TextFormField(
                                        controller: _rewardCtrl,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                            hintText: '0.00'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Strategy
                            _SectionLabel('Entry Strategy'),
                            TextFormField(
                              controller: _strategyCtrl,
                              decoration: const InputDecoration(
                                  hintText: 'Describe your entry strategy'),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),

                            // Tags
                            _SectionLabel('Tags'),
                            _TagsInput(
                              tags: _tags,
                              onChanged: (t) => setState(() => _tags = t),
                            ),
                            const SizedBox(height: 16),

                            // Rules followed
                            _SectionLabel('Rules Followed'),
                            SegmentedButton<RulesFollowed>(
                              segments: const [
                                ButtonSegment(
                                    value: RulesFollowed.yes,
                                    label: Text('Yes')),
                                ButtonSegment(
                                    value: RulesFollowed.no, label: Text('No')),
                              ],
                              selected: {_rulesFollowed},
                              onSelectionChanged: (s) =>
                                  setState(() => _rulesFollowed = s.first),
                            ),
                            const SizedBox(height: 16),

                            // Comments
                            _SectionLabel('Comments'),
                            TextFormField(
                              controller: _commentsCtrl,
                              decoration: const InputDecoration(
                                  hintText: 'Additional notes'),
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),

                            // Images
                            _SectionLabel('Images'),
                            Row(
                              children: [
                                Expanded(
                                  child: ImagePickerWidget(
                                    label: 'Entry Screenshot',
                                    imagePath: _entryImagePath,
                                    onImagePicked: (path) =>
                                        setState(() => _entryImagePath = path),
                                    onImageRemoved: () =>
                                        setState(() => _entryImagePath = null),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ImagePickerWidget(
                                    label: 'Result Screenshot',
                                    imagePath: _resultImagePath,
                                    onImagePicked: (path) =>
                                        setState(() => _resultImagePath = path),
                                    onImageRemoved: () =>
                                        setState(() => _resultImagePath = null),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
      );
      if (time != null) {
        setState(() => _dateTime =
            DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    }
  }

  void _saveTrade() {
    if (!_formKey.currentState!.validate()) return;

    final profileState = context.read<UserProfileBloc>().state;
    if (profileState is! ProfileSelected) return;

    final market = _marketCtrl.text.trim();
    final entryPrice = double.tryParse(_entryCtrl.text) ?? 0;
    final exitPrice = double.tryParse(_exitCtrl.text) ?? 0;
    final pnlAmount = double.tryParse(_pnlCtrl.text) ?? 0;
    final pnl = _pnlPositive ? pnlAmount : -pnlAmount;
    final riskAmount = double.tryParse(_riskCtrl.text) ?? 0;
    final rewardAmount = double.tryParse(_rewardCtrl.text) ?? 0;
    final strategy = _strategyCtrl.text.trim();
    final comments = _commentsCtrl.text.trim();

    final trade = Trade(
      id: isEdit ? _originalTrade!.id : UuidGenerator.generate(),
      userId: profileState.selectedProfile.id,
      dateTimeTaken: _dateTime,
      market: market,
      positionType: _positionType,
      entryPrice: entryPrice,
      exitPrice: exitPrice,
      pnl: pnl,
      riskAmount: riskAmount,
      rewardAmount: rewardAmount,
      entryStrategy: strategy,
      tags: _tags,
      comments: comments,
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
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _TagsInput extends StatefulWidget {
  const _TagsInput({required this.tags, required this.onChanged});
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_TagsInput> createState() => _TagsInputState();
}

class _TagsInputState extends State<_TagsInput> {
  late final TextEditingController _tagController;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isEmpty || widget.tags.contains(tag)) return;
    final updated = [...widget.tags, tag];
    widget.onChanged(updated);
    _tagController.clear();
  }

  void _removeTag(String tag) {
    final updated = widget.tags.where((item) => item != tag).toList();
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.tags
              .map((tag) => InputChip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _tagController,
          decoration: InputDecoration(
            hintText: 'Add tag',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: _addTag,
            ),
          ),
          onSubmitted: (_) => _addTag(),
        ),
      ],
    );
  }
}
