import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  void _initializeApp() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    try {
      await appProvider.initUser();
      
      // Wait for animations to complete
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize app: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon/Logo
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.flight_takeoff,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // App Title Animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black26,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            'PRE A1 English Trip',
                            speed: const Duration(milliseconds: 100),
                          ),
                        ],
                        totalRepeatCount: 1,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Subtitle
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Your English Adventure Begins!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Hebrew Translation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'הרפתקת האנגלית שלך מתחילה!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white60,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Loading Animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Consumer<AppProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Text(
                              'Loading your journey...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            );
                          } else if (provider.error != null) {
                            return Text(
                              'Error: ${provider.error}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return const Text(
                              'Welcome aboard!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Travel Icons Animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTravelIcon(Icons.flight_takeoff, 0),
                      const SizedBox(width: 20),
                      _buildTravelIcon(Icons.language, 200),
                      const SizedBox(width: 20),
                      _buildTravelIcon(Icons.location_city, 400),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTravelIcon(IconData icon, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1000 + delay),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
