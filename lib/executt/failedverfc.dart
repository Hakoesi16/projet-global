import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';

class FailedvetPage extends StatefulWidget {
  final String batchId;
  final String token;

  const FailedvetPage({super.key, required this.batchId, required this.token});

  @override
  State<FailedvetPage> createState() => _FailedvetPageState();
}

class _FailedvetPageState extends State<FailedvetPage> {
  final TextEditingController _rejectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<AuthCubit>().fetchInspectionDetails(widget.batchId, widget.token);
  }

  @override
  void dispose() {
    _rejectionController.dispose();
    super.dispose();
  }

  void _submitRejection() {
    if (_rejectionController.text.isNotEmpty) {
      context.read<AuthCubit>().sendRejectionReason(
        batchId: widget.batchId,
        reason: _rejectionController.text,
        token: widget.token,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a rejection reason")),
      );
    }
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
                  _buildSectionTitle("Mandatory Rejection Reasons"),
                  const SizedBox(height: 12),
                  _buildRejectionInputCard(),
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
        color: const Color(0xFFF9B1B1), // Rose/Rouge clair selon l'image
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
              color: Colors.white.withValues(alpha: 0.2), // Rectangle arrondi pour l'icône
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.block, 
              color: Color(0xFFE53935), // Rouge foncé pour l'icône
              size: 45
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "REJECTED",
            style: TextStyle(
              color: Color(0xFFE53935), // Rouge foncé pour le texte
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "PROTOCOL VERIFICATION FAILED",
            style: TextStyle(
              color: Color(0xFFE53935),
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
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF011A33),
        ),
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

  Widget _buildRejectionInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _rejectionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Required only if rejecting batch...",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitRejection,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Send Rejection", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
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
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFE53935)),
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
