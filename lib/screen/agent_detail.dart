import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Akarat/services/api_service.dart';
import 'package:Akarat/model/agentdetaill.dart';
import 'package:url_launcher/url_launcher.dart';

class Agent_Detail extends StatefulWidget {
  const Agent_Detail({super.key, required this.data});
  final String data;

  @override
  State<Agent_Detail> createState() => _Agent_DetailState();
}

class _Agent_DetailState extends State<Agent_Detail> {
  AgentDetail? agentDetailModel;



  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    fetchAgentDetails(widget.data);
  }

  Future<void> fetchAgentDetails(String agentId) async {
    try {
      final jsonData = await ApiService.getAgentDetails(int.parse(agentId));
      final agentDetail = AgentDetail.fromJson(jsonData);

      if (mounted) {
        setState(() {
          agentDetailModel = agentDetail;
        });
      }

      print("✅ Agent Name: ${agentDetailModel?.name}");
    } catch (e) {
      print("❌ Failed to fetch agent details: $e");
    }
  }

  String phoneCallNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (input.startsWith('+971')) return input;
    if (input.startsWith('00971')) return '+971${input.substring(5)}';
    if (input.startsWith('971')) return '+971${input.substring(3)}';
    if (input.startsWith('0') && input.length == 10)
      return '+971${input.substring(1)}';
    if (input.length == 9) return '+971$input';
    return input;
  }

  String whatsAppNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d]'), '');
    if (input.startsWith('971')) return input;
    if (input.startsWith('00971')) return input.substring(2);
    if (input.startsWith('+971')) return input.substring(1);
    if (input.startsWith('0') && input.length == 10)
      return '971${input.substring(1)}';
    if (input.length == 9) return '971$input';
    return input;
  }

  @override
  Widget build(BuildContext context) {
    if (agentDetailModel == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Agent Details"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agent Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                agentDetailModel!.image ?? "https://via.placeholder.com/100",
              ),
            ),
            const SizedBox(height: 16),
            Text(
              agentDetailModel!.name ?? "",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(agentDetailModel!.email ?? "", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(agentDetailModel!.agency ?? "", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(agentDetailModel!.address ?? "", style: const TextStyle(fontSize: 16)),
            const Divider(height: 32),

            // More Info
            _buildInfoRow("Languages", agentDetailModel!.languages),
            _buildInfoRow("Expertise", agentDetailModel!.expertise),
            _buildInfoRow("Experience", "${agentDetailModel!.experience} years"),
            _buildInfoRow("Broker Reg. No.", agentDetailModel!.brokerRegisterationNumber),
            _buildInfoRow("Service Areas", agentDetailModel!.serviceAreas),
            _buildInfoRow("Sales", "${agentDetailModel!.sale ?? 0}"),
            _buildInfoRow("Rent", "${agentDetailModel!.rent ?? 0}"),
            const SizedBox(height: 20),

            // Contact Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text("Call"),
                  onPressed: () async {
                    final phone = phoneCallNumber(agentDetailModel!.phone ?? '');
                    final url = Uri.parse("tel:$phone");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      print("❌ Could not launch phone call.");
                    }
                  },
                ),
                ElevatedButton.icon(
                  icon: Image.asset("assets/images/whats.png", height: 20),
                  label: const Text("WhatsApp"),
                  onPressed: () async {
                    final phone = whatsAppNumber(agentDetailModel!.whatsapp ?? '');
                    final message = Uri.encodeComponent("Hello");
                    final waUrl = Uri.parse("https://wa.me/$phone?text=$message");

                    if (await canLaunchUrl(waUrl)) {
                      await launchUrl(waUrl);
                    } else {
                      print("❌ Could not launch WhatsApp.");
                    }
                  },
                ),

                ElevatedButton.icon(
                  icon: const Icon(Icons.email),
                  label: const Text("Email"),
                  onPressed: () async {
                    final emailUri = Uri(
                      scheme: 'mailto',
                      path: agentDetailModel!.email,
                      query: 'subject=Property Inquiry&body=Hi, I saw your agent profile on Akarat.',
                    );
                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    } else {
                      print("❌ Could not launch email.");
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
