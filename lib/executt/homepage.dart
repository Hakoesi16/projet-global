import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';
import 'begin.dart';

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchHomeData(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HomeDataLoaded) {
              final data = state.data;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(data["userName"]),
                    const SizedBox(height: 24),
                    _buildAddBatchCard(),
                    const SizedBox(height: 16),
                    _buildQuickActions(isDark),
                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.analytics_outlined, "Performance Overview"),
                    const SizedBox(height: 12),
                    _buildPerformanceGrid(data, isDark),
                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.inventory_2_outlined, "Batch Status Tracker"),
                    const SizedBox(height: 12),
                    _buildStatusTracker(data, isDark),
                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.storefront_outlined, "Market Highlights", trailing: "View Market"),
                    const SizedBox(height: 12),
                    _buildMarketCard(data["marketItem"], isDark),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            }
            return const Center(child: Text("Error loading data"));
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.person, color: Color(0xFF013D73)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome back,", style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
          child: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }

  Widget _buildAddBatchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF013D73),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.add_box_outlined, color: Colors.white, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add New Batch", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Log your latest catch", style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildActionItem(Icons.anchor, "Register Arrival")),
        const SizedBox(width: 16),
        Expanded(child: _buildActionItem(Icons.list_alt, "My Batches")),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF013D73), size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, {String? trailing}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF013D73), size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (trailing != null) Text(trailing, style: const TextStyle(color: Color(0xFF013D73), fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildPerformanceGrid(Map<String, dynamic> data, bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildStatCard("TOTAL EARNINGS", data["earnings"], data["earningsTrend"])),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("TOTAL WEIGHT", data["weight"], data["weightTrend"])),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String trend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FittedBox(child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Text(trend, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTracker(Map<String, dynamic> data, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: [
        _buildStatusItem(Icons.access_time, data["pendingBatches"].toString(), "Pending", const Color(0xFFFFB038)),
        _buildStatusItem(Icons.check_circle_outline, data["approvedBatches"].toString(), "Approved", const Color(0xFF4CAF50)),
        _buildStatusItem(Icons.cancel_outlined, data["rejectedBatches"].toString(), "Rejected", const Color(0xFFFF5252)),
        _buildStatusItem(Icons.history, data["expiredBatches"].toString(), "Expired", const Color(0xFF7B8D9E)),
      ],
    );
  }

  Widget _buildStatusItem(IconData icon, String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketCard(Map<String, dynamic> item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network('https://via.placeholder.com/60', width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${item["grade"]} - ${item["demand"]}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(item["price"], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF013D73))),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                      child: Text(item["tag"], style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home, color: isDark ? Colors.white : const Color(0xFF013D73), size: 28),
          Icon(Icons.anchor, color: Colors.grey.shade400, size: 28),
          Icon(Icons.storefront, color: Colors.grey.shade400, size: 28),
          Icon(Icons.remove_red_eye, color: Colors.grey.shade400, size: 28),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(token: widget.token))),
            child: Icon(Icons.person_outline, color: Colors.grey.shade400, size: 28),
          ),
        ],
      ),
    );
  }
}
