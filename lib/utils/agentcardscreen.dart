import 'package:Akarat/model/agentsmodel.dart';
import 'package:Akarat/screen/about_agent.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:flutter/material.dart';

class Agentcardscreen extends StatelessWidget {
  final AgentsModel agentsModel;

  const Agentcardscreen({super.key, required this.agentsModel});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if (agentsModel == null) {
      return Scaffold(
        body: Center(
            child: ShimmerCard()), // Show loading state
      );
    }
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AboutAgent(data: '${agentsModel.id}'),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Card(
            color: Colors.white,
            elevation: 20,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Agent image
                  Container(
                    width: screenSize.width * 0.25,
                    height: screenSize.width * 0.25,
                    margin: const EdgeInsets.only(right: 10),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(agentsModel.image),
                      radius: 40,
                    ),
                  ),

                  // Agent details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          agentsModel.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),

                        // Agency
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            agentsModel.agency,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        // Languages
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Speaks: ${agentsModel.languages}",
                            style: TextStyle(fontSize: 12, letterSpacing: 0.5),
                          ),
                        ),

                        // Sale & Rent buttons
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Wrap(
                            spacing: 10,
                            children: [
                              buildTagButton(
                                count: agentsModel.sale,
                                label: "Sale",
                                screenSize: screenSize,
                              ),
                              buildTagButton(
                                count: agentsModel.rent,
                                label: "Rent",
                                screenSize: screenSize,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

    Widget buildTagButton({required int count, required String label, required Size screenSize}) {
      return Container(
        width: screenSize.width * 0.22,
        height: screenSize.height * 0.035,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              offset: Offset(4, 4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: Offset(-4, -4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            '$count $label',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }
  }
