import 'package:app/auth/google_auth.dart';
import 'package:app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _backgroundAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _backgroundAnimation =
        ColorTween(begin: Color(0xFF1E3A8A), end: Color(0xFF1E40AF)).animate(
          CurvedAnimation(
            parent: _backgroundController,
            curve: Curves.easeInOut,
          ),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(color: _backgroundAnimation.value),
            child: Stack(
              children: [
                // Animated background particles
                ...List.generate(
                  15,
                  (index) => AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      final progress =
                          (_particleController.value + index * 0.1) % 1.0;
                      final size = 4.0 + (index % 3) * 2.0;
                      final opacity = (0.1 + (index % 4) * 0.1);

                      return Positioned(
                        left:
                            (screenWidth * (0.1 + (index % 8) * 0.1)) +
                            math.sin(progress * 2 * math.pi + index) * 50,
                        top: MediaQuery.of(context).size.height * progress,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(opacity),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Floating geometric shapes
                ...List.generate(
                  8,
                  (index) => AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      final progress =
                          (_particleController.value * 0.5 + index * 0.15) %
                          1.0;
                      final size = 20.0 + (index % 3) * 15.0;
                      final rotation = progress * 2 * math.pi;

                      return Positioned(
                        right:
                            (50.0 + (index % 5) * 100.0) +
                            math.cos(progress * math.pi + index) * 30,
                        bottom: MediaQuery.of(context).size.height * progress,
                        child: Transform.rotate(
                          angle: rotation,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(
                                index % 2 == 0 ? size / 2 : 8.0,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height,
                            maxWidth: isLargeScreen
                                ? 500
                                : (isMediumScreen ? 450 : 400),
                          ),
                          child: IntrinsicHeight(
                            child: Container(
                              margin: EdgeInsets.all(isLargeScreen ? 48 : 32),
                              child: Center(
                                child: Card(
                                  elevation: 24,
                                  shadowColor: Colors.black.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        isLargeScreen ? 40 : 28,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // App Logo with enhanced styling
                                          Container(
                                            height: isLargeScreen ? 140 : 120,
                                            width: isLargeScreen ? 140 : 120,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF3B82F6),
                                              borderRadius:
                                                  BorderRadius.circular(90),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(
                                                    0xFF3B82F6,
                                                  ).withOpacity(0.3),
                                                  blurRadius: 20,
                                                  offset: Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(90),
                                              child: Image.asset(
                                                'assets/app_logo.png',
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        decoration:
                                                            BoxDecoration(
                                                              color: Color(
                                                                0xFF3B82F6,
                                                              ),
                                                            ),
                                                        child: Icon(
                                                          Icons.sailing,
                                                          size: isLargeScreen
                                                              ? 80
                                                              : 60,
                                                          color: Colors.white,
                                                        ),
                                                      );
                                                    },
                                              ),
                                            ),
                                          ),

                                          SizedBox(height: 24),

                                          // Welcome Text
                                          Text(
                                            'Welcome Back',
                                            style: GoogleFonts.inter(
                                              fontSize: isLargeScreen ? 24 : 20,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.grey.shade600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),

                                          SizedBox(height: 6),

                                          // App Name with enhanced styling
                                          Text(
                                            'BluVoyage',
                                            style: GoogleFonts.montserrat(
                                              fontSize: isLargeScreen ? 36 : 30,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1E40AF),
                                              letterSpacing: 1.2,
                                            ),
                                          ),

                                          SizedBox(height: 12),

                                          Text(
                                            'Your journey begins here',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Colors.grey.shade500,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),

                                          SizedBox(height: 36),

                                          // Enhanced Google Sign-In Button
                                          MouseRegion(
                                            onEnter: (_) => setState(
                                              () => _isHovering = true,
                                            ),
                                            onExit: (_) => setState(
                                              () => _isHovering = false,
                                            ),
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 200,
                                              ),
                                              transform: Matrix4.identity()
                                                ..scale(
                                                  _isHovering ? 1.02 : 1.0,
                                                ),
                                              child: Container(
                                                width: double.infinity,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: _isHovering
                                                      ? Color(0xFF3B82F6)
                                                      : Colors.white,
                                                  border: Border.all(
                                                    color: _isHovering
                                                        ? Colors.transparent
                                                        : Colors.grey.shade300,
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: _isHovering
                                                          ? Color(
                                                              0xFF3B82F6,
                                                            ).withOpacity(0.3)
                                                          : Colors.grey
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                      blurRadius: _isHovering
                                                          ? 20
                                                          : 10,
                                                      offset: Offset(
                                                        0,
                                                        _isHovering ? 8 : 4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: ElevatedButton.icon(
                                                  icon: _isHovering
                                                      ? Icon(
                                                          Icons.login,
                                                          color: Colors.white,
                                                          size: 24,
                                                        )
                                                      : Image.asset(
                                                          'assets/google_logo.png',
                                                          height: 24,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Icon(
                                                                  Icons
                                                                      .g_mobiledata,
                                                                  size: 24,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600,
                                                                );
                                                              },
                                                        ),
                                                  label: Text(
                                                    _isHovering
                                                        ? 'Continue your journey'
                                                        : 'Sign in with Google',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: _isHovering
                                                          ? Colors.white
                                                          : Colors
                                                                .grey
                                                                .shade700,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    foregroundColor:
                                                        Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    // TODO: Add Google sign-in logic
                                                    signInWithGoogle()
                                                        .then((userCredential) {
                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  HomeScreen(),
                                                            ),
                                                          );
                                                        })
                                                        .catchError((error) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Sign-in failed: $error',
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),

                                          SizedBox(height: 20),

                                          // Footer text
                                          Text(
                                            'By continuing, you agree to our Terms & Privacy Policy',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
