import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';
import '../models/workbook_content.dart';
import '../widgets/exercise_widget.dart';
import '../widgets/game_widget.dart';
import '../widgets/teaching_widget.dart';
import '../widgets/review_widget.dart';

class WorkbookSectionScreen extends StatefulWidget {
  final Map<String, dynamic> section;

  const WorkbookSectionScreen({
    super.key,
    required this.section,
  });

  @override
  State<WorkbookSectionScreen> createState() => _WorkbookSectionScreenState();
}

class _WorkbookSectionScreenState extends State<WorkbookSectionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    // Log section start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).logEvent('section_start', {
        'sectionId': widget.section['id'],
        'sectionTitle': widget.section['title'],
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        child: Column(
          children: [
            _buildHeader(),
            _buildStorySection(),
            _buildTabBar(),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.section['title'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.section['titleHebrew'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Section ${widget.section['id']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorySection() {
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Story Step',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.section['storyStep'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.section['storyStepHebrew'] as String,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            icon: Icon(Icons.school),
            text: 'Learn',
          ),
          Tab(
            icon: Icon(Icons.edit),
            text: 'Practice',
          ),
          Tab(
            icon: Icon(Icons.games),
            text: 'Games',
          ),
          Tab(
            icon: Icon(Icons.quiz),
            text: 'Review',
          ),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTeachingTab(),
        _buildPracticeTab(),
        _buildGamesTab(),
        _buildReviewTab(),
      ],
    );
  }

  Widget _buildTeachingTab() {
    final teachings = widget.section['teachings'] as List<dynamic>;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: teachings.length,
        itemBuilder: (context, index) {
          final teaching = teachings[index] as Map<String, dynamic>;
          return TeachingWidget(
            teaching: teaching,
            onComplete: () => _onTeachingComplete(teaching),
          );
        },
      ),
    );
  }

  Widget _buildPracticeTab() {
    final practices = widget.section['practices'] as List<dynamic>;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: practices.length,
        itemBuilder: (context, index) {
          final practice = practices[index] as Map<String, dynamic>;
          return ExerciseWidget(
            exercise: practice,
            onComplete: (score) => _onPracticeComplete(practice, score),
          );
        },
      ),
    );
  }

  Widget _buildGamesTab() {
    final games = widget.section['games'] as List<dynamic>;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index] as Map<String, dynamic>;
          return GameWidget(
            game: game,
            onComplete: (score) => _onGameComplete(game, score),
          );
        },
      ),
    );
  }

  Widget _buildReviewTab() {
    final review = widget.section['review'] as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ReviewWidget(
        section: WorkbookSection.fromMap(widget.section),
        onComplete: () => _onReviewComplete(),
      ),
    );
  }

  void _onTeachingComplete(Map<String, dynamic> teaching) {
    Provider.of<AppProvider>(context, listen: false).logEvent('teaching_complete', {
      'sectionId': widget.section['id'],
      'teachingId': teaching['type'],
      'teachingTitle': teaching['title'],
    });
  }

  void _onPracticeComplete(Map<String, dynamic> practice, int score) {
    Provider.of<AppProvider>(context, listen: false).logEvent('practice_complete', {
      'sectionId': widget.section['id'],
      'practiceId': practice['id'],
      'practiceTitle': practice['title'],
      'score': score,
    });

    if (score >= 70) {
      _showCelebration();
    }
  }

  void _onGameComplete(Map<String, dynamic> game, int score) {
    Provider.of<AppProvider>(context, listen: false).logEvent('game_complete', {
      'sectionId': widget.section['id'],
      'gameId': game['id'],
      'gameTitle': game['title'],
      'score': score,
    });

    if (score >= 70) {
      _showCelebration();
    }
  }

  void _onReviewComplete() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    // Mark section as complete
    provider.logEvent('section_complete', {
      'sectionId': widget.section['id'],
      'sectionTitle': widget.section['title'],
    });

    // Award passport stamp
    provider.awardPassportStamp(widget.section['id'] as int);

    // Show completion celebration
    _showSectionComplete();
  }

  void _showCelebration() {
    _confettiController.play();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.correct),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSectionComplete() {
    _confettiController.play();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Column(
          children: [
            Icon(
              Icons.card_travel,
              size: 50,
              color: AppColors.success,
            ),
            SizedBox(height: 12),
            Text(
              AppStrings.sectionComplete,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'Congratulations! You\'ve earned a passport stamp and can proceed to the next section.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text(
              AppStrings.nextSection,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
