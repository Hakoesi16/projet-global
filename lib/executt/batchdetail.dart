import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../cubit/authcubit.dart';
import '../cubit/authstate.dart';
import '../cubit/themecubit.dart';

class BatchDetailPage extends StatefulWidget {
  final String token;
  final String batchId;

  const BatchDetailPage({
    super.key,
    required this.token,
    required this.batchId,
  });

  @override
  State<BatchDetailPage> createState() => _BatchDetailPageState();
}

class _BatchDetailPageState extends State<BatchDetailPage> {
  double _quantity = 3.0;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchBatchById(widget.token, widget.batchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Batch details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthError) {
            return Center(child: Text(state.message));
          }

          if (state is BatchDetailLoaded) {
            return _buildContent(state.batch);
          }

          return const SizedBox();

        },

      ),
      bottomNavigationBar: _buildBottomNavBar(false),
    );
  }

  Widget _buildContent(Map<String, dynamic> batch) {
    // Données du backend
    final String name = batch['name'] ?? 'Unknown';
    final String category = batch['category'] ?? 'MARINE FISH';
    final double price = (batch['price'] ?? 0).toDouble();
    final double weight = (batch['weight'] ?? 0).toDouble();
    final String arrival = batch['arrival'] ?? '';
    final int freshnessScore = batch['freshnessScore'] ?? 0;
    final String shelfLife = batch['shelfLife'] ?? '0 H Left';
    final List<dynamic> photos = batch['photos'] ?? [];
    final String deliveryAddress = batch['deliveryAddress'] ?? '';

    final double totalPrice = _quantity * price;

    return SingleChildScrollView(
      child: Column(
        children: [

          // ── CAROUSEL PHOTOS ──
          _buildCarousel(photos),

          const SizedBox(height: 16),

          // ── INFOS PRINCIPALES ──
          _buildInfoCard(
            name, category, price, weight,
            arrival, freshnessScore, shelfLife,
          ),

          const SizedBox(height: 12),

          // ── DOCUMENTS ──
          _buildDocumentsCard(),

          const SizedBox(height: 12),

          // ── QUANTITE + PRIX TOTAL ──
          _buildQuantityCard(price, totalPrice, deliveryAddress),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // =====================
  //   CAROUSEL PHOTOS
  // =====================
  Widget _buildCarousel(List<dynamic> photos) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: PageView.builder(
              itemCount: photos.isEmpty ? 1 : photos.length,
              onPageChanged: (index) {
                setState(() => _currentImage = index);
              },
              itemBuilder: (context, index) {
                if (photos.isEmpty) {
                  return const Center(
                    child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                  );
                }
                return Stack(
                  children: [
                    // Photos latérales
                    if (index > 0)
                      Positioned(
                        left: 0,
                        top: 30,
                        child: _buildSideImage(photos[index - 1]),
                      ),
                    // Photo principale
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          photos[index],
                          width: 260,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 260,
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, size: 60),
                          ),
                        ),
                      ),
                    ),
                    // Icône agrandir
                    Positioned(
                      right: 70,
                      top: 16,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.fullscreen, color: Color(0xFFC9972A), size: 20),
                      ),
                    ),
                    // Photo suivante
                    if (index < photos.length - 1)
                      Positioned(
                        right: 0,
                        top: 30,
                        child: _buildSideImage(photos[index + 1]),
                      ),
                  ],
                );
              },
            ),
          ),

          // Indicateurs
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              photos.isEmpty ? 1 : photos.length,
                  (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == _currentImage ? 10 : 6,
                height: index == _currentImage ? 10 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentImage
                      ? const Color(0xFFC9972A)
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSideImage(dynamic photoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        photoUrl,
        width: 60,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 60,
          height: 160,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }

  // =====================
  //   INFOS PRINCIPALES
  // =====================
  Widget _buildInfoCard(
      String name,
      String category,
      double price,
      double weight,
      String arrival,
      int freshnessScore,
      String shelfLife,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Catégorie
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFC9972A)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFC9972A),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Nom + Prix
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${price.toStringAsFixed(2)} DA",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Poids + Per Kilogram
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$weight Kg Available",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Text(
                "Per Kilogram",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Arrival
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.anchor, color: Colors.grey.shade500, size: 18),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      "Arrival",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      arrival,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Freshness + Shelf Life
          Row(
            children: [

              // Freshness Score
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Overall Freshness Score",
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            "$freshnessScore/100",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: freshnessScore / 100,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFFC9972A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Shelf Life
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey.shade500, size: 20),
                      const SizedBox(height: 4),
                      const Text(
                        "Shelf Life",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        shelfLife,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================
  //   DOCUMENTS
  // =====================
  Widget _buildDocumentsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Digital Certificate
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf_outlined,
                    color: Color(0xFFC9972A)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Digital certificate",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text("PDF format - 1.2 MB",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.download_outlined, color: Colors.grey.shade500),
            ],
          ),

          const Divider(height: 24),

          // View Batch Report
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.remove_red_eye_outlined,
                    color: Color(0xFFC9972A)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text("View Batch Report",
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.open_in_new, color: Colors.grey.shade500),
              //tester share option
              ElevatedButton.icon(
                onPressed: () async {
                  await SharePlus.instance.share(
                    ShareParams(
                      text: "🐟 Découvre Let's Fishing !\n"
                          "L'app du marché de poisson en Algérie.\n\n"
                          "📱 Télécharge ici :\n"
                          "https://play.google.com/store/apps/details?id=com.example.projetsndcp\n\n"
                          "Rejoins-moi sur l'app !",
                      subject: "Let's Fishing App",
                    ),
                  );
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  "Partager l'app",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF013D73),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              //------------------------------------------
            ],
          ),
        ],
      ),
    );
  }

  // =====================
  //   QUANTITE + BOUTONS
  // =====================
  Widget _buildQuantityCard(
      double price, double totalPrice, String deliveryAddress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          // Quantité + Prix total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Boutons - quantité +
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_quantity > 1) {
                        setState(() => _quantity -= 0.5);
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.remove, size: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "${_quantity}kg",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _quantity += 0.5),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9972A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),

              // Prix total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${totalPrice.toStringAsFixed(2)} DA",
                    style: const TextStyle(
                      color: Color(0xFFC9972A),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Total Price",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Delivery address
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: Color(0xFFC9972A), size: 20),
              const SizedBox(width: 8),
              const Text(
                "Delivery to: ",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: Text(
                  deliveryAddress,
                  style: TextStyle(color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.edit_outlined,
                  color: Colors.grey.shade500, size: 18),
            ],
          ),

          const SizedBox(height: 16),

          // Boutons Add to cart + Buy now
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Add to cart",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9972A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Buy now",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(token: widget.token)));
          }, icon: Icon(Icons.home_outlined, color: isDark ? Colors.white54 : Colors.grey)),
          IconButton(onPressed: () {}, icon: Icon(Icons.list_alt_outlined, color: isDark ? Colors.white54 : Colors.grey)),
          IconButton(onPressed: () {}, icon: Icon(Icons.shopping_cart, color: isDark ? Colors.white54 : Colors.grey)),
          IconButton(onPressed: () {}, icon: Icon(Icons.person, color: isDark ? const Color(0xFF01A896) : const Color(0xFFD5A439), size: 30)),
        ],
      ),
    );
  }
}
