import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/counter_data.dart';
import '../../../design/design_tokens.dart';
import '../domain/add_challenge_repository.dart';

class AddChallengePage extends ConsumerWidget {
  const AddChallengePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? selectedExerciseType;
    String? selectedName;
    int? selectedReps;
    int? selectedTime;
    final repository = ref.watch(addChallengeRepositoryProvider);

    return Scaffold(
      backgroundColor: DT.bg,
      appBar: AppBar(
        backgroundColor: DT.bg,
        elevation: 0,
        title: Text(
          "Add Custom Challenge",
          style: TextStyle(
            color: DT.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 450,
            padding: const EdgeInsets.all(DT.s4),
            decoration: BoxDecoration(
              color: DT.bgWhite,
              borderRadius: BorderRadius.circular(DT.rCardLarge),
              boxShadow: [
                const BoxShadow(
                  color: DT.shadowMedium,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("Name"),
                    const SizedBox(width: DT.s8),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          selectedName = value;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DT.s4),
                Row(
                  children: [
                    const Text("Exercise Type"),
                    const SizedBox(width: DT.s8),
                    Expanded(
                      child: DropdownMenu(
                        inputDecorationTheme: InputDecorationTheme(
                          isDense: true,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(DT.rChip),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSelected: (value) {
                          selectedExerciseType = value?.name;
                        },
                        dropdownMenuEntries: [
                          for (final exerciseType in ExerciseType.values)
                            DropdownMenuEntry(
                              value: exerciseType,
                              label: exerciseType.name,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DT.s4),
                Row(
                  children: [
                    const Text("Reps"),
                    const SizedBox(width: DT.s8),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          selectedReps = int.tryParse(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DT.s4),
                Row(
                  children: [
                    const Text("Time"),
                    const SizedBox(width: DT.s8),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          selectedTime = int.tryParse(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedName != null &&
                          selectedExerciseType != null &&
                          selectedReps != null &&
                          selectedTime != null) {
                        repository.addChallenge(
                          selectedName!,
                          ExerciseType.values.firstWhere(
                            (element) => element.name == selectedExerciseType,
                          ),
                          selectedReps!,
                          selectedTime!,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Challenge added successfully"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill in all fields"),
                          ),
                        );
                      }
                    },
                    child: const Text("Add Challenge"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
