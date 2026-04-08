import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'succesverfc.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';

class SetupConspage extends StatefulWidget {
  final String token;
  const SetupConspage({super.key, required this.token});

  @override
  State<SetupConspage> createState() => _SetupConpageState();
}

class _SetupConpageState extends State<SetupConspage> {
  final _fullNameConsController = TextEditingController();
  final _nationalIdConsController = TextEditingController();
  final _phoneConsController = TextEditingController();
  final _emailConsController = TextEditingController();
  final _deleveryaddressConsController = TextEditingController();
  final _nearbyPortConsController = TextEditingController();

  @override
  void dispose() {
    _fullNameConsController.dispose();
    _nationalIdConsController.dispose();
    _phoneConsController.dispose();
    _emailConsController.dispose();
    _deleveryaddressConsController.dispose();
    _nearbyPortConsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_fullNameConsController.text.isEmpty || _deleveryaddressConsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    context.read<AuthCubit>().submitSetupCons(
      token: widget.token,
      fullNameCons: _fullNameConsController.text.trim(),
      nationalIdCons: _nationalIdConsController.text.trim(),
      phoneCons: _phoneConsController.text.trim(),
      emailCons: _emailConsController.text.trim(),
      delevryAddress: _deleveryaddressConsController.text.trim(),
      nearbyPortCons: _nearbyPortConsController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Setup", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SetupSuccess) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VetInspectionPage(token: widget.token, batchId: "CONSUMER-SETUP")));
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
                const SizedBox(height: 24),
                // Section 1: Personal Information
                _buildSection("1", "Personal Information", [
                  _label("Full Name"),
                  customTextField("e.g. hako ..", _fullNameConsController, isDark),
                  const SizedBox(height: 16),
                  _label("National ID / Passport"),
                  customTextField("ID Number", _nationalIdConsController, isDark),
                  const SizedBox(height: 16),
                  _label("Phone Number"),
                  customTextField("+213 674854088", _phoneConsController, isDark),
                  const SizedBox(height: 16),
                  _label("Email Address"),
                  customTextField("Projet@esi-sba.dz", _emailConsController, isDark),
                ], isDark),
                
                const SizedBox(height: 20),
                
                // Section 2: Delivery Details
                _buildSection("2", "Delivery Details", [
                  _label("Delivery Address"),
                  customTextField("eg..Rue El Wiam Sidi Bel Abbes", _deleveryaddressConsController, isDark),
                  const SizedBox(height: 16),
                  _label("Nearby Port"),
                  customTextField("eg..Oran Port", _nearbyPortConsController, isDark),
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
  
  Widget _buildSection(String number, String title, List<Widget> children, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15, 
                backgroundColor: const Color(0xFFD5A439),
                child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ),
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

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8), 
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
  );

  Widget _buildCompleteButton() {
    return ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD5A439), 
        minimumSize: const Size(double.infinity, 56), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
      ),
      child: const Text("Complete Setup", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFooterText(bool isDark) {
    return Center(
      child: Text(
        "By completing setup, you agree to Terms and Safety Guidelines.", 
        style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 12), 
        textAlign: TextAlign.center
      )
    );
  }
}

Widget customTextField(String hint, TextEditingController controller, bool isDark) {
  return TextField(
    controller: controller,
    style: TextStyle(color: isDark ? Colors.white : Colors.black),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
      filled: true,
      fillColor: isDark ? Colors.white10 : const Color(0xFFF8FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    ),
  );
}
