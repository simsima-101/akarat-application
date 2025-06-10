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


    String imageUrl = agentsModel.image?.toString().trim() ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://akarat.com$imageUrl';
    }

// Check if it is invalid:
    bool isValidImage = imageUrl.isNotEmpty &&
        imageUrl.toLowerCase() != 'n/a' &&
        imageUrl.toLowerCase() != 'null' &&
        imageUrl.toLowerCase().contains('.jpg') &&  // Optional: adjust to your API
        !imageUrl.toLowerCase().contains('default-image.jpg');  // IMPORTANT!


    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AboutAgent(data: '${agentsModel.id}'),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Card(
          color: Colors.white,
          elevation: 6,
          shadowColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Prepare imageUrl here ✅
                Builder(builder: (context) {
                  String imageUrl = agentsModel.image?.toString().trim() ?? '';
                  if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                    imageUrl = 'https://akarat.com$imageUrl';
                  }

                  return CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: isValidImage
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/images/profile.png') as ImageProvider,
                  );

                }),

                const SizedBox(width: 12), // spacing

                // Right content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        agentsModel.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Agency
                      Text(
                        agentsModel.agency,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Languages
                      Text(
                        "Speaks: ${agentsModel.languages}",
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Bio (if exists)
                      if (agentsModel.bio?.trim().isNotEmpty == true)
                        Text(
                          agentsModel.bio!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
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
