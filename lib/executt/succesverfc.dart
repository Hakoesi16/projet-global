import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';

class VetInspectionPage extends StatefulWidget {
  final String batchId;
  final String token;

  const VetInspectionPage({super.key, required this.batchId, required this.token});

  @override
  State<VetInspectionPage> createState() => _VetInspectionPageState();
}

class _VetInspectionPageState extends State<VetInspectionPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<AuthCubit>().fetchInspectionDetails(widget.batchId, widget.token);
  }

  Future<void> _downloadCertificate(String? url) async {
    final Uri uri = Uri.parse(url ?? "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch download")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF011A33)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Vet Inspection",
          style: TextStyle(color: Color(0xFF011A33), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InspectionDataLoaded) {
            final data = state.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Batch Identity"),
                  const SizedBox(height: 12),
                  _buildIdentityCard(data),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Expiration Date"),
                  const SizedBox(height: 12),
                  _buildExpirationCard(data["expiryDate"], data["timeLeft"]),
                  const SizedBox(height: 24),
                  _buildActionCard(
                    icon: Icons.picture_as_pdf_outlined,
                    title: "Digital certificate",
                    subtitle: "PDF format - 1.2 MB",
                    actionIcon: Icons.download_outlined,
                    onTap: () => _downloadCertificate(data["pdfUrl"]),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.remove_red_eye_outlined,
                    title: "View Batch Report",
                    subtitle: "",
                    actionIcon: Icons.open_in_new_outlined,
                    onTap: () {},
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ElevatedButton(
              onPressed: _loadData,
              child: const Text("Retry"),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF98E2C6), // Vert menthe de l'image
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3), // Carré arrondi clair
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF006F63),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "APPROVED",
            style: TextStyle(
              color: Color(0xFF006F63), // Texte vert foncé
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "PROTOCOL VERIFICATION PASSED",
            style: TextStyle(
              color: Color(0xFF006F63),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF011A33),
      ),
    );
  }

  Widget _buildIdentityCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildIdentityItem("BATCH ID", data["batchId"]),
          const Divider(height: 32),
          _buildIdentityItem("FISHER NAME", data["fisherName"]),
          const Divider(height: 32),
          _buildIdentityItem("FISH TYPE", data["fishType"]),
        ],
      ),
    );
  }

  Widget _buildIdentityItem(String label, String value) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF011A33))),
          ],
        ),
      ],
    );
  }

  Widget _buildExpirationCard(String date, String timeLeft) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: Color(0xFF00C2A0)),
          const SizedBox(width: 16),
          Text(
            date,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            "($timeLeft)",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Spacer(),
          const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, String? subtitle, required IconData actionIcon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF00C2A0)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (subtitle != null)
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(actionIcon, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
