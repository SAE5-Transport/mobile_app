import 'package:flutter/material.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({
    super.key,
  });

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: Add the ticket of user
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Le logo de la barrique en travaux
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // La barrique
                    Container(
                      width: 120,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.brown.shade300,
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        border: Border.all(color: Colors.brown.shade900, width: 3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Cercles pour simuler les cerclages de la barrique
                          Container(
                            width: 120,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.brown.shade900,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 10,
                            decoration: BoxDecoration(color: Colors.brown.shade900),
                          ),
                          Container(
                            width: 120,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.brown.shade900,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Le panneau "En Travaux"
                    Positioned(
                      top: 45,
                      child: Transform.rotate(
                        angle: -0.2, // Un peu penché pour le style
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade700,
                            border: Border.all(color: Colors.black87, width: 1.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            "En Travaux",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40), // Espacement entre le logo et le texte
                // Le texte centré avec un peu de style
                Text(
                  "Notre projet est comme un bon vin : il s'améliore avec le temps.\n\nNos vignerons s'acharnent à la tâche, soignant chaque détail : macération des features, fermentation des idées, et un soupçon de débogage en barrique.\n\nOn vous tiendra au courant quand il sera passé de \"brut\" à \"stable\".",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.5, // Espacement entre les lignes
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}