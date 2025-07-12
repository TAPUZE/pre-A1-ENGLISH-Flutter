import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    // Refresh analytics when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchAnalytics();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildStatsOverview(provider),
                          const SizedBox(height: 20),
                          _buildProgressChart(provider),
                          const SizedBox(height: 20),
                          _buildMistakesChart(provider),
                          const SizedBox(height: 20),
                          _buildRecentActivity(provider),
                          const SizedBox(height: 20),
                          _buildAchievements(provider),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.dashboardTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track your learning progress',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _refreshData(),
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(AppProvider provider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: FutureBuilder<List<int>>(
        future: provider.getCompletedSections(),
        builder: (context, snapshot) {
          final completedSections = snapshot.data ?? [];
          final stats = provider.getUserStats();
          
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  completedSections.length.toString(),
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Current',
                  provider.currentSection.toString(),
                  Icons.play_circle,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Mistakes',
                  provider.mistakeLog.length.toString(),
                  Icons.error,
                  AppColors.error,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(AppProvider provider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
            const Text(
              'Progress by Section',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<int>>(
                future: provider.getCompletedSections(),
                builder: (context, snapshot) {
                  final completedSections = snapshot.data ?? [];
                  
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                'S${value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        provider.totalSections,
                        (index) {
                          final sectionId = index + 1;
                          final isCompleted = completedSections.contains(sectionId);
                          final isCurrent = sectionId == provider.currentSection;
                          
                          return BarChartGroupData(
                            x: sectionId,
                            barRods: [
                              BarChartRodData(
                                toY: isCompleted ? 100 : (isCurrent ? 50 : 0),
                                color: isCompleted
                                    ? AppColors.success
                                    : (isCurrent ? AppColors.primary : AppColors.background),
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMistakesChart(AppProvider provider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
            const Text(
              'Mistake Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Builder(
                builder: (context) {
                  final mistakeStats = provider.getMistakeStats();
                  
                  if (mistakeStats.isEmpty) {
                    return const Center(
                      child: Text(
                        'No mistakes yet!\nKeep up the great work! 🎉',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  final colors = [
                    AppColors.error,
                    AppColors.warning,
                    AppColors.primary,
                    AppColors.secondary,
                  ];

                  return PieChart(
                    PieChartData(
                      sections: mistakeStats.entries.map((entry) {
                        final index = mistakeStats.keys.toList().indexOf(entry.key);
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: entry.value.toDouble(),
                          title: '${entry.value}',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildMistakeLegend(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildMistakeLegend(AppProvider provider) {
    final mistakeStats = provider.getMistakeStats();
    final colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.primary,
      AppColors.secondary,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: mistakeStats.entries.map((entry) {
        final index = mistakeStats.keys.toList().indexOf(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              entry.key,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivity(AppProvider provider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
            const Text(
              'Recent Mistakes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final recentMistakes = provider.getRecentMistakes(limit: 5);
                
                if (recentMistakes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No recent mistakes!\nYou\'re doing great! 🌟',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: recentMistakes.map((mistake) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mistake['type'] ?? 'Unknown mistake',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            _formatDateTime(mistake['timestamp']),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(AppProvider provider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<int>>(
              future: provider.getCompletedSections(),
              builder: (context, snapshot) {
                final completedSections = snapshot.data ?? [];
                
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildAchievementBadge(
                      'First Steps',
                      Icons.directions_walk,
                      completedSections.isNotEmpty,
                      'Complete your first section',
                    ),
                    _buildAchievementBadge(
                      'Halfway There',
                      Icons.timeline,
                      completedSections.length >= (provider.totalSections / 2),
                      'Complete half of all sections',
                    ),
                    _buildAchievementBadge(
                      'Perfectionist',
                      Icons.star,
                      provider.mistakeLog.length < 10,
                      'Keep mistakes under 10',
                    ),
                    _buildAchievementBadge(
                      'Explorer',
                      Icons.explore,
                      completedSections.length == provider.totalSections,
                      'Complete all sections',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(String title, IconData icon, bool earned, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: earned ? AppColors.success.withOpacity(0.1) : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: earned ? AppColors.success : AppColors.background,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: earned ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: earned ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: earned ? AppColors.success : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return '';
    
    try {
      final dateTime = DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  void _refreshData() {
    Provider.of<AppProvider>(context, listen: false).fetchAnalytics();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data refreshed!'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
