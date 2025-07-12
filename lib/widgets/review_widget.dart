import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timer_count_down/timer_count_down.dart';
import '../providers/app_provider.dart';
import '../models/workbook_content.dart';
import '../constants/app_constants.dart';

class ReviewWidget extends StatefulWidget {
  final WorkbookSection section;
  final VoidCallback onComplete;

  const ReviewWidget({
    super.key,
    required this.section,
    required this.onComplete,
  });

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  late ConfettiController _confettiController;
  late FlutterTts _flutterTts;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  bool _isAnswered = false;
  bool _showResults = false;
  bool _isTimerActive = false;
  int _timeLeft = 30;
  String? _selectedAnswer;
  List<ReviewQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _flutterTts = FlutterTts();
    _setupTts();
    _generateQuestions();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _setupTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  void _generateQuestions() {
    _questions = [];
    
    // Generate vocabulary questions
    for (var vocab in widget.section.vocabulary) {
      _questions.add(ReviewQuestion(
        type: QuestionType.vocabulary,
        question: 'What does "$vocab" mean?',
        options: _generateVocabularyOptions(vocab),
        correctAnswer: vocab,
        explanation: 'The word "$vocab" is part of your vocabulary.',
      ));
    }

    // Generate grammar questions
    for (var grammar in widget.section.grammar) {
      _questions.add(ReviewQuestion(
        type: QuestionType.grammar,
        question: 'Which grammar rule applies: $grammar?',
        options: _generateGrammarOptions(grammar),
        correctAnswer: grammar,
        explanation: 'This is about $grammar.',
      ));
    }

    // Generate story comprehension questions
    if (widget.section.stories.isNotEmpty) {
      var story = widget.section.stories.first;
      _questions.add(ReviewQuestion(
        type: QuestionType.comprehension,
        question: 'What is the main topic of the story?',
        options: _generateStoryOptions(story),
        correctAnswer: story.split(' ').first,
        explanation: 'The story is about $story.',
      ));
    }

    _questions.shuffle();
    _totalQuestions = _questions.length;
    _isTimerActive = true;
  }

  List<String> _generateVocabularyOptions(String correctAnswer) {
    List<String> options = [correctAnswer];
    List<String> allVocab = widget.section.vocabulary
        .where((v) => v != correctAnswer)
        .toList();
    
    allVocab.shuffle();
    options.addAll(allVocab.take(3));
    options.shuffle();
    
    return options;
  }

  List<String> _generateGrammarOptions(String rule) {
    List<String> options = [];
    
    if (rule.contains('am/is/are')) {
      options = ['I am happy', 'You is happy', 'He are happy', 'She am happy'];
    } else if (rule.contains('have/has')) {
      options = ['I has a book', 'You have a book', 'He have a book', 'She has a book'];
    } else {
      options = ['Option A', 'Option B', 'Option C', 'Option D'];
    }
    
    return options;
  }

  List<String> _generateStoryOptions(String title) {
    List<String> options = [];
    String firstName = title.split(' ').first;
    
    options.add(firstName);
    options.addAll(['Sarah', 'John', 'Emma', 'David']
        .where((name) => name != firstName)
        .take(3));
    
    options.shuffle();
    return options;
  }

  void _speakText(String text) async {
    await _flutterTts.speak(text);
  }

  void _selectAnswer(String answer) {
    if (_isAnswered) return;
    
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      _isTimerActive = false;
    });

    bool isCorrect = answer == _questions[_currentQuestionIndex].correctAnswer;
    
    if (isCorrect) {
      _correctAnswers++;
      _confettiController.play();
      _speakText("Correct! Well done!");
    } else {
      _speakText("Not quite right. The correct answer is ${_questions[_currentQuestionIndex].correctAnswer}");
    }

    // Log the attempt
    context.read<AppProvider>().logMistake(
      'review_question',
      {
        'section': widget.section.title,
        'question': _questions[_currentQuestionIndex].question,
        'userAnswer': answer,
        'correctAnswer': _questions[_currentQuestionIndex].correctAnswer,
        'isCorrect': isCorrect,
      },
    );

    // Move to next question after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        _nextQuestion();
      } else {
        _showReviewResults();
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _isAnswered = false;
      _selectedAnswer = null;
      _timeLeft = 30;
      _isTimerActive = true;
    });
  }

  void _showReviewResults() {
    setState(() {
      _showResults = true;
      _isTimerActive = false;
    });

    double percentage = (_correctAnswers / _totalQuestions) * 100;
    
    if (percentage >= 80) {
      _confettiController.play();
      _speakText("Excellent work! You scored ${percentage.toInt()}%!");
    } else if (percentage >= 60) {
      _speakText("Good job! You scored ${percentage.toInt()}%. Keep practicing!");
    } else {
      _speakText("You scored ${percentage.toInt()}%. Don't worry, practice makes perfect!");
    }

    // Log completion
    context.read<AppProvider>().logProgress(
      'review_${widget.section.title}',
      {
        'score': percentage,
        'correctAnswers': _correctAnswers,
        'totalQuestions': _totalQuestions,
      },
    );
  }

  void _onTimerFinished() {
    if (!_isAnswered) {
      _selectAnswer(''); // Empty answer for timeout
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isHebrew = appProvider.isHebrew;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isHebrew ? 'חזרה על ${widget.section.title}' : 'Review: ${widget.section.title}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => _speakText(
              _showResults 
                ? 'Review completed'
                : _questions[_currentQuestionIndex].question
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: _showResults ? _buildResults() : _buildQuiz(),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    final appProvider = context.watch<AppProvider>();
    final isHebrew = appProvider.isHebrew;
    final currentQuestion = _questions[_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _totalQuestions,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
          const SizedBox(height: 16),
          
          // Question counter and timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isHebrew ? 'שאלה' : 'Question'} ${_currentQuestionIndex + 1} / $_totalQuestions',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isTimerActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Countdown(
                    seconds: _timeLeft,
                    build: (BuildContext context, double time) {
                      return Text(
                        '${time.toInt()}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                    interval: const Duration(seconds: 1),
                    onFinished: _onTimerFinished,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Question card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getQuestionIcon(currentQuestion.type),
                        color: AppConstants.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getQuestionTypeText(currentQuestion.type, isHebrew),
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Answer options
                  ...currentQuestion.options.map((option) {
                    bool isSelected = _selectedAnswer == option;
                    bool isCorrect = option == currentQuestion.correctAnswer;
                    bool showCorrect = _isAnswered && isCorrect;
                    bool showIncorrect = _isAnswered && isSelected && !isCorrect;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _selectAnswer(option),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: showCorrect
                                ? Colors.green.withOpacity(0.2)
                                : showIncorrect
                                    ? Colors.red.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                            border: Border.all(
                              color: showCorrect
                                  ? Colors.green
                                  : showIncorrect
                                      ? Colors.red
                                      : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              if (showCorrect)
                                const Icon(Icons.check_circle, color: Colors.green)
                              else if (showIncorrect)
                                const Icon(Icons.cancel, color: Colors.red)
                              else
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: showCorrect
                                        ? Colors.green
                                        : showIncorrect
                                            ? Colors.red
                                            : AppConstants.textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  
                  // Explanation
                  if (_isAnswered && currentQuestion.explanation.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentQuestion.explanation,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final appProvider = context.watch<AppProvider>();
    final isHebrew = appProvider.isHebrew;
    final percentage = (_correctAnswers / _totalQuestions) * 100;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    percentage >= 80
                        ? Icons.emoji_events
                        : percentage >= 60
                            ? Icons.thumb_up
                            : Icons.school,
                    size: 64,
                    color: percentage >= 80
                        ? Colors.amber
                        : percentage >= 60
                            ? Colors.green
                            : Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isHebrew ? 'חזרה הושלמה!' : 'Review Complete!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: percentage >= 80
                          ? Colors.green
                          : percentage >= 60
                              ? Colors.blue
                              : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isHebrew ? 'תשובות נכונות' : 'Correct Answers'}: $_correctAnswers/$_totalQuestions',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    percentage >= 80
                        ? (isHebrew ? 'מעולה! אתה מוכן לחלק הבא!' : 'Excellent! You\'re ready for the next section!')
                        : percentage >= 60
                            ? (isHebrew ? 'כל הכבוד! המשך לתרגל!' : 'Good job! Keep practicing!')
                            : (isHebrew ? 'אל תלך לאיבוד, התרגול עושה שלמות!' : 'Don\'t worry, practice makes perfect!'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppConstants.textColor,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              isHebrew ? 'המשך' : 'Continue',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getQuestionIcon(QuestionType type) {
    switch (type) {
      case QuestionType.vocabulary:
        return Icons.translate;
      case QuestionType.grammar:
        return Icons.school;
      case QuestionType.comprehension:
        return Icons.book;
    }
  }

  String _getQuestionTypeText(QuestionType type, bool isHebrew) {
    switch (type) {
      case QuestionType.vocabulary:
        return isHebrew ? 'אוצר מילים' : 'Vocabulary';
      case QuestionType.grammar:
        return isHebrew ? 'דקדוק' : 'Grammar';
      case QuestionType.comprehension:
        return isHebrew ? 'הבנת הנקרא' : 'Comprehension';
    }
  }
}

class ReviewQuestion {
  final QuestionType type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  ReviewQuestion({
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation = '',
  });
}

enum QuestionType {
  vocabulary,
  grammar,
  comprehension,
}
