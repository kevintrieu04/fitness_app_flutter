import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/design_tokens.dart';

class ChallengeResultPage extends StatelessWidget {
  const ChallengeResultPage({
    super.key,
    required this.errors,
    required this.totalCount,
    required this.correctReps,
    required this.caloriesBurnt,
    required this.targetReps, // Add this
  });

  final Map<int, String> errors;
  final int totalCount;
  final int correctReps;
  final double caloriesBurnt;
  final int targetReps; // Add this

  @override
  Widget build(BuildContext context) {
    final bool isPassed = correctReps >= targetReps; // Calculate isPassed here
    final int score = correctReps; // Assuming score is correctReps

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.pop([isPassed, score]); // Return data to ChallengeTestPage
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Challenge Result',
            style: TextStyle(
              color: DT.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ResultCard(
                totalCount: totalCount,
                correctReps: correctReps,
                caloriesBurnt: caloriesBurnt,
              ),
              const SizedBox(height: 24),
              if (errors.isNotEmpty)
                const Text(
                  "Mistakes",
                  style: TextStyle(
                    color: DT.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (errors.isNotEmpty) const SizedBox(height: 16),
              if (errors.isNotEmpty)
                DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Rep',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Reason',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: errors.entries.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry.key.toString())),
                      DataCell(Text(entry.value)),
                    ]);
                  }).toList(),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.pop([isPassed, score]); // Return data to ChallengeTestPage
                },
                child: const Text("Return"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.totalCount,
    required this.correctReps,
    required this.caloriesBurnt,
  });

  final int totalCount;
  final int correctReps;
  final double caloriesBurnt;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _ResultRow(
              label: 'Total Reps',
              value: totalCount.toString(),
            ),
            const SizedBox(height: 8),
            _ResultRow(
              label: 'Correct Reps',
              value: correctReps.toString(),
              valueColor: Colors.green,
            ),
            const SizedBox(height: 8),
            _ResultRow(
              label: 'Calories Burnt',
              value: caloriesBurnt.toStringAsFixed(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
