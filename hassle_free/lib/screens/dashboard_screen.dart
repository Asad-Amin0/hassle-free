import 'dart:async';
import 'package:flutter/material.dart';
import 'resume_screen.dart';
import 'employer_dashboard_screen.dart';
import 'jobs_screen.dart';
import 'profile_screen.dart';
import 'interview_screen.dart';
import '../services/resume_service.dart';

class MainDashboardScreen extends StatefulWidget {
  final bool isJobSeeker;
  const MainDashboardScreen({super.key, this.isJobSeeker = true});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late bool _isJobSeeker;
  String _userName = ""; // Removed "Sarah" as default
  late AnimationController _bgAnimationController;
  StreamSubscription? _resumeSubscription;

  @override
  void initState() {
    super.initState();
    _isJobSeeker = widget.isJobSeeker;
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _subscribeToUserData();
  }

  void _subscribeToUserData() {
    _resumeSubscription = ResumeService().getLatestResumeAnalysisStream().listen(
      (data) {
        if (data != null && data['name'] != null) {
          if (mounted) {
            setState(() {
              _userName = data['name'];
            });
          }
        }
      },
      onError: (error) {
        debugPrint('Error in Dashboard stream: $error');
      },
    );
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _resumeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1100) {
          return _buildMobileLayout(context);
        } else {
          return _buildWebLayout(context);
        }
      },
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Slate
      body: Row(
        children: [
          Container(
            width: 260,
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B26F2), Color(0xFF9042F6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HASSLE-FREE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'AI Recruitment',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                if (_isJobSeeker) ...[
                  _buildSidebarItem(0, Icons.dashboard_rounded, 'Dashboard'),
                  _buildSidebarItem(1, Icons.business_center_outlined, 'Jobs'),
                  _buildSidebarItem(2, Icons.description_outlined, 'Resume'),
                  _buildSidebarItem(3, Icons.video_call_outlined, 'Interview'),
                  _buildSidebarItem(4, Icons.person_outline, 'Profile'),
                ] else ...[
                  _buildSidebarItem(0, Icons.dashboard_rounded, 'Dashboard'),
                  _buildSidebarItem(1, Icons.business_center_outlined, 'Job Postings'),
                  _buildSidebarItem(2, Icons.business_outlined, 'Company'),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upgrade to Pro',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Get unlimited AI features',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Upgrade Now',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF020617), // Deep Dark Body
              child: _buildSelectedScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedScreen() {
    if (!_isJobSeeker) {
      switch (_selectedIndex) {
        case 1:
          return const Center(
            child: Text(
              "Job Postings Screen\n(Coming Soon)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        case 2:
          return const Center(
            child: Text(
              "Company Profile Screen\n(Coming Soon)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        default:
          return const EmployerDashboardScreen();
      }
    }

    switch (_selectedIndex) {
      case 1:
        return const JobsScreen();
      case 2:
        return ResumeScreen(
          onNameExtracted: (name) {
            setState(() {
              _userName = name;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Welcome, $_userName! Name extracted successfully.",
                ),
                backgroundColor: const Color(0xFF3B26F2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        );
      case 3:
        return const InterviewScreen();
      case 4:
        return const ProfileScreen();
      default:
        return Stack(
          children: [
            _buildLiveBackground(),
            SingleChildScrollView(child: _buildDashboardContent()),
          ],
        );
    }
  }

  Widget _buildDashboardContent() {
    bool isMobile = MediaQuery.of(context).size.width < 1100;
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://api.dicebear.com/7.x/avataaars/png?seed=${_userName.isEmpty ? "default" : _userName}',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: isMobile ? 240 : 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                  Color(0xFF06B6D4),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: isMobile ? 24 : 40,
                  top: isMobile ? 24 : 40,
                  right: isMobile ? 24 : 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'AI-Powered Insights',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _userName.isNotEmpty
                            ? 'Welcome back, $_userName! 👋'
                            : 'Welcome back! 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 28 : 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                Positioned(
                  top: -40,
                  right: -40,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: 150,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: isMobile ? 12 : 16,
                  left: isMobile ? 24 : 40,
                  right: isMobile ? 24 : 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBannerStat('24', 'Applications'),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                        icon: const Icon(
                          Icons.business_center_outlined,
                          size: 18,
                        ),
                        label: const Text(
                          'View Jobs',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended Jobs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 1),
                child: const Text(
                  'See all',
                  style: TextStyle(color: Color(0xFF6366F1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCompactJobCard(
                  'Senior UI Designer',
                  'Creative Inc',
                  'Remote',
                ),
                const SizedBox(width: 16),
                _buildCompactJobCard('Full Stack Dev', 'TechFlow', 'USA'),
                const SizedBox(width: 16),
                _buildCompactJobCard('Product Lead', 'Innova', 'London'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Your Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: isMobile ? 1 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isMobile ? 2.8 : 2.5,
            children: [
              _buildStatCard(
                'Applications',
                '24',
                Icons.business_center,
                const Color(0xFF3B82F6),
                '+12% this week',
              ),
              _buildStatCard(
                'Offers',
                '1',
                Icons.check_circle_outline,
                const Color(0xFF22C55E),
                'New!',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'HASSLE-FREE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: const [],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndexMap(_selectedIndex),
        onTap: (index) {
          setState(() {
            _selectedIndex = _reverseIndexMap(index);
          });
        },
        backgroundColor: const Color(0xFF0F172A),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        items: _isJobSeeker
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.description_outlined),
                  activeIcon: Icon(Icons.description),
                  label: 'Resume',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_center_outlined),
                  activeIcon: Icon(Icons.business_center),
                  label: 'Jobs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_call_outlined),
                  activeIcon: Icon(Icons.video_call),
                  label: 'Interview',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_center_outlined),
                  activeIcon: Icon(Icons.business_center),
                  label: 'Postings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_outlined),
                  activeIcon: Icon(Icons.business),
                  label: 'Company',
                ),
              ],
      ),
      body: _buildSelectedScreen(),
    );
  }

  // Maps unified _selectedIndex to mobile bottom nav index
  int _selectedIndexMap(int index) {
    if (!_isJobSeeker) {
      if (index > 2) return 0;
      return index;
    }
    if (index == 0) return 0; // Dashboard
    if (index == 2) return 1; // Resume
    if (index == 1) return 2; // Jobs
    if (index == 3) return 3; // Interview
    if (index == 4) return 4; // Profile
    return 0;
  }

  // Maps mobile bottom nav index back to unified _selectedIndex
  int _reverseIndexMap(int mobileIndex) {
    if (!_isJobSeeker) return mobileIndex;
    if (mobileIndex == 0) return 0; // Dashboard
    if (mobileIndex == 1) return 2; // Resume
    if (mobileIndex == 2) return 1; // Jobs
    if (mobileIndex == 3) return 3; // Interview
    if (mobileIndex == 4) return 4; // Profile
    return 0;
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF3B26F2), Color(0xFF9042F6)],
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerStat(String value, String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _bgAnimationController,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned(
                top: 100 + (20 * _bgAnimationController.value),
                left: -50 + (30 * _bgAnimationController.value),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 80 - (30 * _bgAnimationController.value),
                right: -100 + (50 * _bgAnimationController.value),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompactJobCard(String title, String company, String location) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            company,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 12,
                color: Colors.white60,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
