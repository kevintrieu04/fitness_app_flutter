import 'package:flutter/material.dart';

import '../core/data/evaluator_data.dart';

class MoveEvaluatorAlertBox extends StatefulWidget {
  const MoveEvaluatorAlertBox({
    super.key,
    required this.link,
    required this.type,
    required this.entries,
  });

  final String link;
  final EvaluateExerciseType type;
  final List<DropdownMenuEntry<Moves>> entries;

  @override
  State<StatefulWidget> createState() {
    return _MoveEvaluatorAlertBoxState();
  }
}

class _MoveEvaluatorAlertBoxState extends State<MoveEvaluatorAlertBox> {
  Moves? move;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AlertDialog(
          title: const Text('Move Evaluator'),
          content: Column(
            children: [
              const Text("Choose the move you want to evaluate"),
              const SizedBox(height: 20),
              DropdownMenu(
                dropdownMenuEntries: widget.entries,
                onSelected: (value) {
                  move = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (move == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please choose a move")),
                  );
                } else {
                  Navigator.of(context).pop();
                  //todo: open evaluator test page
                  /**
                  AppNavigator.onOpenEvaluatorTestPage(
                    context,
                    widget.link,
                    widget.type,
                    move!,
                  );
                      */
                }
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }
}
