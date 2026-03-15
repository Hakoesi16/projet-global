import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';
import 'editeprofile.dart';
import 'homepage.dart';

class ProfilePage extends StatefulWidget {
  final String token;

  const ProfilePage({super.key, required this.token});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notifications = true;
  bool _darkMode = false;
  String _selectedLanguage = "English";

  // Dictionnaire de traduction
  final Map<String, Map<String, String>> _texts = {
    "English": {
      "profile": "Profile",
      "edit": "Edit Profile",
      "info": "ACCOUNT INFO",
      "settings": "SETTINGS",
      "notifications": "Notifications",
      "darkMode": "Dark Mode",
      "language": "Language",
      "documents": "DOCUMENTS",
      "upload": "Upload New",
      "password": "Change Password",
    },
    "Français": {
      "profile": "Profil",
      "edit": "Modifier le Profil",
      "info": "INFOS DU COMPTE",
      "settings": "PARAMÈTRES",
      "notifications": "Notifications",
      "darkMode": "Mode Sombre",
      "language": "Langue",
      "documents": "DOCUMENTS",
      "upload": "Enregistrer nouveau",
      "password": "Changer le mot de passe",
    },
    "العربية": {
      "profile": "الملف الشخصي",
      "edit": "تعديل الملف",
      "info": "معلومات الحساب",
      "settings": "الإعدادات",
      "notifications": "الإشعارات",
      "darkMode": "الوضع الليلي",
      "language": "اللغة",
      "documents": "المستندات",
      "upload": "تحميل جديد",
      "password": "تغيير كلمة السر",
    }
  };

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchProfile(widget.token);
  }

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedLanguage == "العربية" ? "اختر اللغة" : "Select Language",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _languageOption("English"),
              _languageOption("Français"),
              _languageOption("العربية"),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption(String lang) {
    return ListTile(
      title: Text(lang),
      trailing: _selectedLanguage == lang
          ? const Icon(Icons.check_circle, color: Color(0xFF013D73))
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = lang;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var t = _texts[_selectedLanguage]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(t["profile"]!, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(user, t),
                  const SizedBox(height: 24),
                  _buildSectionHeader(t["info"]!),
                  const SizedBox(height: 8),
                  _buildAccountInfoCard(user),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader(t["documents"]!),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: Text(t["upload"]!),
                      )
                    ],
                  ),
                  _buildDocumentsCard(user),
                  const SizedBox(height: 24),
                  _buildSectionHeader(t["settings"]!),
                  const SizedBox(height: 8),
                  _buildSettingsCard(t),
                  const SizedBox(height: 100),
                ],
              ),
            );
          }
          return const Center(child: Text("No Profile Data"));
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700, fontSize: 13),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> user, Map<String, String> t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFE3F2FD),
            backgroundImage: user["profilePicture"] != null ? NetworkImage(user["profilePicture"]) : null,
            child: user["profilePicture"] == null ? const Icon(Icons.person, size: 60, color: Color(0xFF013D73)) : null,
          ),
          const SizedBox(height: 12),
          Text(user["name"] ?? "Unknown", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("ID: ${user["id"] ?? "N/A"} | LICENSE: ${user["license"] ?? "N/A"}", style: const TextStyle(color: Color(0xFF64748B),fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(token: widget.token)));
                },
                icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                label: Text(t["edit"]!, style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF013D73),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                child: IconButton(onPressed: () {}, icon: const Icon(Icons.share, color: Colors.grey)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _infoTile(Icons.directions_boat, "Boat Name", user["boatName"] ?? "N/A", trailing: _statusBadge()),
          const Divider(),
          Row(
            children: [
              Expanded(child: _infoTile(null, "Registration", user["registration"] ?? "N/A")),
              Container(width: 1, height: 40, color: Colors.grey.shade400),
              Container(width: 7, height: 40),
              Expanded(child: _infoTile(null, "Home Port", user["homePort"] ?? "N/A")),
            ],
          ),
          const Divider(),
          _infoTile(Icons.email_outlined, "Email Address", user["email"] ?? "N/A"),
          const Divider(),
          _infoTile(Icons.calendar_today_outlined, "License Expiry", user["licenseExpiry"] ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(Map<String, dynamic> user) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _docTile(Icons.description, "Fishing License", "Valid until ${user["licenseExpiry"] ?? "N/A"}"),
          const Divider(height: 1),
          _docTile(Icons.directions_boat, "Boat Registration", "Verified on ${user["registration day"] ?? "N/A"}"),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(Map<String, String> t) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _settingsTile(Icons.lock_outline, t["password"]!, trailing: const Icon(Icons.chevron_right, color: Colors.grey)),
          const Divider(),
          _settingsTile(
            Icons.language, 
            t["language"]!, 
            trailing: Text("$_selectedLanguage >", style: const TextStyle(color: Colors.grey)),
            onTap: _showLanguageDialog,
          ),
          const Divider(),
          _settingsTile(Icons.notifications_none, t["notifications"]!,
              trailing: Switch(value: _notifications, activeThumbColor: const Color(0xFF013D73), onChanged: (v) => setState(() => _notifications = v))),
          const Divider(),
          _settingsTile(Icons.dark_mode_outlined, t["darkMode"]!,
              trailing: Switch(value: _darkMode, activeThumbColor: const Color(0xFF013D73), onChanged: (v) => setState(() => _darkMode = v))),
        ],
      ),
    );
  }

  Widget _infoTile(IconData? icon, String label, String value, {Widget? trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: icon != null ? Icon(icon, color: const Color(0xFF013D73)) : null,
      title: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12,fontWeight: FontWeight.w400)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      trailing: trailing,
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(5)),
      child: const Text("ACTIVE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _docTile(IconData icon, String title, String sub) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF013D73)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  Widget _settingsTile(IconData icon, String title, {required Widget trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF013D73)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(token: widget.token)));
          }, icon: const Icon(Icons.home_outlined, color: Colors.grey)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.anchor, color: Colors.grey)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_basket_outlined, color: Colors.grey)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.grey)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person, color: Color(0xFF013D73), size: 30)),
        ],
      ),
    );
  }
}
