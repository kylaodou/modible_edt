import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const DashboardPage({super.key, this.userData});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.userData != null && widget.userData!['photo'] != null)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.userData!['photo']),
                radius: 40,
              ),
            SizedBox(height: 20),
            Text(
              "Bienvenue, ${widget.userData != null ? widget.userData!['nom'] ?? 'Utilisateur' : 'Utilisateur'}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
                widget.userData != null ? widget.userData!['email'] ?? '' : ''),
            Text(widget.userData.toString())
          ],
        ),
      ),
    );
  }
}
