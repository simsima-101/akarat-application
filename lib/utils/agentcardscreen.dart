import 'package:Akarat/model/agentsmodel.dart';
import 'package:Akarat/screen/about_agent.dart';
import 'package:flutter/material.dart';

class Agentcardscreen extends StatelessWidget {
  final AgentsModel agentsModel;

  const Agentcardscreen({super.key, required this.agentsModel});

  @override
  Widget build(BuildContext context) {
    String imageUrl = agentsModel.image?.trim() ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://akarat.com$imageUrl';
    }

    String agencyLogoUrl = agentsModel.agencyLogo?.trim() ?? '';
    if (agencyLogoUrl.isNotEmpty && !agencyLogoUrl.startsWith('http')) {
      agencyLogoUrl = 'https://akarat.com$agencyLogoUrl';
    }

    bool isValidImage = imageUrl.isNotEmpty &&
        imageUrl.toLowerCase() != 'n/a' &&
        imageUrl.toLowerCase() != 'null' &&
        (imageUrl.toLowerCase().endsWith('.jpg') ||
            imageUrl.toLowerCase().endsWith('.png') ||
            imageUrl.toLowerCase().endsWith('.jpeg') ||
            imageUrl.toLowerCase().endsWith('.webp')) &&
        !imageUrl.toLowerCase().contains('default-image.jpg');

    bool isValidLogo = agencyLogoUrl.isNotEmpty &&
        agencyLogoUrl.toLowerCase() != 'n/a' &&
        agencyLogoUrl.toLowerCase() != 'null' &&
        (agencyLogoUrl.toLowerCase().endsWith('.jpg') ||
            agencyLogoUrl.toLowerCase().endsWith('.jpeg') ||
            agencyLogoUrl.toLowerCase().endsWith('.png') ||
            agencyLogoUrl.toLowerCase().endsWith('.webp'));

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Agent photo
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: isValidImage
                      ? NetworkImage(imageUrl)
                      : const AssetImage('assets/images/profile.png') as ImageProvider,
                ),
                const SizedBox(width: 12),

                // Info + Sale/Rent
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      Text(
                        "${agentsModel.propertiesCount} Properties",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3A7CED),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      Text(
                        "Speaks: ${agentsModel.languages.isNotEmpty ? agentsModel.languages : 'N/A'}",
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Container(
                            width: 55,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40000000),
                                  spreadRadius: 0,
                                  blurRadius: 2,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "${agentsModel.sale} Sale",
                                style: const TextStyle(
                                  fontFamily: "Radio Canada Big",
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF3A7CED),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 55,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40000000),
                                  spreadRadius: 0,
                                  blurRadius: 2,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "${agentsModel.rent} Rent",
                                style: const TextStyle(
                                  fontFamily: "Raleway",
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF3A7CED),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
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

                // Agency Logo
                if (isValidLogo)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        agencyLogoUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
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
