import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/utils/extensions.dart';

class InfoTraficDetails extends StatefulWidget {
  final Map<String, dynamic> lineData;
  final Widget logo;

  const InfoTraficDetails({
    super.key,
    required this.lineData,
    required this.logo,
  });

  @override
  State<InfoTraficDetails> createState() => _InfoTraficDetailsState();
}

class _InfoTraficDetailsState extends State<InfoTraficDetails> {
  List<bool> isSelected = [true, false, false];

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: HexColor.fromHex(widget.lineData["presentation"]["colour"]),
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity
    );

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.lineData['name'],
          maxFontSize: 22,
          maxLines: 2,
          softWrap: true,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous page
          },
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: Material(
        color: colorScheme.primaryContainer,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.2,
                  child: FittedBox(
                    fit: BoxFit.contain, // Ensures the logo scales properly
                    child: widget.logo,
                  ),
                )
              ),

              const SizedBox(height: 12),

              Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 48, // Explicit height for ToggleButtons
        child: ToggleButtons(
          color: Colors.black.withOpacity(0.60),
          selectedColor: Colors.white,
          selectedBorderColor: Colors.white,
          fillColor: Colors.white.withOpacity(0.08),
          splashColor: Colors.white.withOpacity(0.4),
          hoverColor: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4.0),
          constraints: const BoxConstraints(
            minHeight: 48, // Ensure consistent height
            minWidth: 100, // Optional: Set a minimum width for buttons
          ),
          isSelected: isSelected,
          onPressed: (index) {
            setState(() {
              for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                isSelected[buttonIndex] = buttonIndex == index;
              }
            });
          },
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'En cours',
                  maxLines: 2,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.today, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Dans la journée',
                  maxLines: 2,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.schedule, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Prévu',
                  maxLines: 2,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ],
),
            ],
          ),
        )
      )
    );
  }
}