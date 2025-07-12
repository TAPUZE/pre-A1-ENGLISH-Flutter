import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/app_constants.dart';

class TeachingWidget extends StatefulWidget {
  final Map<String, dynamic> teaching;
  final VoidCallback onComplete;

  const TeachingWidget({
    super.key,
    required this.teaching,
    required this.onComplete,
  });

  @override
  State<TeachingWidget> createState() => _TeachingWidgetState();
}

class _TeachingWidgetState extends State<TeachingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  FlutterTts? _flutterTts;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeTts();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  void _initializeTts() {
    _flutterTts = FlutterTts();
    _configureTts();
  }

  void _configureTts() async {
    await _flutterTts?.setLanguage('en-US');
    await _flutterTts?.setSpeechRate(0.6);
    await _flutterTts?.setVolume(0.8);
    await _flutterTts?.setPitch(1.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _flutterTts?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
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
            children: [
              _buildHeader(),
              if (_isExpanded) _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
        if (_isExpanded) {
          widget.onComplete();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.school,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.teaching['title'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.teaching['titleHebrew'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _speakText(widget.teaching['title'] as String),
                  icon: const Icon(
                    Icons.volume_up,
                    color: AppColors.primary,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          _buildExplanation(),
          const SizedBox(height: 20),
          _buildExamples(),
        ],
      ),
    );
  }

  Widget _buildExplanation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Explanation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _speakText(widget.teaching['explanation'] as String),
                icon: const Icon(
                  Icons.volume_up,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.teaching['explanation'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.teaching['explanationHebrew'] as String,
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

  Widget _buildExamples() {
    final examples = widget.teaching['examples'] as List<dynamic>?;
    if (examples == null || examples.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Examples',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildExamplesList(examples),
      ],
    );
  }

  Widget _buildExamplesList(List<dynamic> examples) {
    final teachingType = widget.teaching['type'] as String;
    
    switch (teachingType) {
      case 'capital_letters':
      case 'small_letters':
        return _buildLetterExamples(examples);
      case 'vowels':
        return _buildVowelExamples(examples);
      case 'consonants':
        return _buildConsonantExamples(examples);
      case 'simple_sentences':
        return _buildSentenceExamples(examples);
      case 'basic_words':
        return _buildWordExamples(examples);
      default:
        return _buildGenericExamples(examples);
    }
  }

  Widget _buildLetterExamples(List<dynamic> examples) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: examples.length,
      itemBuilder: (context, index) {
        final example = examples[index] as Map<String, dynamic>;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    example['letter'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      example['word'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      example['hebrew'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _speakText(example['word'] as String),
                icon: const Icon(
                  Icons.volume_up,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVowelExamples(List<dynamic> examples) {
    return Column(
      children: examples.map((example) {
        final vowelData = example as Map<String, dynamic>;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.5),
              width: 2,
            ),
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
                    child: Center(
                      child: Text(
                        vowelData['vowel'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sound: ${vowelData['sound'] as String}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          vowelData['hebrew'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _speakText(vowelData['vowel'] as String),
                    icon: const Icon(
                      Icons.volume_up,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Examples:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (vowelData['words'] as List<dynamic>).map((word) {
                  return InkWell(
                    onTap: () => _speakText(word as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        word as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConsonantExamples(List<dynamic> examples) {
    return Column(
      children: examples.map((category) {
        final categoryData = category as Map<String, dynamic>;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryData['category'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                categoryData['categoryHebrew'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Letters: ${(categoryData['letters'] as List<dynamic>).join(', ')}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (categoryData['examples'] as List<dynamic>).map((example) {
                  return InkWell(
                    onTap: () => _speakText(example as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        example as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSentenceExamples(List<dynamic> examples) {
    return Column(
      children: examples.map((pattern) {
        final patternData = pattern as Map<String, dynamic>;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pattern: ${patternData['pattern'] as String}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'תבנית: ${patternData['patternHebrew'] as String}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ...((patternData['examples'] as List<dynamic>).map((example) {
                final exampleData = example as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exampleData['sentence'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exampleData['hebrew'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _speakText(exampleData['sentence'] as String),
                        icon: const Icon(
                          Icons.volume_up,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWordExamples(List<dynamic> examples) {
    return Column(
      children: examples.map((category) {
        final categoryData = category as Map<String, dynamic>;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryData['category'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                categoryData['categoryHebrew'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ...((categoryData['words'] as List<dynamic>).map((word) {
                final wordData = word as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wordData['word'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              wordData['hebrew'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (wordData['pronunciation'] != null)
                              Text(
                                wordData['pronunciation'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _speakText(wordData['word'] as String),
                        icon: const Icon(
                          Icons.volume_up,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenericExamples(List<dynamic> examples) {
    return Column(
      children: examples.map((example) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            example.toString(),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _speakText(String text) async {
    await _flutterTts?.speak(text);
  }
}
