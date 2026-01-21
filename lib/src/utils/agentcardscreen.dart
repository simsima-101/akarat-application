import 'package:flutter/material.dart';

import '../core/constants/constants.dart' as ApiService;
import '../features/agency/data/models/agents_model.dart';
import '../screen/about_agent.dart';


class Agentcardscreen extends StatelessWidget {
  final AgentsModel agentsModel;

  const Agentcardscreen({super.key, required this.agentsModel});

  @override
  Widget build(BuildContext context) {
    // Helper to build full image URL using ApiService base
    String _getFullImageUrl(String? path) {
      if (path == null || path.trim().isEmpty) return '';

      final trimmed = path.trim();

      // Already absolute URL → use as is
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }

      // Relative path → prepend current base URL from ApiService
      return ApiService.baseUrl.replaceAll('/api', '') + trimmed;
      // or more safe:
      // return '${ApiService.baseUrl.replaceAll(RegExp(r'/api/?$'), '')}$trimmed';
    }

    final String imageUrl = _getFullImageUrl(agentsModel.image);
    final String agencyLogoUrl = _getFullImageUrl(agentsModel.agencyLogo);

    // Validation helpers (you can keep or simplify)
    bool isValidImage = imageUrl.isNotEmpty &&
        !imageUrl.toLowerCase().contains('n/a') &&
        !imageUrl.toLowerCase().contains('null') &&
        (imageUrl.toLowerCase().endsWith('.jpg') ||
            imageUrl.toLowerCase().endsWith('.jpeg') ||
            imageUrl.toLowerCase().endsWith('.png') ||
            imageUrl.toLowerCase().endsWith('.webp')) &&
        !imageUrl.toLowerCase().contains('default-image.jpg');

    bool isValidLogo = agencyLogoUrl.isNotEmpty &&
        !agencyLogoUrl.toLowerCase().contains('n/a') &&
        !agencyLogoUrl.toLowerCase().contains('null') &&
        (agencyLogoUrl.toLowerCase().endsWith('.jpg') ||
            agencyLogoUrl.toLowerCase().endsWith('.jpeg') ||
            agencyLogoUrl.toLowerCase().endsWith('.png') ||
            agencyLogoUrl.toLowerCase().endsWith('.webp'));

    return GestureDetector(
      onTap: () {
        if (agentsModel.id == null || agentsModel.id.toString().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Agent ID not available")),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AboutAgent(
              data: agentsModel.id.toString(),
            ),
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

                // Info section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agentsModel.name ?? 'Unknown Agent',
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
                        "${agentsModel.propertiesCount ?? 0} Properties",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3A7CED),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Speaks: ${agentsModel.languages?.trim().isNotEmpty == true ? agentsModel.languages : 'N/A'}",
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (agentsModel.sale != null && agentsModel.sale! > 0)
                            _buildTag("${agentsModel.sale} Sale"),
                          const SizedBox(width: 10),
                          if (agentsModel.rent != null && agentsModel.rent! > 0)
                            _buildTag("${agentsModel.rent} Rent"),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (agentsModel.bio?.trim().isNotEmpty == true)
                        Text(
                          agentsModel.bio!.trim(),
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
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.business,
                          size: 40,
                          color: Colors.grey,
                        ),
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

  Widget _buildTag(String text) {
    return Container(
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
          text,
          style: const TextStyle(
            fontFamily: "Radio Canada Big", // ← keep your font or unify
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3A7CED),
          ),
        ),
      ),
    );
  }
}