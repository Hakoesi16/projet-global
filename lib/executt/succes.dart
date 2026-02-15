import 'package:checkmark/checkmark.dart';
import 'package:flutter/material.dart';

class Sixpage extends StatefulWidget {
  const Sixpage({super.key});

  @override
  State<Sixpage> createState() => _SixpageState();
}

class _SixpageState extends State<Sixpage> {
  bool _checked = false; // 1. Déclarer la variable

  @override
  void initState() {
    super.initState();
    // Lancer l'animation après un petit délai=500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _checked = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellowAccent,
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrer le contenu verticalement
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: CheckMark(
                active: _checked,
                curve: Curves.decelerate,
                duration: const Duration(milliseconds: 800),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your account",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Text(
              "was successfully created!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text("Only one click to explore the fish's world"),
            const SizedBox(height: 40),
            SizedBox(
              width: 250,
              height: 50,
              child: MaterialButton(
                color: const Color(0xFF013D73),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onPressed: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(builder: (context) => Homepage()),
                  // );
                },
                child: const Text(
                  "Log-in",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}