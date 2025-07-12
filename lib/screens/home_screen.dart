import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';
import '../models/workbook_content.dart';
import 'workbook_section_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  void _setupAnimations() {
    _progressAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _confettiController.dispose();
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
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStorySection(),
              _buildProgressSection(),
              Expanded(child: _buildSectionsList()),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.homeTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.dashboard,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'מסעו של דוד לניו יורק',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flight_takeoff,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'David\'s Journey',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Follow David as he travels from Tel Aviv to New York, learning English along the way!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'עקוב אחר דוד בזמן שהוא נוסע מתל אביב לניו יורק ולומד אנגלית בדרך!',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<double>(
          future: provider.getProgressPercentage(),
          builder: (context, snapshot) {
            final progress = snapshot.data ?? 0.0;
            return Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Section ${provider.currentSection}/${provider.totalSections}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: (progress / 100) * _progressAnimation.value,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 8,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${progress.toStringAsFixed(1)}% Complete',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionsList() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: WorkbookContent.sections.length,
          itemBuilder: (context, index) {
            final section = WorkbookContent.sections[index];
            return _buildSectionCard(section, provider);
          },
        );
      },
    );
  }

  Widget _buildSectionCard(Map<String, dynamic> section, AppProvider provider) {
    final sectionId = section['id'] as int;
    final isUnlocked = sectionId <= provider.currentSection;
    
    return FutureBuilder<bool>(
      future: provider.isSectionCompleted(sectionId),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data ?? false;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: isUnlocked ? 6 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: isUnlocked ? () => _navigateToSection(section) : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isUnlocked
                      ? LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.secondary.withOpacity(0.05),
                          ],
                        )
                      : null,
                  color: isUnlocked ? null : Colors.grey[100],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isUnlocked ? AppColors.primary : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Text(
                                    sectionId.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section['title'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? AppColors.textPrimary : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                section['titleHebrew'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isUnlocked ? AppColors.textSecondary : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.card_travel,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      (section['storyStep'] as String).length > 100
                          ? '${(section['storyStep'] as String).substring(0, 100)}...'
                          : section['storyStep'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isUnlocked ? AppColors.textSecondary : Colors.grey,
                        height: 1.4,
                      ),
                    ),
                    if (!isUnlocked)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Complete previous section to unlock',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return FloatingActionButton.extended(
          onPressed: () {
            final currentSectionData = provider.getSectionData(provider.currentSection);
            if (currentSectionData != null) {
              _navigateToSection(currentSectionData);
            }
          },
          label: const Text('Continue Learning'),
          icon: const Icon(Icons.play_arrow),
          backgroundColor: AppColors.primary,
        );
      },
    );
  }

  void _navigateToSection(Map<String, dynamic> section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkbookSectionScreen(section: section),
      ),
    );
  }
}
