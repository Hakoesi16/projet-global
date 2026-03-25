import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'succesverfc.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';

class SetupVitpage extends StatefulWidget {
  final String token;
  const SetupVitpage({super.key, required this.token});

  @override
  State<SetupVitpage> createState() => _SetupVitpageState();
}

class _SetupVitpageState extends State<SetupVitpage> {
  final _fullNameVitController = TextEditingController();
  final _nationalIdVitController = TextEditingController();
  final _phoneVitController = TextEditingController();
  final _emailVitController = TextEditingController();
  final _boatNameVitController = TextEditingController();
  final _registrationVitController = TextEditingController();
  final _homePortVitController = TextEditingController();
  final _licenseVitController = TextEditingController();
  final _expiryVitController = TextEditingController();
  File? _fishingLicenseFileVit;
  File? _boatRegistrationFileVit;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _fullNameVitController.dispose();
    _nationalIdVitController.dispose();
    _phoneVitController.dispose();
    _emailVitController.dispose();
    _boatNameVitController.dispose();
    _registrationVitController.dispose();
    _homePortVitController.dispose();
    _licenseVitController.dispose();
    _expiryVitController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isLicense) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isLicense) {
          _fishingLicenseFileVit = File(pickedFile.path);
        } else {
          _boatRegistrationFileVit = File(pickedFile.path);
        }
      });
    }
  }

  void _submit() {
    context.read<AuthCubit>().submitSetupVit(
      token: widget.token,
      fullNameVit: _fullNameVitController.text.trim(),
      nationalIdVit: _nationalIdVitController.text.trim(),
      phoneVit: _phoneVitController.text.trim(),
      emailVit: _emailVitController.text.trim(),
      boatNameVit: _boatNameVitController.text.trim(),
      registrationNumberVit: _registrationVitController.text.trim(),
      homePortVit: _homePortVitController.text.trim(),
      licenseNumberVit: _licenseVitController.text.trim(),
      expiryDateVit: _expiryVitController.text.trim(),
      fishingLicenseVit: _fishingLicenseFileVit,
      boatRegistrationVit: _boatRegistrationFileVit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SetupSuccess) {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VetInspectionPage(token: widget.token, batchId: "NEW-BATCH")));
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is SetupLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressBar(isDark),
                const SizedBox(height: 24),
                _buildSection("1", "Personal Information", [
                  _label("Full Name"),
                  customTextField("e.g. Dr Ahmed ..", _fullNameVitController, isDark),
                  const SizedBox(height: 16),
                  _label("National ID / Passport"),
                  customTextField("ID Number", _nationalIdVitController, isDark),
                  const SizedBox(height: 16),
                  _label("Phone Number"),
                  customTextField("+213 674854088", _phoneVitController, isDark),
                  const SizedBox(height: 16),
                  _label("Email Address"),
                  customTextField("Projet@esi-sba.dz", _emailVitController, isDark),
                ], isDark),
                const SizedBox(height: 20),
                _buildSection("2", "Boat Details", [
                  _label("Boat Name"),
                  customTextField("Sea's King", _boatNameVitController, isDark),
                  const SizedBox(height: 16),
                  _label("Registration Number"),
                  customTextField("REG-8829-X", _registrationVitController, isDark),
                  const SizedBox(height: 16),
                  _label("Home Port"),
                  portTextField("City, Port Name", _homePortVitController, isDark),
                ], isDark),
                const SizedBox(height: 20),
                _buildSection("3", "Licenses & Documents", [
                  _label("Primary License #"),
                  customTextField("LIC-00-1122", _licenseVitController, isDark),
                  const SizedBox(height: 16),
                  _label("Expiry Date"),
                  customTextField("mm/dd/yyyy", _expiryVitController, isDark),
                  const SizedBox(height: 24),
                  const Text("Required Uploads (PDF or JPG)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildUploadTile(Icons.description, "Fishing License", _fishingLicenseFileVit, () => _pickFile(true), isDark),
                  const SizedBox(height: 12),
                  _buildUploadTile(Icons.directions_boat, "Boat Registration", _boatRegistrationFileVit, () => _pickFile(false), isDark),
                ], isDark),
                const SizedBox(height: 32),
                _buildCompleteButton(),
                const SizedBox(height: 24),
                _buildFooterText(isDark),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Profile Completion", style: TextStyle(color: isDark ? const Color(0xFF01A896) : const Color(0xFF013D73), fontWeight: FontWeight.bold)),
              const Text("65%", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: 0.65, backgroundColor: isDark ? Colors.white12 : const Color(0xFFF1F5F9), valueColor: const AlwaysStoppedAnimation(Color(0xFF01A896))),
        ],
      ),
    );
  }

  Widget _buildSection(String number, String title, List<Widget> children, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 15, backgroundColor: const Color(0xFF01A896), child: Text(number, style: const TextStyle(color: Colors.white))),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)));

  Widget _buildUploadTile(IconData icon, String title, File? file, VoidCallback onTap, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? Colors.white10 : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF01A896)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(file != null ? file.path.split('/').last : "Not uploaded", style: const TextStyle(fontSize: 12, color: Colors.grey))]),
          ),
          ElevatedButton(onPressed: onTap, child: Text(file != null ? "Change" : "Upload")),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF01A896), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: const Text("Complete Setup", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFooterText(bool isDark) {
    return Center(child: Text("By completing setup, you agree to Terms and Safety Guidelines.", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 12), textAlign: TextAlign.center));
  }
}

Widget customTextField(String hint, TextEditingController controller, bool isDark) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? Colors.white12 : const Color(0xFFF8FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    ),
  );
}

Widget portTextField(String hint, TextEditingController controller, bool isDark) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF01A896)),
      hintText: hint,
      filled: true,
      fillColor: isDark ? Colors.white12 : const Color(0xFFF8FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    ),
  );
}
