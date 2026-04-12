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
    final Uri uri = Uri.parse(url ?? "https://www.orimi.com/pdf-test.pdf");
    // "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      // Utilisation de la couleur de fond du thème
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // Utilisation des couleurs du thème pour l'AppBar
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Vet Inspection",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF011A33), 
            fontWeight: FontWeight.bold
          ),
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
                  _buildStatusCard(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Batch Identity", isDark),
                  const SizedBox(height: 12),
                  _buildIdentityCard(data, isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Expiration Date", isDark),
                  const SizedBox(height: 12),
                  _buildExpirationCard(data["expiryDate"], data["timeLeft"], isDark),
                  const SizedBox(height: 24),
                  _buildActionCard(
                    icon: Icons.picture_as_pdf_outlined,
                    title: "Digital certificate",
                    subtitle: "PDF format - 1.2 MB",
                    actionIcon: Icons.download_outlined,
                    onTap: () => _downloadCertificate(data["pdfUrl"]),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.remove_red_eye_outlined,
                    title: "View Batch Report",
                    subtitle: "",
                    actionIcon: Icons.open_in_new_outlined,
                    onTap: () {},
                    isDark: isDark,
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

  Widget _buildStatusCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        // On garde l'aspect vert même en dark mode mais on l'adapte
        color: isDark ? const Color(0xFF004D40) : const Color(0xFF98E2C6),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF006F63),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 30),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "APPROVED",
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF006F63),
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "PROTOCOL VERIFICATION PASSED",
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF006F63),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF011A33),
      ),
    );
  }

  Widget _buildIdentityCard(Map<String, dynamic> data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), 
            blurRadius: 10
          )
        ],
      ),
      child: Column(
        children: [
          _buildIdentityItem("BATCH ID", data["batchId"], isDark),
          const Divider(height: 32),
          _buildIdentityItem("FISHER NAME", data["fisherName"], isDark),
          const Divider(height: 32),
          _buildIdentityItem("FISH TYPE", data["fishType"], isDark),
        ],
      ),
    );
  }

  Widget _buildIdentityItem(String label, String value, bool isDark) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF011A33))),
          ],
        ),
      ],
    );
  }

  Widget _buildExpirationCard(String date, String timeLeft, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: Color(0xFF00C2A0)),
          const SizedBox(width: 16),
          Text(
            date,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
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

  Widget _buildActionCard({required bool isDark, required IconData icon, required String title, String? subtitle, required IconData actionIcon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF00C2A0)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black)),
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
