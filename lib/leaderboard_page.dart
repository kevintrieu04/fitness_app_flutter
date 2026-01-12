import 'package:flutter/material.dart';

import 'design/design_tokens.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DT.bg,
      appBar: AppBar(
        backgroundColor: DT.bg,
        elevation: 0,
        title: Text(
          "Leaderboard",
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [DropdownMenu(
              dropdownMenuEntries: [
                DropdownMenuEntry(value: "Pushup", label: "Pushup"),
                DropdownMenuEntry(value: "Squat", label: "Squat"),
                DropdownMenuEntry(value: "Pullup", label: "Pullup"),
                DropdownMenuEntry(value: "Lunge", label: "Lunge"),
                DropdownMenuEntry(value: "Bridge", label: "Bridge"),
              ],
            ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.add))
            ],
          ),
          const SizedBox(height: DT.s4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Text("#"), Text("User"), Text("Counts")],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text("User ${index + 1}"),
                  subtitle: Text("Level ${index + 1}"),
                  trailing: Text("${index + 5}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
