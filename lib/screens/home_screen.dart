import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/screens/profile_screen.dart';
import 'package:pemrograman_mobile/screens/settings_screen.dart';
import 'package:pemrograman_mobile/screens/statistics_screen.dart';

import '../services/expense_service.dart';
import 'add_expense_screen.dart';
import 'advanced_expense_list_screen.dart';
import 'category_screen.dart';
import 'expense_list_screen.dart';
import 'login_screen.dart';
import 'massages_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const Color pinkBg = Color(0xFFF8D7DA);
  static const Color pinkSoft = Color(0xFFF3B8C2);
  static const Color rose = Color(0xFFEE9CA7);
  static const Color roseDark = Color(0xFFD87A87);
  static const Color orangeAccent = Color(0xFFFF7D00);
  static const Color maroon = Color(0xFF451A2B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D1B2E);

  static const Color patternBg = Color(0xFFFEF7F8);

  final String userName = "Fakhira";
  int _currentIndex = 0;

  late AnimationController _animationController;
  Animation<double> _fadeAnimation = const AlwaysStoppedAnimation(1.0);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _initData();
  }

  Future<void> _initData() async {
    await ExpenseService.load();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _title {
    switch (_currentIndex) {
      case 0:
        return "Home";
      case 1:
        return "Expenses";
      case 2:
        return "Statistics";
      case 3:
        return "Profile";
      default:
        return "Home";
    }
  }

  // Fungsi untuk menghitung total pengeluaran hari ini
  double _todayTotal() {
    final now = DateTime.now();
    return ExpenseService.expenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // Fungsi untuk menghitung total pengeluaran bulan ini
  double _monthTotal() {
    final now = DateTime.now();
    return ExpenseService.expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // Fungsi untuk format rupiah
  String _formatRupiah(double value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // ✅ INI YANG PENTING: body pake switch biar rebuild tiap pindah tab
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return ExpenseListScreen(
          // key biar dianggap widget baru kalau jumlah data berubah
          key: ValueKey(DateTime.now().millisecondsSinceEpoch),
        );
      case 2:
        return const StatisticsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pinkBg,
      extendBody: true,

      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            fontSize: 22,
          ),
        ),
        backgroundColor: maroon,
        foregroundColor: white,
        elevation: 0,
        shadowColor: maroon.withOpacity(0.5),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: "Logout",
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 22),
            ),
          ),
        ],
      ),

      // ================= DRAWER =================
      drawer: Drawer(
        backgroundColor: white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [maroon, roseDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: maroon.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: maroon.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Welcome Back,",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Let's manage your finance efficiently",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.category_rounded,
                    title: 'Categories',
                    subtitle: 'Manage categories',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CategoryScreen()),
                      ).then((_) => setState(() {}));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.analytics_rounded,
                    title: 'Advanced Expenses',
                    subtitle: 'Detailed tracking',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdvancedExpenseListScreen(),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.message_rounded,
                    title: 'Messages',
                    subtitle: 'Message are shown here',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MessagesScreen(),
                        ),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                  ),
                  _buildDrawerItem(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Sign out from app',
                    color: orangeAccent,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ✅ body udah pake buildBody()
      body: _buildBody(),

      // FAB cuma muncul di tab Expenses
      floatingActionButton:
          (_currentIndex == 1)
              ? Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [roseDark, maroon],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: maroon.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: white.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(-3, -3),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddExpenseScreen(),
                      ),
                    ).then((result) async {
                      if (result == true) {
                        await ExpenseService.load();
                      }
                      if (!mounted) return;
                      setState(() {});
                    });
                  },
                  child: const Icon(Icons.add_rounded, size: 32, color: white),
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ====== BOTTOM NAVBAR ======
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: maroon.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, "Home", 0),
                _buildNavItem(Icons.attach_money_rounded, "Expenses", 1),
                _buildNavItem(Icons.bar_chart_rounded, "Stats", 2),
                _buildNavItem(Icons.person_rounded, "Profile", 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HOME TAB =================
  Widget _buildHomeTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // HEADER - TETAP DI ATAS
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [maroon, roseDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: maroon.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, $userName 👋",
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Ready to track your expenses today!",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: white.withOpacity(0.9),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: white.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ModernSummaryItem(
                          "This Month",
                          _formatRupiah(_monthTotal()),
                          Icons.calendar_month_rounded,
                        ),
                        const SizedBox(
                          height: 50,
                          child: VerticalDivider(
                            color: white,
                            thickness: 1,
                            indent: 5,
                            endIndent: 5,
                          ),
                        ),
                        _ModernSummaryItem(
                          "Today",
                          _formatRupiah(_todayTotal()),
                          Icons.today_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // CONTAINER PUTIH - YANG DISCROLL
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: patternBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Quick Access Title
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    decoration: const BoxDecoration(
                      color: patternBg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Quick Access",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22, // Sedikit lebih besar
                            fontWeight: FontWeight.w700,
                            color: darkText,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Manage your finances efficiently",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: darkText.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Grid Cards dengan scrolling yang tepat
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: GridView.count(
                        physics:
                            const BouncingScrollPhysics(), // Tambah physics untuk smooth scroll
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9, // Sedikit lebih tinggi
                        padding: const EdgeInsets.only(
                          bottom: 100,
                        ), // PERBAIKI: Tambah bottom padding
                        children: [
                          _buildModernCard(
                            context,
                            title: "Advanced\nExpenses",
                            subtitle: "Detailed tracking",
                            icon: Icons.analytics_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            const AdvancedExpenseListScreen(),
                                  ),
                                ).then((_) => setState(() {})),
                          ),
                          _buildModernCard(
                            context,
                            title: "Categories",
                            subtitle: "Manage categories",
                            icon: Icons.category_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CategoryScreen(),
                                  ),
                                ).then((_) => setState(() {})),
                          ),
                          _buildModernCard(
                            context,
                            title: "Settings",
                            subtitle: "App preferences",
                            icon: Icons.settings_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                ),
                          ),
                          _buildModernCard(
                            context,
                            title: "Messages",
                            subtitle: "Notification & messages",
                            icon: Icons.message_rounded,
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 142, 234, 102),
                                Color.fromARGB(255, 75, 162, 98),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MessagesScreen(),
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18), // Sedikit lebih besar
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48, // Sedikit lebih besar
                width: 48,
                decoration: BoxDecoration(
                  color: white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: white.withOpacity(0.3), width: 1.5),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: white,
                ), // Sedikit lebih besar
              ),
              const SizedBox(height: 16), // Sedikit lebih besar
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16, // Sedikit lebih besar
                  fontWeight: FontWeight.w700,
                  color: white,
                  letterSpacing: 0.2,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12, // Sedikit lebih besar
                  color: white.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? maroon.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected ? maroon : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? white : maroon.withOpacity(0.4),
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? maroon : maroon.withOpacity(0.4),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (color ?? maroon).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color ?? maroon, size: 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: color ?? darkText,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: (color ?? darkText).withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
          ),
          onTap: onTap,
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (color ?? maroon).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: color ?? maroon,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernSummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _ModernSummaryItem(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
