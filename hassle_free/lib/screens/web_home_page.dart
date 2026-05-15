import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key});

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _demoKey = GlobalKey();
  final GlobalKey _employersKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 20 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 20 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }
  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.1,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  void _showDemoVideo() {
    showDialog(
      context: context,
      builder: (context) => const _VideoPlayerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: _buildHeader(),
      drawer: _buildMobileDrawer(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HeroSection(onWatchDemo: _showDemoVideo),
            FeaturesSection(
              key: _featuresKey,
              onLearnMore: () => _scrollToSection(_howItWorksKey),
            ),
            HowItWorksSection(key: _howItWorksKey),
            DemoShowcase(key: _demoKey),
            EmployersSection(key: _employersKey),
            TestimonialsSection(key: _testimonialsKey),
            const CTASection(),
            const Footer(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: _isScrolled ? Colors.white.withValues(alpha: 0.8) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: _isScrolled ? Colors.grey.withValues(alpha: 0.2) : Colors.transparent,
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  // Logo
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _scrollController.animateTo(0,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutQuart),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'HASSLE-FREE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Nav Items
                  if (MediaQuery.of(context).size.width > 900) ...[
                    _navItem('Features', () => _scrollToSection(_featuresKey)),
                    _navItem('How It Works', () => _scrollToSection(_howItWorksKey)),
                    _navItem('For Employers', () => _scrollToSection(_employersKey)),
                    _navItem('Testimonials', () => _scrollToSection(_testimonialsKey)),
                    const SizedBox(width: 40),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                      child: Text('Sign In', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen(initialIsJobSeeker: true))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Get Started Free', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                    ),
                  ] else
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.sparkles, color: Colors.white, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'HASSLE-FREE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem('Features', LucideIcons.layers, () {
                    Navigator.pop(context);
                    _scrollToSection(_featuresKey);
                  }),
                  _drawerItem('How It Works', LucideIcons.helpCircle, () {
                    Navigator.pop(context);
                    _scrollToSection(_howItWorksKey);
                  }),
                  _drawerItem('For Employers', LucideIcons.briefcase, () {
                    Navigator.pop(context);
                    _scrollToSection(_employersKey);
                  }),
                  _drawerItem('Testimonials', LucideIcons.messageSquare, () {
                    Navigator.pop(context);
                    _scrollToSection(_testimonialsKey);
                  }),
                  const Divider(indent: 20, endIndent: 20),
                  _drawerItem('Sign In', LucideIcons.logIn, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  }),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen(initialIsJobSeeker: true)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Get Started Free', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64748B)),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
      ),
      onTap: onTap,
    );
  }
}

class HeroSection extends StatefulWidget {
  final VoidCallback onWatchDemo;
  const HeroSection({super.key, required this.onWatchDemo});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/demo_video.mp4');
    await _controller.initialize();
    await _controller.setVolume(0);
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
      showControls: false,
      aspectRatio: 16 / 9,
      allowMuting: true,
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1000;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: size.height),
      child: Stack(
        children: [
          // Dynamic Mesh Background (Highly Polished)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
                ),
              ),
              child: Stack(
                children: [
                  // Animated Mesh Orbs
                  Positioned(
                    top: -200,
                    right: -100,
                    child: _floatingOrb(800, const Color(0xFF6366F1).withValues(alpha: 0.12), duration: 10),
                  ),
                  Positioned(
                    bottom: -150,
                    left: -100,
                    child: _floatingOrb(700, const Color(0xFF06B6D4).withValues(alpha: 0.1), duration: 8),
                  ),
                  Positioned(
                    top: size.height * 0.3,
                    left: size.width * 0.05,
                    child: _floatingOrb(400, const Color(0xFF8B5CF6).withValues(alpha: 0.08), duration: 12),
                  ),
                  Positioned(
                    top: size.height * 0.1,
                    right: size.width * 0.2,
                    child: _floatingOrb(300, const Color(0xFFD946EF).withValues(alpha: 0.06), duration: 15),
                  ),
                  // Grid Pattern Overlay
                  Opacity(
                    opacity: 0.03,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.only(top: 140, left: isDesktop ? 80 : 20, right: isDesktop ? 80 : 20, bottom: 80),
            child: Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, color: Color(0xFF6366F1), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'AI-POWERED RECRUITMENT 2.0',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF6366F1),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().moveX(begin: -20, end: 0),
                      const SizedBox(height: 32),
                      
                      // Headline
                      RichText(
                        textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Revolutionize Your ',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF0F172A),
                                fontSize: isDesktop ? 72 : 48,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            TextSpan(
                              text: 'Career Path',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: isDesktop ? 72 : 48,
                                fontWeight: FontWeight.w900,
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                  ).createShader(const Rect.fromLTWH(0, 0, 400, 70)),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).moveY(begin: 30, end: 0),
                      const SizedBox(height: 24),
                      
                      Text(
                        'Unlock your potential with our AI-driven platform. From smart resume building to realistic mock interviews, we provide everything you need to land your dream job.',
                        textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF64748B),
                          fontSize: 20,
                          height: 1.6,
                        ),
                      ).animate().fadeIn(delay: 400.ms).moveY(begin: 30, end: 0),
                      const SizedBox(height: 48),
                      
                      // Buttons
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
                        children: [
                          _primaryButton('Start Hiring', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen(initialIsJobSeeker: false)))),
                          _secondaryButton('Watch Demo', widget.onWatchDemo),
                        ],
                      ).animate().fadeIn(delay: 600.ms).moveY(begin: 30, end: 0),
                    ],
                  ),
                ),
                if (isDesktop) const SizedBox(width: 60),
                if (isDesktop)
                  Expanded(
                    flex: 6,
                    child: _HeroImageStack().animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton(String text, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _secondaryButton(String text, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0F172A),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_outline, size: 24),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _floatingOrb(double size, Color color, {int duration = 4}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .moveY(begin: -20, end: 20, duration: duration.seconds, curve: Curves.easeInOut)
     .moveX(begin: -10, end: 10, duration: (duration + 1).seconds, curve: Curves.easeInOut);
  }
}

class _HeroImageStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Main Dashboard Preview
        _DeviceMockup(
          child: _LandingImage(
            assetPath: 'assets/images/seeker_dashboard.png',
            fallbackUrl: 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20192736-NqYT7e5iAxP21dvNWEDqpAielx96bZ.png',
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
         .moveY(begin: 0, end: -15, duration: 5.seconds, curve: Curves.easeInOut),
        
        // Floating Card 1: Employability Score
        Positioned(
          top: -40,
          right: -20,
          child: _floatingGlassCard(
            icon: Icons.speed,
            title: '92%',
            subtitle: 'Employability Score',
            color: const Color(0xFF10B981),
          ),
        ).animate().fadeIn(delay: 1200.ms).moveX(begin: 30, end: 0),
        
        // Floating Card 2: AI Match
        Positioned(
          bottom: 40,
          left: -40,
          child: _floatingGlassCard(
            icon: Icons.check_circle,
            title: 'Perfect Match',
            subtitle: 'Software Engineer',
            color: const Color(0xFF6366F1),
          ),
        ).animate().fadeIn(delay: 1400.ms).moveX(begin: -30, end: 0),
      ],
    );
  }
  Widget _floatingGlassCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18, color: const Color(0xFF0F172A))),
              Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}

class FeaturesSection extends StatelessWidget {
  final VoidCallback onLearnMore;
  const FeaturesSection({super.key, required this.onLearnMore});

  final List<Map<String, dynamic>> _features = const [
    {'icon': LucideIcons.fileText, 'title': 'AI Resume Parsing', 'description': 'Advanced NLP extracts qualifications.', 'color': Color(0xFF6366F1)},
    {'icon': LucideIcons.brain, 'title': 'Smart Matching', 'description': 'ML algorithms find perfect roles.', 'color': Color(0xFF06B6D4)},
    {'icon': LucideIcons.video, 'title': 'AI Interviews', 'description': 'Get real-time feedback easily.', 'color': Color(0xFF10B981)},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/white-diamond-dark.png'),
          opacity: 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        children: [
          // Section Header
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'POWERFUL FEATURES',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Everything you need to succeed',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isDesktop ? 56 : 36,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF06B6D4)]),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ).animate().fadeIn().moveY(begin: 30, end: 0),
          const SizedBox(height: 80),
          
          // Features Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
              crossAxisSpacing: 32,
              mainAxisSpacing: 32,
              childAspectRatio: 1,
            ),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              final feature = _features[index];
              return _HoverCard(
                onTap: onLearnMore,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white),
                    image: const DecorationImage(
                      image: NetworkImage('https://www.transparenttextures.com/patterns/white-diamond-dark.png'),
                      opacity: 0.03,
                      repeat: ImageRepeat.repeat,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon with Glow
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: (feature['color'] as Color).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          Icon(feature['icon'], color: feature['color'], size: 32),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        feature['title'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        feature['description'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                          height: 1.7,
                        ),
                      ),
                      const Spacer(),
                      // Learn More Link
                      Row(
                        children: [
                          Text(
                            'Learn more',
                            style: GoogleFonts.plusJakartaSans(
                              color: feature['color'],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: feature['color'], size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 100),
          
          // Stats Bar (Glassmorphic)
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withValues(alpha: 0.9),
                      const Color(0xFF06B6D4).withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: isDesktop ? 120 : 40,
                  runSpacing: 40,
                  children: [
                    _statBarItem(LucideIcons.trendingUp, '40%', 'Faster Hiring'),
                    _statBarItem(LucideIcons.award, '90%', 'Accuracy Rate'),
                    _statBarItem(LucideIcons.users, '10K+', 'Active Users'),
                    _statBarItem(LucideIcons.target, '500+', 'Partner Companies'),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).moveY(begin: 40, end: 0),
        ],
      ),
    );
  }

  Widget _statBarItem(IconData icon, String val, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 20),
        Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2)),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {
        'number': '01',
        'icon': LucideIcons.upload,
        'title': 'Upload Your Resume',
        'description': 'Simply upload your resume and our AI will automatically parse and analyze your professional profile.',
        'image': 'assets/images/resume_analysis.png',
      },
      {
        'number': '02',
        'icon': LucideIcons.search,
        'title': 'Get Matched with Jobs',
        'description': 'Our intelligent matching system finds the best opportunities based on your skills and preferences.',
        'image': 'assets/images/seeker_dashboard.png',
      },
      {
        'number': '03',
        'icon': LucideIcons.video,
        'title': 'Practice Interviews',
        'description': 'Prepare with AI-powered mock interviews that provide real-time feedback and improvement tips.',
        'image': 'assets/images/ai_interview.png',
      },
      {
        'number': '04',
        'icon': LucideIcons.checkCircle,
        'title': 'Land Your Dream Job',
        'description': 'Apply confidently with your improved profile and get hired by top companies.',
        'image': 'assets/images/candidate_profile.png',
      },
    ];

    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
      child: Column(
        children: [
          // Header
          Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'How It ',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0F172A),
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Works',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Get started in minutes with our simple 4-step process to transform your job search experience.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontSize: 18,
                ),
              ),
            ],
          ).animate().fadeIn().moveY(begin: 30, end: 0),
          
          const SizedBox(height: 80),
          
          // Steps
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (context, index) => const SizedBox(height: 100),
            itemBuilder: (context, index) {
              final step = steps[index];
              final isEven = index % 2 == 0;
              
              return Row(
                children: [
                  if (isDesktop && !isEven) _stepImage(step['image'], step['number']),
                  if (isDesktop && !isEven) const SizedBox(width: 80),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isDesktop ? (isEven ? CrossAxisAlignment.start : CrossAxisAlignment.start) : CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
                          children: [
                            Text(step['number'], style: GoogleFonts.plusJakartaSans(fontSize: 60, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1).withValues(alpha: 0.1))),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF06B6D4)]),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(step['icon'], color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step['title'],
                          style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step['description'],
                          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(fontSize: 18, color: const Color(0xFF64748B), height: 1.6),
                        ),
                        if (!isDesktop) const SizedBox(height: 32),
                        if (!isDesktop) _stepImage(step['image'], step['number']),
                      ],
                    ),
                  ),
                  
                  if (isDesktop && isEven) const SizedBox(width: 80),
                  if (isDesktop && isEven) _stepImage(step['image'], step['number']),
                ],
              ).animate().fadeIn(delay: (index * 200).ms).moveY(begin: 50, end: 0);
            },
          ),
        ],
      ),
    );
  }

  Widget _stepImage(String url, String id) {
    return Expanded(
      child: _DeviceMockup(
        child: _LandingImage(
          assetPath: url,
          fallbackUrl: _getHowItWorksFallback(id),
        ),
      ),
    );
  }

  String? _getHowItWorksFallback(String id) {
    switch (id) {
      case '01': return 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20192842-WQgqQ23Gi9dnJ9PKZkUolU7U2TujdV.png';
      case '02': return 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20192736-NqYT7e5iAxP21dvNWEDqpAielx96bZ.png';
      case '03': return 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20193016-PowjYPqupsyxl6hZWrFDmTQ7Ezun1h.png';
      case '04': return 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20193208-KYmhXLi0SPT2vSrkXHmJ6laTxIN7Ej.png';
      default: return null;
    }
  }
}

class DemoShowcase extends StatefulWidget {
  const DemoShowcase({super.key});

  @override
  State<DemoShowcase> createState() => _DemoShowcaseState();
}

class _DemoShowcaseState extends State<DemoShowcase> {
  String _activeTab = 'dashboard';
  
  final List<Map<String, dynamic>> _screenshots = [
    {
      'id': 'dashboard',
      'title': 'Job Seeker Dashboard',
      'description': 'Your personalized career hub with activity tracking and job recommendations',
      'image': 'assets/images/seeker_dashboard.png',
    },
    {
      'id': 'resume',
      'title': 'Resume Analysis',
      'description': 'AI-powered resume parsing with skill extraction and professional insights',
      'image': 'assets/images/resume_analysis.png',
    },
    {
      'id': 'interview',
      'title': 'AI Interview',
      'description': 'Practice with our AI interviewer featuring real-time feedback and avatar interaction',
      'image': 'assets/images/ai_interview.png',
    },
    {
      'id': 'profile',
      'title': 'Employability Score',
      'description': 'Complete professional profile with AI-driven employability scoring',
      'image': 'assets/images/candidate_profile.png',
    },
    {
      'id': 'employer',
      'title': 'Employer Dashboard',
      'description': 'Powerful recruitment tools with AI-powered candidate scoring and match tracking',
      'image': 'assets/images/employer_dashboard.png',
    },
    {
      'id': 'video',
      'title': 'Video Tour',
      'description': 'Watch a quick overview of how HASSLE-FREE simplifies recruitment for everyone.',
      'image': 'video',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeScreenshot = _screenshots.firstWhere((s) => s['id'] == _activeTab);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      child: Column(
        children: [
          // Header
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.monitor, color: Color(0xFF10B981), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Platform Preview',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'See ',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0F172A),
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'HASSLE-FREE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                          ).createShader(const Rect.fromLTWH(0, 0, 400, 70)),
                      ),
                    ),
                    TextSpan(
                      text: ' in Action',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0F172A),
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn().moveY(begin: 30, end: 0),
          
          const SizedBox(height: 48),
          
          // Tabs
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: _screenshots.map((screen) {
              final isActive = _activeTab == screen['id'];
              return InkWell(
                onTap: () => setState(() => _activeTab = screen['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isActive ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF06B6D4)]) : null,
                    color: isActive ? null : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: isActive ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] : null,
                  ),
                  child: Text(
                    screen['title'],
                    style: GoogleFonts.plusJakartaSans(
                      color: isActive ? Colors.white : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 64),
          
          // Screenshot Display
          Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: _activeTab == 'video' 
              ? _buildVideoPreview()
              : _DeviceMockup(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _LandingImage(
                      assetPath: activeScreenshot['image'],
                      fallbackUrl: _getFallbackUrl(activeScreenshot['id']),
                    ),
                  ),
                ),
          ).animate(key: ValueKey(_activeTab)).fadeIn(duration: 400.ms),
          
          const SizedBox(height: 32),
          
          Text(
            activeScreenshot['description'],
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 18, color: const Color(0xFF64748B)),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  String? _getFallbackUrl(String id) {
    switch (id) {
      case 'dashboard': return 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20192736-NqYT7e5iAxP21dvNWEDqpAielx96bZ.png';
      case 'resume': return 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20192842-WQgqQ23Gi9dnJ9PKZkUolU7U2TujdV.png';
      case 'interview': return 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20193016-PowjYPqupsyxl6hZWrFDmTQ7Ezun1h.png';
      case 'profile': return 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20193208-KYmhXLi0SPT2vSrkXHmJ6laTxIN7Ej.png';
      case 'employer': return 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20193454-SV0KPdviuzU13l2K6xdpbwTjWjUIFb.png';
      default: return null;
    }
  }

  Widget _buildVideoPreview() {
    return _DeviceMockup(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: const _MutedAutoplayVideo(
            url: 'assets/videos/demo_video.mp4',
          ),
        ),
      ),
    );
  }
}

class _MutedAutoplayVideo extends StatefulWidget {
  final String url;
  const _MutedAutoplayVideo({required this.url});

  @override
  State<_MutedAutoplayVideo> createState() => _MutedAutoplayVideoState();
}

class _MutedAutoplayVideoState extends State<_MutedAutoplayVideo> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.url.startsWith('assets/')
        ? VideoPlayerController.asset(widget.url)
        : VideoPlayerController.networkUrl(Uri.parse(widget.url));
    
    _controller.initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller.setVolume(0);
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              if (_controller.value.volume == 0)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.volume_off, color: Colors.white, size: 20),
                  ),
                ),
            ],
          )
        : const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
  }
}

class EmployersSection extends StatelessWidget {
  const EmployersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> benefits = [
      'AI-powered candidate scoring with bias-free evaluation',
      'Automated resume parsing and skill extraction',
      'Smart shortlisting based on job requirements',
      'Real-time analytics and hiring insights',
      'Video interview recordings with AI analysis',
      'Customizable job postings and applicant filters',
    ];

    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      child: Row(
        children: [
          if (isDesktop)
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(0, 20)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: const _LandingImage(
                        assetPath: 'assets/images/employer_dashboard.png',
                        fallbackUrl: 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20193454-SV0KPdviuzU13l2K6xdpbwTjWjUIFb.png',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    right: -20,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF06B6D4)]),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.check, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('90%', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                              Text('Match Accuracy', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).scale(),
                  ),
                ],
              ).animate().fadeIn().moveX(begin: -50, end: 0),
            ),
          
          if (isDesktop) const SizedBox(width: 80),
          
          Expanded(
            child: Column(
              crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.building2, color: Color(0xFF06B6D4), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'For Employers',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF06B6D4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                RichText(
                  textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hire Smarter with\n',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF0F172A),
                          fontSize: isDesktop ? 48 : 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'AI-Powered',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isDesktop ? 48 : 32,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                            ).createShader(const Rect.fromLTWH(0, 0, 400, 70)),
                        ),
                      ),
                      TextSpan(
                        text: ' Recruitment',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF0F172A),
                          fontSize: isDesktop ? 48 : 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Reduce hiring costs by 40% and find the perfect candidates faster with our intelligent recruitment dashboard.',
                  textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, color: const Color(0xFF64748B), height: 1.6),
                ),
                const SizedBox(height: 32),
                ...benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.check, color: Color(0xFF10B981), size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(benefit, style: GoogleFonts.plusJakartaSans(fontSize: 16, color: const Color(0xFF0F172A)))),
                    ],
                  ),
                )),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen(initialIsJobSeeker: false))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Start Hiring', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.arrowRight),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn().moveX(begin: 50, end: 0),
          ),
        ],
      ),
    );
  }
}

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> testimonials = [
      {
        'name': 'Waleed Tariq',
        'role': 'Software Developer',
        'company': 'Devsinc',
        'avatar': 'W',
        'rating': 5,
        'text': 'HASSLE-FREE completely transformed my job search. The AI resume analysis helped me identify gaps I never knew existed, and the mock interviews boosted my confidence significantly.',
        'gradient': [const Color(0xFF6366F1), const Color(0xFF06B6D4)],
      },
      {
        'name': 'Sarah Ahmed',
        'role': 'HR Manager',
        'company': 'TechCorp Pakistan',
        'avatar': 'S',
        'rating': 5,
        'text': 'As a recruiter, this platform has cut our hiring time in half. The AI scoring system is incredibly accurate and helps us focus on the best candidates immediately.',
        'gradient': [const Color(0xFF06B6D4), const Color(0xFF10B981)],
      },
      {
        'name': 'Hassan Ali',
        'role': 'Fresh Graduate',
        'company': 'UCP Lahore',
        'avatar': 'H',
        'rating': 5,
        'text': "Being a fresh graduate was tough, but HASSLE-FREE's employability score gave me a clear roadmap. I landed my first job within a month of using the platform!",
        'gradient': [const Color(0xFF10B981), const Color(0xFF6366F1)],
      },
    ];

    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      color: const Color(0xFFF1F5F9).withValues(alpha: 0.3),
      child: Column(
        children: [
          // Header
          Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Loved by ',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0F172A),
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Thousands',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                          ).createShader(const Rect.fromLTWH(0, 0, 400, 70)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'See what our users are saying about their experience with HASSLE-FREE.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontSize: 18,
                ),
              ),
            ],
          ).animate().fadeIn().moveY(begin: 30, end: 0),
          
          const SizedBox(height: 64),
          
          // Testimonials Grid
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: testimonials.asMap().entries.map((entry) {
              final index = entry.key;
              final t = entry.value;
              return Container(
                width: isDesktop ? 350 : double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.orange, size: 20)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '"${t['text']}"',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, color: const Color(0xFF0F172A), height: 1.6, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: t['gradient']),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(t['avatar'], style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t['name'], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                              Text(
                                '${t['role']} at ${t['company']}',
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF64748B)),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (index * 100).ms).moveY(begin: 30, end: 0);
            }).toList(),
          ),
          
          const SizedBox(height: 80),
          
          // Trust Indicators
          Text(
            'Trusted by leading organizations',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 60,
            runSpacing: 24,
            children: ['University of Central Punjab', 'Devsinc', 'Systems Limited', 'TechCorp', 'i2c Inc'].map((company) {
              return Text(
                company,
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)),
              );
            }).toList(),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class CTASection extends StatelessWidget {
  const CTASection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      child: Container(
        padding: const EdgeInsets.all(64),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 20)),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Ready to Transform\nYour Career Journey?',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: isDesktop ? 56 : 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Join thousands of job seekers and employers who are already experiencing the future of recruitment. Start your hassle-free journey today.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen(initialIsJobSeeker: true))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Text('Get Started Free', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.arrowRight),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ctaBadge('No credit card required'),
                const SizedBox(width: 24),
                _ctaBadge('Free forever plan'),
                const SizedBox(width: 24),
                _ctaBadge('Setup in 2 minutes'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctaBadge(String label) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.white60, size: 16),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 14)),
      ],
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF06B6D4)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'HASSLE-FREE',
                          style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'AI-powered recruitment platform simplifying the job search and hiring process for everyone.',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 16, height: 1.6),
                    ),
                  ],
                ),
              ),
              if (isDesktop) const Spacer(),
              if (isDesktop) ...[
                _footerColumn('Platform', ['Features', 'Interviews', 'Resumes', 'Job Board']),
                const SizedBox(width: 60),
                _footerColumn('Company', ['About Us', 'Contact', 'Privacy Policy', 'Terms']),
                const SizedBox(width: 60),
                _footerColumn('Resources', ['Blog', 'Success Stories', 'Guides', 'Support']),
              ],
            ],
          ),
          const SizedBox(height: 64),
          const Divider(color: Color(0xFF1E293B)),
          const SizedBox(height: 32),
          Row(
            children: [
              Text('© 2026 HASSLE-FREE. All rights reserved.', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 14)),
              const Spacer(),
              Row(
                children: [
                  _socialIcon(Icons.facebook),
                  const SizedBox(width: 16),
                  _socialIcon(Icons.camera_alt),
                  const SizedBox(width: 16),
                  _socialIcon(Icons.link),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(link, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 14)),
        )),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _HoverCard({required this.child, this.onTap});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: _isHovered ? Matrix4.translationValues(0, -10, 0) : Matrix4.identity(),
          child: widget.child,
        ),
      ),
    );
  }
}

class _DeviceMockup extends StatelessWidget {
  final Widget child;
  const _DeviceMockup({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                _dot(const Color(0xFFFF5F56)),
                const SizedBox(width: 8),
                _dot(const Color(0xFFFFBD2E)),
                const SizedBox(width: 8),
                _dot(const Color(0xFF27C93F)),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Text(
                        'hasslefree.ai/dashboard',
                        style: GoogleFonts.inter(fontSize: 9, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _LandingImage extends StatelessWidget {
  final String assetPath;
  final String? fallbackUrl;

  const _LandingImage({
    required this.assetPath,
    this.fallbackUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        if (fallbackUrl != null) {
          return Image.network(
            fallbackUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingPlaceholder();
            },
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        }
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 400,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 400,
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.image, color: Colors.grey.shade300, size: 48),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Please add $assetPath to your assets folder',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerDialog extends StatefulWidget {
  const _VideoPlayerDialog();

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/demo_video.mp4')
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller.setVolume(0); // Start muted
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 1000,
        constraints: const BoxConstraints(maxHeight: 650),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.play_circle_outline, color: Color(0xFF6366F1), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('Platform Demo', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                clipBehavior: Clip.antiAlias,
                child: _isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_controller),
                            _buildControls(),
                          ],
                        ),
                      )
                    : const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white60, size: 16),
                  const SizedBox(width: 8),
                  Text('Video is muted by default for a smoother experience.', style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 13)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => setState(() => _controller.setVolume(_controller.value.volume == 0 ? 1 : 0)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Icon(_controller.value.volume == 0 ? Icons.volume_off : Icons.volume_up, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        child: VideoProgressIndicator(_controller, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Color(0xFF6366F1))),
      ),
    );
  }
}
