import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/scenes/tabs/info-trafic/info_trafic.dart';

class SelectOperatorInfoTrafic extends StatefulWidget {
  const SelectOperatorInfoTrafic({
    super.key,
  });

  @override
  State<SelectOperatorInfoTrafic> createState() => _SelectOperatorInfoTraficState();
}

class _SelectOperatorInfoTraficState extends State<SelectOperatorInfoTrafic> {
  Future<SizedBox> getOperators() async {
    List<Widget> operators = [];

    final jsonData = await rootBundle.loadString('assets/data/trafic.json');
    final data = jsonDecode(jsonData) as List<dynamic>;

    for (var company in data) {
      operators.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InfoTraficPage(
                  companyData: Map<String, dynamic>.from(company),
                )
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            // ignore: use_build_context_synchronously
            width: MediaQuery.of(context).size.width / 2 - 16,
            height: 100,
            child: Image.asset(
              company["companyLogo"]
            ),
          )
        )
      );
    }

    return SizedBox(
      width: double.infinity, // Ensure the Wrap takes the full width of the screen
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: operators,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Trafic'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous page
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary, // Set the background color
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder(
                  future: getOperators(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return SingleChildScrollView(
                        child: snapshot.data!,
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(), // Center the loading indicator
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}