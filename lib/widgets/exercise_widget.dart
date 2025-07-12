import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';

class ExerciseWidget extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final Function(int score) onComplete;

  const ExerciseWidget({
    super.key,
    required this.exercise,
    required this.onComplete,
  });

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ConfettiController _confettiController;
  FlutterTts? _flutterTts;

  bool _isExpanded = false;
  bool _isCompleted = false;
  int _currentScore = 0;
  int _totalQuestions = 0;
  Map<String, dynamic> _userAnswers = {};
  Map<String, bool> _questionResults = {};

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeTts();
    _initializeExercise();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
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

  void _initializeExercise() {
    final type = widget.exercise['type'] as String;
    
    switch (type) {
      case 'writing_capitals':
        _totalQuestions = (widget.exercise['data'] as List<dynamic>).length;
        break;
      case 'letter_matching':
        _totalQuestions = (widget.exercise['pairs'] as List<dynamic>).length;
        break;
      case 'fill_blanks':
        _totalQuestions = (widget.exercise['questions'] as List<dynamic>?)?.length ?? 
                          (widget.exercise['words'] as List<dynamic>?)?.length ?? 0;
        break;
      case 'vowel_identification':
        _totalQuestions = (widget.exercise['words'] as List<dynamic>).length;
        break;
      case 'word_building':
        _totalQuestions = (widget.exercise['exercises'] as List<dynamic>).length;
        break;
      case 'pronunciation_practice':
        _totalQuestions = (widget.exercise['words'] as List<dynamic>).length;
        break;
      case 'consonant_identification':
        _totalQuestions = (widget.exercise['words'] as List<dynamic>).length;
        break;
      case 'sentence_building':
        _totalQuestions = (widget.exercise['sentences'] as List<dynamic>).length;
        break;
      case 'security_dialogue':
        _totalQuestions = (widget.exercise['dialogue'] as List<dynamic>).length;
        break;
      default:
        _totalQuestions = 1;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
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
                color: _isCompleted ? AppColors.success : AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isCompleted ? Icons.check : Icons.edit,
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
                    widget.exercise['title'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.exercise['titleHebrew'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_isCompleted)
                    Text(
                      'Score: $_currentScore/$_totalQuestions',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                if (_isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${((_currentScore / _totalQuestions) * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
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
          _buildInstructions(),
          const SizedBox(height: 20),
          _buildExerciseContent(),
          if (!_isCompleted) ...[
            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
          if (_isCompleted) ...[
            const SizedBox(height: 20),
            _buildResults(),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructions() {
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
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _speakText(widget.exercise['instruction'] as String),
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
            widget.exercise['instruction'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.exercise['instructionHebrew'] as String,
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

  Widget _buildExerciseContent() {
    final type = widget.exercise['type'] as String;
    
    switch (type) {
      case 'writing_capitals':
        return _buildWritingCapitals();
      case 'letter_matching':
        return _buildLetterMatching();
      case 'fill_blanks':
        return _buildFillBlanks();
      case 'vowel_identification':
        return _buildVowelIdentification();
      case 'word_building':
        return _buildWordBuilding();
      case 'pronunciation_practice':
        return _buildPronunciationPractice();
      case 'consonant_identification':
        return _buildConsonantIdentification();
      case 'sentence_building':
        return _buildSentenceBuilding();
      case 'security_dialogue':
        return _buildSecurityDialogue();
      default:
        return _buildGenericExercise();
    }
  }

  Widget _buildWritingCapitals() {
    final data = widget.exercise['data'] as List<dynamic>;
    
    return Column(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value as Map<String, dynamic>;
        final letter = item['letter'] as String;
        final example = item['example'] as String;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _questionResults[index.toString()] == true
                  ? AppColors.success
                  : (_questionResults[index.toString()] == false
                      ? AppColors.error
                      : AppColors.primary.withOpacity(0.3)),
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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        letter,
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
                    child: Text(
                      'Practice writing "$letter" - Example: $example',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _speakText(letter),
                    icon: const Icon(
                      Icons.volume_up,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                enabled: !_isCompleted,
                onChanged: (value) {
                  setState(() {
                    _userAnswers[index.toString()] = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Write the letter $letter six times...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
              if (_questionResults[index.toString()] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        _questionResults[index.toString()]! ? Icons.check_circle : Icons.cancel,
                        color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _questionResults[index.toString()]! ? 'Correct!' : 'Try again!',
                        style: TextStyle(
                          fontSize: 12,
                          color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLetterMatching() {
    final pairs = widget.exercise['pairs'] as List<dynamic>;
    
    return Column(
      children: pairs.asMap().entries.map((entry) {
        final index = entry.key;
        final pair = entry.value as Map<String, dynamic>;
        final capital = pair['capital'] as String;
        final small = pair['small'] as String;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _questionResults[index.toString()] == true
                  ? AppColors.success
                  : (_questionResults[index.toString()] == false
                      ? AppColors.error
                      : AppColors.primary.withOpacity(0.3)),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    capital,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.arrow_forward,
                color: AppColors.primary,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _userAnswers[index.toString()] as String?,
                  onChanged: _isCompleted ? null : (value) {
                    setState(() {
                      _userAnswers[index.toString()] = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Select matching letter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  items: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
                      .map((letter) => DropdownMenuItem(
                            value: letter,
                            child: Text(letter),
                          ))
                      .toList(),
                ),
              ),
              if (_questionResults[index.toString()] != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    _questionResults[index.toString()]! ? Icons.check_circle : Icons.cancel,
                    color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFillBlanks() {
    final questions = widget.exercise['questions'] as List<dynamic>? ?? 
                     widget.exercise['words'] as List<dynamic>? ?? [];
    
    return Column(
      children: questions.asMap().entries.map((entry) {
        final index = entry.key;
        final question = entry.value as Map<String, dynamic>;
        final word = question['word'] as String;
        final answer = question['answer'] as String;
        final hint = question['hint'] as String?;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _questionResults[index.toString()] == true
                  ? AppColors.success
                  : (_questionResults[index.toString()] == false
                      ? AppColors.error
                      : AppColors.primary.withOpacity(0.3)),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    word,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _speakText(word.replaceAll('_', answer)),
                    icon: const Icon(
                      Icons.volume_up,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (hint != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Hint: $hint',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                enabled: !_isCompleted,
                onChanged: (value) {
                  setState(() {
                    _userAnswers[index.toString()] = value.toUpperCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter the missing letter(s)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              if (_questionResults[index.toString()] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        _questionResults[index.toString()]! ? Icons.check_circle : Icons.cancel,
                        color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _questionResults[index.toString()]! 
                            ? 'Correct!' 
                            : 'Correct answer: $answer',
                        style: TextStyle(
                          fontSize: 12,
                          color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVowelIdentification() {
    final words = widget.exercise['words'] as List<dynamic>;
    
    return Column(
      children: words.asMap().entries.map((entry) {
        final index = entry.key;
        final wordData = entry.value as Map<String, dynamic>;
        final word = wordData['word'] as String;
        final vowels = wordData['vowels'] as List<dynamic>;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _questionResults[index.toString()] == true
                  ? AppColors.success
                  : (_questionResults[index.toString()] == false
                      ? AppColors.error
                      : AppColors.primary.withOpacity(0.3)),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    word,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _speakText(word),
                    icon: const Icon(
                      Icons.volume_up,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Select all vowels in this word:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: word.split('').map((letter) {
                  final isVowel = ['A', 'E', 'I', 'O', 'U'].contains(letter);
                  final isSelected = (_userAnswers[index.toString()] as List<String>?)?.contains(letter) ?? false;
                  
                  return InkWell(
                    onTap: _isCompleted ? null : () {
                      setState(() {
                        final currentAnswers = (_userAnswers[index.toString()] as List<String>?) ?? <String>[];
                        if (isSelected) {
                          currentAnswers.remove(letter);
                        } else {
                          currentAnswers.add(letter);
                        }
                        _userAnswers[index.toString()] = currentAnswers;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.secondary : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isVowel ? AppColors.secondary : AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_questionResults[index.toString()] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        _questionResults[index.toString()]! ? Icons.check_circle : Icons.cancel,
                        color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _questionResults[index.toString()]! 
                            ? 'Correct!' 
                            : 'Correct vowels: ${vowels.join(", ")}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWordBuilding() {
    final exercises = widget.exercise['exercises'] as List<dynamic>;
    
    return Column(
      children: exercises.asMap().entries.map((entry) {
        final index = entry.key;
        final exercise = entry.value as Map<String, dynamic>;
        final word = exercise['word'] as String;
        final complete = exercise['complete'] as String;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _questionResults[index.toString()] == true
                  ? AppColors.success
                  : (_questionResults[index.toString()] == false
                      ? AppColors.error
                      : AppColors.primary.withOpacity(0.3)),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    word,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _speakText(complete),
                    icon: const Icon(
                      Icons.volume_up,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                enabled: !_isCompleted,
                onChanged: (value) {
                  setState(() {
                    _userAnswers[index.toString()] = value.toUpperCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Complete the word',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              if (_questionResults[index.toString()] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        _questionResults[index.toString()]! ? Icons.check_circle : Icons.cancel,
                        color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _questionResults[index.toString()]! 
                            ? 'Correct!' 
                            : 'Correct answer: $complete',
                        style: TextStyle(
                          fontSize: 12,
                          color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPronunciationPractice() {
    final words = widget.exercise['words'] as List<dynamic>;
    
    return Column(
      children: words.asMap().entries.map((entry) {
        final index = entry.key;
        final wordData = entry.value as Map<String, dynamic>;
        final word = wordData['word'] as String;
        final phonetic = wordData['phonetic'] as String;
        final hebrew = wordData['hebrew'] as String;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _questionResults[index.toString()] == true
                  ? AppColors.success
                  : AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phonetic,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hebrew,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _speakText(word),
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Listen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _questionResults[index.toString()] = true;
                        });
                        _updateScore();
                      },
                      icon: const Icon(Icons.mic),
                      label: const Text('Practice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (_questionResults[index.toString()] == true)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Great practice!',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConsonantIdentification() {
    final words = widget.exercise['words'] as List<dynamic>;
    
    return Column(
      children: words.asMap().entries.map((entry) {
        final index = entry.key;
        final wordData = entry.value as Map<String, dynamic>;
        final word = wordData['word'] as String;
        final consonants = wordData['consonants'] as List<dynamic>;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _questionResults[index.toString()] == true
                  ? AppColors.success
                  : (_questionResults[index.toString()] == false
                      ? AppColors.error
                      : AppColors.primary.withOpacity(0.3)),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    word,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _speakText(word),
                    icon: const Icon(
                      Icons.volume_up,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Select all consonants in this word:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: word.split('').map((letter) {
                  final isConsonant = !['A', 'E', 'I', 'O', 'U'].contains(letter);
                  final isSelected = (_userAnswers[index.toString()] as List<String>?)?.contains(letter) ?? false;
                  
                  return InkWell(
                    onTap: _isCompleted ? null : () {
                      setState(() {
                        final currentAnswers = (_userAnswers[index.toString()] as List<String>?) ?? <String>[];
                        if (isSelected) {
                          currentAnswers.remove(letter);
                        } else {
                          currentAnswers.add(letter);
                        }
                        _userAnswers[index.toString()] = currentAnswers;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isConsonant ? AppColors.primary : AppColors.secondary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_questionResults[index.toString()] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        _questionResults[index.toString()]! ? Icons.check_circle : Icons.cancel,
                        color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _questionResults[index.toString()]! 
                            ? 'Correct!' 
                            : 'Correct consonants: ${consonants.join(", ")}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSentenceBuilding() {
    final sentences = widget.exercise['sentences'] as List<dynamic>;
    
    return Column(
      children: sentences.asMap().entries.map((entry) {
        final index = entry.key;
        final sentence = entry.value as Map<String, dynamic>;
        final incomplete = sentence['incomplete'] as String;
        final answers = sentence['answers'] as List<dynamic>;
        final hebrew = sentence['hebrew'] as String;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _questionResults[index.toString()] == true
                  ? AppColors.success
                  : (_questionResults[index.toString()] == false
                      ? AppColors.error
                      : AppColors.primary.withOpacity(0.3)),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                incomplete,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hebrew,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                enabled: !_isCompleted,
                onChanged: (value) {
                  setState(() {
                    _userAnswers[index.toString()] = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Complete the sentence',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              if (_questionResults[index.toString()] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        _questionResults[index.toString()]! ? Icons.check_circle : Icons.cancel,
                        color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _questionResults[index.toString()]! 
                            ? 'Correct!' 
                            : 'Possible answers: ${answers.join(", ")}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _questionResults[index.toString()]! ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSecurityDialogue() {
    final dialogue = widget.exercise['dialogue'] as List<dynamic>;
    
    return Column(
      children: [
        const Text(
          'Practice this dialogue:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...dialogue.asMap().entries.map((entry) {
          final index = entry.key;
          final line = entry.value as Map<String, dynamic>;
          final speaker = line['speaker'] as String;
          final text = line['text'] as String;
          final hebrew = line['hebrew'] as String;
          final isDavid = speaker == 'David';
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDavid ? AppColors.primary.withOpacity(0.1) : AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      speaker,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDavid ? AppColors.primary : AppColors.secondary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _speakText(text),
                      icon: Icon(
                        Icons.volume_up,
                        color: isDavid ? AppColors.primary : AppColors.secondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hebrew,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isCompleted ? null : () {
            setState(() {
              _isCompleted = true;
              _currentScore = _totalQuestions;
              for (int i = 0; i < _totalQuestions; i++) {
                _questionResults[i.toString()] = true;
              }
            });
            _completeExercise();
          },
          child: const Text('Mark as Practiced'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGenericExercise() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Generic Exercise',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isCompleted ? null : () {
              setState(() {
                _isCompleted = true;
                _currentScore = _totalQuestions;
                for (int i = 0; i < _totalQuestions; i++) {
                  _questionResults[i.toString()] = true;
                }
              });
              _completeExercise();
            },
            child: const Text('Complete Exercise'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canSubmit() ? _submitExercise : null,
        child: const Text(
          AppStrings.submit,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final percentage = ((_currentScore / _totalQuestions) * 100).toInt();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: percentage >= 70 ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            percentage >= 70 ? Icons.celebration : Icons.refresh,
            size: 48,
            color: percentage >= 70 ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            percentage >= 70 ? AppStrings.congratulations : AppStrings.tryAgain,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: percentage >= 70 ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score: $_currentScore/$_totalQuestions ($percentage%)',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          if (percentage < 70) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _resetExercise,
              child: const Text(AppStrings.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _userAnswers.length >= _totalQuestions && !_isCompleted;
  }

  void _submitExercise() {
    setState(() {
      _isCompleted = true;
      _currentScore = 0;
      _questionResults.clear();
    });

    final type = widget.exercise['type'] as String;
    
    // Check answers based on exercise type
    switch (type) {
      case 'writing_capitals':
        _checkWritingCapitals();
        break;
      case 'letter_matching':
        _checkLetterMatching();
        break;
      case 'fill_blanks':
        _checkFillBlanks();
        break;
      case 'vowel_identification':
        _checkVowelIdentification();
        break;
      case 'word_building':
        _checkWordBuilding();
        break;
      case 'consonant_identification':
        _checkConsonantIdentification();
        break;
      case 'sentence_building':
        _checkSentenceBuilding();
        break;
      default:
        _currentScore = _totalQuestions;
    }

    _completeExercise();
  }

  void _checkWritingCapitals() {
    final data = widget.exercise['data'] as List<dynamic>;
    
    for (int i = 0; i < data.length; i++) {
      final item = data[i] as Map<String, dynamic>;
      final letter = item['letter'] as String;
      final userAnswer = _userAnswers[i.toString()] as String? ?? '';
      
      // Check if user wrote the letter multiple times
      final isCorrect = userAnswer.contains(letter) && userAnswer.length >= 6;
      _questionResults[i.toString()] = isCorrect;
      
      if (isCorrect) {
        _currentScore++;
      } else {
        _logMistake('letter_writing', {
          'letter': letter,
          'userAnswer': userAnswer,
          'expected': 'Multiple occurrences of $letter',
        });
      }
    }
  }

  void _checkLetterMatching() {
    final pairs = widget.exercise['pairs'] as List<dynamic>;
    
    for (int i = 0; i < pairs.length; i++) {
      final pair = pairs[i] as Map<String, dynamic>;
      final small = pair['small'] as String;
      final userAnswer = _userAnswers[i.toString()] as String? ?? '';
      
      final isCorrect = userAnswer.toLowerCase() == small.toLowerCase();
      _questionResults[i.toString()] = isCorrect;
      
      if (isCorrect) {
        _currentScore++;
      } else {
        _logMistake('letter_matching', {
          'capital': pair['capital'],
          'userAnswer': userAnswer,
          'correct': small,
        });
      }
    }
  }

  void _checkFillBlanks() {
    final questions = widget.exercise['questions'] as List<dynamic>? ?? 
                     widget.exercise['words'] as List<dynamic>? ?? [];
    
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i] as Map<String, dynamic>;
      final answer = question['answer'] as String;
      final userAnswer = _userAnswers[i.toString()] as String? ?? '';
      
      final isCorrect = userAnswer.toUpperCase() == answer.toUpperCase();
      _questionResults[i.toString()] = isCorrect;
      
      if (isCorrect) {
        _currentScore++;
      } else {
        _logMistake('fill_blanks', {
          'word': question['word'],
          'userAnswer': userAnswer,
          'correct': answer,
        });
      }
    }
  }

  void _checkVowelIdentification() {
    final words = widget.exercise['words'] as List<dynamic>;
    
    for (int i = 0; i < words.length; i++) {
      final wordData = words[i] as Map<String, dynamic>;
      final vowels = wordData['vowels'] as List<dynamic>;
      final userAnswer = _userAnswers[i.toString()] as List<String>? ?? [];
      
      final correctVowels = vowels.cast<String>().toSet();
      final userVowels = userAnswer.toSet();
      
      final isCorrect = correctVowels.difference(userVowels).isEmpty && 
                       userVowels.difference(correctVowels).isEmpty;
      _questionResults[i.toString()] = isCorrect;
      
      if (isCorrect) {
        _currentScore++;
      } else {
        _logMistake('vowel_identification', {
          'word': wordData['word'],
          'userAnswer': userAnswer,
          'correct': vowels,
        });
      }
    }
  }

  void _checkWordBuilding() {
    final exercises = widget.exercise['exercises'] as List<dynamic>;
    
    for (int i = 0; i < exercises.length; i++) {
      final exercise = exercises[i] as Map<String, dynamic>;
      final complete = exercise['complete'] as String;
      final userAnswer = _userAnswers[i.toString()] as String? ?? '';
      
      final isCorrect = userAnswer.toUpperCase() == complete.toUpperCase();
      _questionResults[i.toString()] = isCorrect;
      
      if (isCorrect) {
        _currentScore++;
      } else {
        _logMistake('word_building', {
          'incomplete': exercise['word'],
          'userAnswer': userAnswer,
          'correct': complete,
        });
      }
    }
  }

  void _checkConsonantIdentification() {
    final words = widget.exercise['words'] as List<dynamic>;
    
    for (int i = 0; i < words.length; i++) {
      final wordData = words[i] as Map<String, dynamic>;
      final consonants = wordData['consonants'] as List<dynamic>;
      final userAnswer = _userAnswers[i.toString()] as List<String>? ?? [];
      
      final correctConsonants = consonants.cast<String>().toSet();
      final userConsonants = userAnswer.toSet();
      
      final isCorrect = correctConsonants.difference(userConsonants).isEmpty && 
                       userConsonants.difference(correctConsonants).isEmpty;
      _questionResults[i.toString()] = isCorrect;
      
      if (isCorrect) {
        _currentScore++;
      } else {
        _logMistake('consonant_identification', {
          'word': wordData['word'],
          'userAnswer': userAnswer,
          'correct': consonants,
        });
      }
    }
  }

  void _checkSentenceBuilding() {
    final sentences = widget.exercise['sentences'] as List<dynamic>;
    
    for (int i = 0; i < sentences.length; i++) {
      final sentence = sentences[i] as Map<String, dynamic>;
      final answers = sentence['answers'] as List<dynamic>;
      final userAnswer = _userAnswers[i.toString()] as String? ?? '';
      
      final isCorrect = answers.any((answer) => 
          userAnswer.toLowerCase().trim() == (answer as String).toLowerCase().trim());
      _questionResults[i.toString()] = isCorrect;
      
      if (isCorrect) {
        _currentScore++;
      } else {
        _logMistake('sentence_building', {
          'sentence': sentence['incomplete'],
          'userAnswer': userAnswer,
          'correct': answers,
        });
      }
    }
  }

  void _logMistake(String type, Map<String, dynamic> details) {
    Provider.of<AppProvider>(context, listen: false).logEvent('mistake', {
      'type': type,
      'exerciseId': widget.exercise['id'],
      'exerciseTitle': widget.exercise['title'],
      'details': details,
    });
  }

  void _completeExercise() {
    final percentage = ((_currentScore / _totalQuestions) * 100).toInt();
    
    widget.onComplete(percentage);
    
    if (percentage >= 70) {
      _confettiController.play();
    }
  }

  void _resetExercise() {
    setState(() {
      _isCompleted = false;
      _currentScore = 0;
      _userAnswers.clear();
      _questionResults.clear();
    });
  }

  void _speakText(String text) async {
    await _flutterTts?.speak(text);
  }

  void _updateScore() {
    _currentScore = _questionResults.values.where((result) => result == true).length;
  }
}
