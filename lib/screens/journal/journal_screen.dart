import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/journal/journal_bloc.dart';
import '../../blocs/user_profile/user_profile_bloc.dart';
import '../../widgets/journal_card.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/chat_modal.dart';
import '../trade_detail/trade_detail_modal.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _load() {
    final state = context.read<UserProfileBloc>().state;
    if (state is ProfileSelected) {
      context.read<JournalBloc>().add(LoadJournal(state.selectedProfile.id));
    }
  }

  void _confirmExport(BuildContext context, String userId) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Journal'),
        content: const Text('Export all trading data to a CSV file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<JournalBloc>().add(ExportJournal(userId));
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _analyzeJournal(BuildContext context, String userId) {
    context.read<JournalBloc>().add(AnalyzeJournal(userId));
  }

  void _showNewTradeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const TradeDetailModal(tradeId: null),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search trades...',
                  border: InputBorder.none,
                ),
                onChanged: (q) =>
                    context.read<JournalBloc>().add(SearchJournal(q)),
              )
            : const Text('Trading Journal'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _searching = !_searching;
                if (!_searching) {
                  _searchCtrl.clear();
                  context.read<JournalBloc>().add(const ClearFilters());
                }
              });
            },
          ),
          BlocBuilder<JournalBloc, JournalState>(
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.auto_awesome_outlined),
              tooltip: 'Analyze Journal',
              onPressed: state is JournalLoaded && state.allTrades.isNotEmpty
                  ? () {
                      final profileState =
                          context.read<UserProfileBloc>().state;
                      if (profileState is ProfileSelected) {
                        _analyzeJournal(
                            context, profileState.selectedProfile.id);
                      }
                    }
                  : null,
            ),
          ),
          BlocBuilder<JournalBloc, JournalState>(
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Export CSV',
              onPressed: state is JournalLoaded
                  ? () {
                      final profileState =
                          context.read<UserProfileBloc>().state;
                      if (profileState is ProfileSelected) {
                        _confirmExport(
                            context, profileState.selectedProfile.id);
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
      body: BlocConsumer<JournalBloc, JournalState>(
        listener: (context, state) {
          if (state is JournalExported && state.filePath.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Journal exported to ${state.filePath}')),
            );
          } else if (state is JournalExported && state.filePath.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Journal export completed, but no file path was returned.')),
            );
          } else if (state is JournalAnalyzed) {
            showDialog<void>(
              context: context,
              builder: (_) => ChatModal(
                initialJournalContent: state.journalContent,
                initialJournalUserId: state.userId,
              ),
            );
          } else if (state is JournalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_formatErrorMessage(state.message))),
            );
          }
        },
        builder: (context, state) {
          if (state is JournalLoading ||
              state is JournalExporting ||
              state is JournalAnalyzing) {
            return const ShimmerList();
          }
          if (state is JournalLoaded) {
            if (state.filteredTrades.isEmpty) {
              return EmptyState(
                icon: Icons.book_outlined,
                title: state.allTrades.isEmpty
                    ? 'No trades yet'
                    : 'No matching trades',
                subtitle: state.allTrades.isEmpty
                    ? 'Tap + to log your first trade'
                    : 'Try adjusting your search or filters',
                actionLabel: state.allTrades.isEmpty ? 'Log a Trade' : null,
                onAction: state.allTrades.isEmpty
                    ? () => _showNewTradeModal(context)
                    : null,
              );
            }
            return ListView.builder(
              itemCount: state.filteredTrades.length,
              itemBuilder: (context, i) {
                final trade = state.filteredTrades[i];
                return JournalCard(
                  trade: trade,
                  onTap: () => context.push('/journal/trade/${trade.id}'),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewTradeModal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Trade'),
      ),
    );
  }

  String _formatErrorMessage(String message) {
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }
}
