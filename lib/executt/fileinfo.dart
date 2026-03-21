import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:send/executt/succesverfc.dart';

import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';
import 'homepage.dart';

class Infopage extends StatefulWidget {
  final String token;
  const Infopage({super.key, required this.token});

  @override
  State<Infopage> createState() => _InfopageState();
}

class _InfopageState extends State<Infopage> {
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _boatNameController = TextEditingController();
  final _registrationController = TextEditingController();
  final _homePortController = TextEditingController();
  final _licenseController = TextEditingController();
  final _expiryController = TextEditingController();
  
  String _selectedvesselType = "Trawler";
  File? _fishingLicenseFile;
  File? _boatRegistrationFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _boatNameController.dispose();
    _registrationController.dispose();
    _homePortController.dispose();
    _licenseController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isLicense) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isLicense) {
          _fishingLicenseFile = File(pickedFile.path);
        } else {
          _boatRegistrationFile = File(pickedFile.path);
        }
      });
    }
  }

  void _submit() {
    if (_fullNameController.text.isEmpty || _boatNameController.text.isEmpty || _licenseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    context.read<AuthCubit>().submitSetup(
      token: widget.token,
      fullName: _fullNameController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      boatName: _boatNameController.text.trim(),
      registrationNumber: _registrationController.text.trim(),
      vesselType: _selectedvesselType,
      homePort: _homePortController.text.trim(),
      licenseNumber: _licenseController.text.trim(),
      expiryDate: _expiryController.text.trim(),
      fishingLicense: _fishingLicenseFile,
      boatRegistration: _boatRegistrationFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Setup", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SetupSuccess) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SetupLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  number: "1",
                  title: "Personal Information",
                  children: [
                    _label("Full Name"),
                    customTextField("Enter your full name", _fullNameController),
                    const SizedBox(height: 16),
                    _label("National ID/Passport"),
                    customTextField("Enter National Id", _nationalIdController),
                    const SizedBox(height: 16),
                    _label("Phone Number"),
                    customTextField("Enter your phone number", _phoneController),
                    const SizedBox(height: 16),
                    _label("Email Address"),
                    customTextField("Enter your Email address", _emailController),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  number: "2",
                  title: "Boat details",
                  children: [
                    _label("Boat Name"),
                    customTextField("Enter your Boat name", _boatNameController),
                    const SizedBox(height: 16),
                    _label("Registration Number"),
                    customTextField("Enter your Registration Number", _registrationController),
                    const SizedBox(height: 16),
                    _label("Home Port"),
                    portTextField("City, Port Name", _homePortController),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  number: "3",
                  title: "Licenses & Documents",
                  children: [
                    _label("Primary License"),
                    customTextField("LIC-00-1122", _licenseController),
                    const SizedBox(height: 16),
                    _label("Expiry Date"),
                    customTextField("mm/dd/yyyy", _expiryController),
                    const SizedBox(height: 24),
                    const Text("Required Uploads (PDF or JPG)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF033F78))),
                    const SizedBox(height: 16),
                    _buildUploadTile(Icons.description, "Fishing License", _fishingLicenseFile, () => _pickFile(true)),
                    const SizedBox(height: 12),
                    _buildUploadTile(Icons.directions_boat, "Boat Registration", _boatRegistrationFile, () => _pickFile(false)),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF033F78),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: MaterialButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VetInspectionPage(token: widget.token, batchId: '',)));
                  },child: const Text("Complete Setup", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),)
                ),
                const SizedBox(height: 24),
                _buildFooterText(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String number, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 15, backgroundColor: const Color(0xFF033F78), child: Text(number, style: const TextStyle(color: Colors.white))),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)));

  Widget _buildUploadTile(IconData icon, String title, File? file, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF033F78)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(file != null ? file.path.split('/').last : "Not uploaded", 
                     style: TextStyle(color: file != null ? Colors.green : Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3F2FD),
              foregroundColor: const Color(0xFF033F78),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(file != null ? "Change" : "Upload"),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(fontSize: 11, color: Colors.grey),
          children: [
            TextSpan(text: "By completing setup, you agree to Finder's "),
            TextSpan(text: "Terms of Maritime Service", style: TextStyle(color: Color(0xFF0D2B55), decoration: TextDecoration.underline)),
            TextSpan(text: " and Safety Guidelines."),
          ],
        ),
      ),
    );
  }
}

Widget customTextField(String hint, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );
}

Widget portTextField(String hint, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.location_on, color: Colors.lightBlueAccent),
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );
}
