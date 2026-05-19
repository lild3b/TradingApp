import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../blocs/risk_calculator/risk_calculator_bloc.dart';
import '../../../blocs/analytics/analytics_bloc.dart';
import '../../../models/risk_calculation.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class RiskCalculatorScreen extends StatefulWidget {
  const RiskCalculatorScreen({super.key});

  @override
  State<RiskCalculatorScreen> createState() => _RiskCalculatorScreenState();
}

class _RiskCalculatorScreenState extends State<RiskCalculatorScreen> {
  final _entryCtrl = TextEditingController();
  final _slCtrl = TextEditingController();
  final _rrCtrl = TextEditingController(text: '2.0');
  final _balanceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill balance from analytics
    final analyticsState = context.read<AnalyticsBloc>().state;
    if (analyticsState is AnalyticsLoaded) {
      final bal = analyticsState.data.balance;
      _balanceCtrl.text = bal.toStringAsFixed(2);
      context.read<RiskCalculatorBloc>().add(UpdateRiskBalance(bal));
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _slCtrl.dispose();
    _rrCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Risk Calculator'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<RiskCalculatorBloc>().add(const ResetCalculator());
              _entryCtrl.clear();
              _slCtrl.clear();
              _rrCtrl.text = '2.0';
              final analyticsState = context.read<AnalyticsBloc>().state;
              if (analyticsState is AnalyticsLoaded) {
                _balanceCtrl.text = analyticsState.data.balance.toStringAsFixed(2);
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: BlocBuilder<RiskCalculatorBloc, RiskCalculatorState>(
        builder: (context, state) {
          final calc = state.calculation;
          return LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: _InputPanel(
                    entryCtrl: _entryCtrl,
                    slCtrl: _slCtrl,
                    rrCtrl: _rrCtrl,
                    balanceCtrl: _balanceCtrl,
                    calc: calc,
                  )),
                  const VerticalDivider(width: 1),
                  Expanded(child: _OutputPanel(calc: calc)),
                ],
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InputPanel(
                    entryCtrl: _entryCtrl,
                    slCtrl: _slCtrl,
                    rrCtrl: _rrCtrl,
                    balanceCtrl: _balanceCtrl,
                    calc: calc,
                  ),
                  const SizedBox(height: 24),
                  _OutputPanel(calc: calc),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}

class _InputPanel extends StatelessWidget {
  const _InputPanel({
    required this.entryCtrl,
    required this.slCtrl,
    required this.rrCtrl,
    required this.balanceCtrl,
    required this.calc,
  });

  final TextEditingController entryCtrl;
  final TextEditingController slCtrl;
  final TextEditingController rrCtrl;
  final TextEditingController balanceCtrl;
  final RiskCalculation calc;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inputs', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),

          // Balance
          _Label('Account Balance'),
          TextFormField(
            controller: balanceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: '\$'),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) {
                context.read<RiskCalculatorBloc>().add(UpdateRiskBalance(val));
              }
            },
          ),
          const SizedBox(height: 16),

          // Risk %
          _Label('Risk Percentage: ${calc.riskPercent.toStringAsFixed(1)}%'),
          Slider(
            value: calc.riskPercent,
            min: 0.1,
            max: 5.0,
            divisions: 49,
            label: '${calc.riskPercent.toStringAsFixed(1)}%',
            onChanged: (v) {
              context.read<RiskCalculatorBloc>().add(UpdateRiskPercent(v));
            },
          ),
          const SizedBox(height: 16),

          // Position direction
          _Label('Direction'),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Long'), icon: Icon(Icons.arrow_upward_rounded)),
              ButtonSegment(value: false, label: Text('Short'), icon: Icon(Icons.arrow_downward_rounded)),
            ],
            selected: {calc.isLong},
            onSelectionChanged: (s) {
              context.read<RiskCalculatorBloc>().add(UpdatePositionDirection(s.first));
            },
          ),
          const SizedBox(height: 16),

          // Entry price
          _Label('Entry Price'),
          TextFormField(
            controller: entryCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: const InputDecoration(hintText: '0.00000'),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) {
                context.read<RiskCalculatorBloc>().add(UpdateEntryPrice(val));
              }
            },
          ),
          const SizedBox(height: 16),

          // Stop loss price
          _Label('Stop Loss Price'),
          TextFormField(
            controller: slCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: const InputDecoration(hintText: '0.00000'),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) {
                context.read<RiskCalculatorBloc>().add(UpdateStopLossPrice(val));
              }
            },
          ),
          const SizedBox(height: 16),

          // Reward ratio
          _Label('Reward Ratio (R:R)'),
          TextFormField(
            controller: rrCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(suffixText: 'R'),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) {
                context.read<RiskCalculatorBloc>().add(UpdateRewardRatio(val));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _OutputPanel extends StatelessWidget {
  const _OutputPanel({required this.calc});
  final RiskCalculation calc;

  @override
  Widget build(BuildContext context) {
    final outputs = [
      _Output('Dollar at Risk', AppFormatters.currency(calc.dollarRisk), AppColors.loss),
      _Output('Position Size', calc.positionSize > 0
          ? calc.positionSize.toStringAsFixed(2)
          : '—', AppColors.primary),
      _Output('Take Profit', calc.takeProfitPrice > 0
          ? calc.takeProfitPrice.toStringAsFixed(5)
          : '—', AppColors.profit),
      _Output('Potential Profit', AppFormatters.currency(calc.potentialProfit), AppColors.profit),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Results', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...outputs.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OutputCard(output: o),
              )),
        ],
      ),
    );
  }
}

class _Output {
  const _Output(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;
}

class _OutputCard extends StatelessWidget {
  const _OutputCard({required this.output});
  final _Output output;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: output.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: output.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              output.label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          Text(
            output.value,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: output.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.labelMedium),
      );
}
