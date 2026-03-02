import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';
import 'begin.dart'; // Import pour ProfilePage

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeDataLoaded) {
              final data = state.data;
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(data["userName"]),
                          const SizedBox(height: 24),
                          _buildAddBatchCard(),
                          const SizedBox(height: 16),
                          _buildQuickActions(),
                          const SizedBox(height: 24),
                          _buildSectionHeader(Icons.analytics_outlined, "Performance Overview"),
                          const SizedBox(height: 12),
                          _buildPerformanceGrid(data),
                          const SizedBox(height: 24),
                          _buildSectionHeader(Icons.inventory_2_outlined, "Batch Status Tracker"),
                          const SizedBox(height: 12),
                          _buildStatusTracker(data),
                          const SizedBox(height: 24),
                          _buildSectionHeader(Icons.storefront_outlined, "Market Highlights", trailing: "View Market"),
                          const SizedBox(height: 12),
                          _buildMarketCard(data["marketItem"]),
                          const SizedBox(height: 100), // Space for navbar
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text("Error loading data"));
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      color: Colors.white,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius:1)],),
      child: Row(
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
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF011A33))),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
            child: const Stack(
              children: [
                Icon(Icons.notifications_outlined, color: Colors.black),
                Positioned(
                  right: 2,
                  top: 2,
                  child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBatchCard() {
    return MaterialButton(onPressed: (){
      // Navigator.push(context, MaterialPageRoute(builder: (context) {
      //   return const AddBatchPage();
    },child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF013D73),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF013D73).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.add_box_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add New Batch", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Log your latest catch", style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    ),);
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionItem(Icons.anchor, "Register Arrival")),
        const SizedBox(width: 16),
        Expanded(child:MaterialButton(onPressed: (){
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return const MyBatchesPage();
          // },),);
        },child: _buildActionItem(Icons.list_alt, "My Batches"),)),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
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
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF011A33))),
        const Spacer(),
        if (trailing != null) Text(trailing, style: const TextStyle(color: Color(0xFF013D73), fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildPerformanceGrid(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(child: _buildStatCard("TOTAL EARNINGS", data["earnings"], data["earningsTrend"], Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("TOTAL WEIGHT", data["weight"], data["weightTrend"], Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String trend, Color trendColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FittedBox(child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.trending_up, size: 14, color: trendColor),
              const SizedBox(width: 4),
              Text(trend, style: TextStyle(color: trendColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTracker(Map<String, dynamic> data) {
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
        _buildStatusItem(Icons.history, "0${data["expiredBatches"]}", "Expired", const Color(0xFF7B8D9E)),
      ],
    );
  }

  Widget _buildStatusItem(IconData icon, String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
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

  Widget _buildMarketCard(Map<String, dynamic> item) {
    return MaterialButton(onPressed: (){
      // Navigator.push(context, MaterialPageRoute(builder: (context) {
      //   return const MarketPage();
    },child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://via.placeholder.com/60',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${item["grade"]} - ${item["demand"]}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item["price"],
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF013D73)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item["tag"],
                        style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),);
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => context.read<AuthCubit>().fetchHomeData(widget.token),
            child: _navIcon(Icons.home, true),
          ),
          _navIcon(Icons.anchor, false),
          _navIcon(Icons.storefront_outlined, false),
          _navIcon(Icons.remove_red_eye_outlined, false),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(token: widget.token)),
              );
            },
            child: _navIcon(Icons.person_outline, false),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, bool isActive) {
    return Icon(icon, color: isActive ? const Color(0xFF013D73) : Colors.grey.shade400, size: 28);
  }
}
