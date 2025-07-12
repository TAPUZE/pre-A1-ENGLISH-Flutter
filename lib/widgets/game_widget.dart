import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'dart:math';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';

class GameWidget extends StatefulWidget {
  final Map<String, dynamic> game;
  final Function(int score) onComplete;

  const GameWidget({
    super.key,
    required this.game,
    required this.onComplete,
  });

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ConfettiController _confettiController;
  FlutterTts? _flutterTts;

  bool _isExpanded = false;
  bool _isGameActive = false;
  bool _isGameCompleted = false;
  int _currentScore = 0;
  int _timeRemaining = 0;
  String _gameStatus = 'Ready to Play';

  // Game-specific state
  String _currentWord = '';
  List<String> _guessedLetters = [];
  int _wrongGuesses = 0;
  List<String> _availableLetters = [];
  List<Map<String, dynamic>> _bingoGrid = [];
  List<String> _selectedBingoItems = [];
  int _currentCharadeIndex = 0;
  List<String> _wordRaceWords = [];
  String _currentRaceWord = '';
  int _raceWordsCompleted = 0;
  List<Map<String, dynamic>> _memoryCards = [];
  List<int> _flippedCards = [];
  List<int> _matchedCards = [];
  List<String> _scrambledWords = [];
  String _userSentence = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeTts();
    _initializeGame();
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

  void _initializeGame() {
    final gameType = widget.game['type'] as String;
    
    switch (gameType) {
      case 'hangman':
        _initializeHangman();
        break;
      case 'letter_bingo':
        _initializeBingo();
        break;
      case 'charades':
        _initializeCharades();
        break;
      case 'vowel_hunt':
        _initializeVowelHunt();
        break;
      case 'word_race':
        _initializeWordRace();
        break;
      case 'memory_match':
        _initializeMemoryMatch();
        break;
      case 'security_scanner':
        _initializeSecurityScanner();
        break;
      case 'consonant_wheel':
        _initializeConsonantWheel();
        break;
      case 'sentence_scramble':
        _initializeSentenceScramble();
        break;
    }
  }

  void _initializeHangman() {
    final words = widget.game['words'] as List<dynamic>;
    final randomWord = words[Random().nextInt(words.length)] as Map<String, dynamic>;
    _currentWord = randomWord['word'] as String;
    _availableLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    _guessedLetters = [];
    _wrongGuesses = 0;
  }

  void _initializeBingo() {
    final letters = widget.game['letters'] as List<dynamic>;
    final gridSize = widget.game['gridSize'] as int;
    _timeRemaining = widget.game['timeLimit'] as int;
    
    _bingoGrid = List.generate(gridSize * gridSize, (index) {
      return {
        'letter': letters[Random().nextInt(letters.length)],
        'isSelected': false,
        'index': index,
      };
    });
    _selectedBingoItems = [];
  }

  void _initializeCharades() {
    final activities = widget.game['activities'] as List<dynamic>;
    _timeRemaining = widget.game['timeLimit'] as int;
    _currentCharadeIndex = 0;
  }

  void _initializeVowelHunt() {
    _timeRemaining = widget.game['timeLimit'] as int;
    final hiddenWords = widget.game['hiddenWords'] as List<dynamic>;
    // Initialize vowel hunt state
  }

  void _initializeWordRace() {
    final words = widget.game['words'] as List<dynamic>;
    _timeRemaining = widget.game['timeLimit'] as int;
    _wordRaceWords = words.map((w) => w['word'] as String).toList();
    _currentRaceWord = _wordRaceWords.first;
    _raceWordsCompleted = 0;
  }

  void _initializeMemoryMatch() {
    final pairs = widget.game['pairs'] as List<dynamic>;
    _memoryCards = [];
    
    for (var pair in pairs) {
      _memoryCards.add({
        'text': pair['english'],
        'isFlipped': false,
        'isMatched': false,
        'pairId': pair['english'],
      });
      _memoryCards.add({
        'text': pair['hebrew'],
        'isFlipped': false,
        'isMatched': false,
        'pairId': pair['english'],
      });
    }
    
    _memoryCards.shuffle();
    _flippedCards = [];
    _matchedCards = [];
  }

  void _initializeSecurityScanner() {
    _timeRemaining = widget.game['timeLimit'] as int;
  }

  void _initializeConsonantWheel() {
    _timeRemaining = widget.game['timeLimit'] as int;
  }

  void _initializeSentenceScramble() {
    final sentences = widget.game['sentences'] as List<dynamic>;
    final randomSentence = sentences[Random().nextInt(sentences.length)] as Map<String, dynamic>;
    _scrambledWords = List<String>.from(randomSentence['scrambled'] as List<dynamic>);
    _userSentence = '';
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
        child: Stack(
          children: [
            Container(
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
            Positioned(
              top: 10,
              right: 10,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -pi / 2,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.05,
              ),
            ),
          ],
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
                color: _isGameCompleted ? AppColors.success : AppColors.warning,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isGameCompleted ? Icons.check : Icons.games,
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
                    widget.game['title'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.game['titleHebrew'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _gameStatus,
                    style: TextStyle(
                      fontSize: 12,
                      color: _isGameActive ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: _isGameActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (_isGameCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Score: $_currentScore',
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
          if (_isGameActive && _timeRemaining > 0) _buildTimer(),
          const SizedBox(height: 16),
          _buildGameContent(),
          const SizedBox(height: 20),
          _buildGameControls(),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'How to Play',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _speakText(widget.game['instruction'] as String),
                icon: const Icon(
                  Icons.volume_up,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.game['instruction'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.game['instructionHebrew'] as String,
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

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Countdown(
            seconds: _timeRemaining,
            build: (BuildContext context, double time) {
              return Text(
                '${time.toInt()}s',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              );
            },
            interval: const Duration(seconds: 1),
            onFinished: () {
              setState(() {
                _isGameActive = false;
                _isGameCompleted = true;
                _gameStatus = 'Time\'s up!';
              });
              _completeGame();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    final gameType = widget.game['type'] as String;
    
    switch (gameType) {
      case 'hangman':
        return _buildHangmanGame();
      case 'letter_bingo':
        return _buildBingoGame();
      case 'charades':
        return _buildCharadesGame();
      case 'vowel_hunt':
        return _buildVowelHuntGame();
      case 'word_race':
        return _buildWordRaceGame();
      case 'memory_match':
        return _buildMemoryMatchGame();
      case 'security_scanner':
        return _buildSecurityScannerGame();
      case 'consonant_wheel':
        return _buildConsonantWheelGame();
      case 'sentence_scramble':
        return _buildSentenceScrambleGame();
      default:
        return _buildGenericGame();
    }
  }

  Widget _buildHangmanGame() {
    return Column(
      children: [
        // Draw hangman
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomPaint(
            painter: HangmanPainter(_wrongGuesses),
          ),
        ),
        const SizedBox(height: 20),
        // Display word with guessed letters
        Text(
          _getDisplayWord(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 20),
        // Available letters
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableLetters.map((letter) {
            final isGuessed = _guessedLetters.contains(letter);
            return InkWell(
              onTap: isGuessed || !_isGameActive ? null : () => _guessLetter(letter),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isGuessed ? Colors.grey[300] : AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isGuessed ? Colors.grey.shade600 : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text(
          'Wrong guesses: $_wrongGuesses/6',
          style: TextStyle(
            fontSize: 14,
            color: _wrongGuesses >= 6 ? AppColors.error : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBingoGame() {
    final gridSize = widget.game['gridSize'] as int;
    
    return Column(
      children: [
        Text(
          'Find and select the letters to complete lines!',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _bingoGrid.length,
          itemBuilder: (context, index) {
            final item = _bingoGrid[index];
            final isSelected = item['isSelected'] as bool;
            
            return InkWell(
              onTap: !_isGameActive ? null : () => _selectBingoItem(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.success : AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item['letter'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Selected: ${_selectedBingoItems.length}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCharadesGame() {
    final activities = widget.game['activities'] as List<dynamic>;
    if (_currentCharadeIndex >= activities.length) {
      return const Center(
        child: Text(
          'All activities completed!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
      );
    }
    
    final activity = activities[_currentCharadeIndex] as Map<String, dynamic>;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.emoji_people,
                size: 80,
                color: AppColors.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Act out this activity:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                activity['action'] as String,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                activity['hebrew'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hint: ${activity['hint'] as String}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: !_isGameActive ? null : _nextCharade,
                child: const Text('Next Activity'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVowelHuntGame() {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Airport Scene\n(Vowel Hunt)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Vowels found: $_currentScore',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildWordRaceGame() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                'Type this word:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentRaceWord,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          enabled: _isGameActive,
          onSubmitted: (value) => _checkWordRace(value),
          decoration: InputDecoration(
            hintText: 'Type the word here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        Text(
          'Words completed: $_raceWordsCompleted/${_wordRaceWords.length}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryMatchGame() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: _memoryCards.length,
          itemBuilder: (context, index) {
            final card = _memoryCards[index];
            final isFlipped = card['isFlipped'] as bool;
            final isMatched = card['isMatched'] as bool;
            
            return InkWell(
              onTap: !_isGameActive || isFlipped || isMatched ? null : () => _flipCard(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isMatched ? AppColors.success : (isFlipped ? AppColors.secondary : AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    isFlipped || isMatched ? card['text'] as String : '?',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Matches: ${_matchedCards.length ~/ 2}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityScannerGame() {
    final items = widget.game['items'] as List<dynamic>;
    
    return Column(
      children: [
        const Text(
          'Security Scanner',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) {
          final itemData = item as Map<String, dynamic>;
          final itemName = itemData['item'] as String;
          final isAllowed = itemData['allowed'] as bool;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: !_isGameActive ? null : () => _scanItem(itemName, true),
                      child: const Text('Allow'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: !_isGameActive ? null : () => _scanItem(itemName, false),
                      child: const Text('Deny'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildConsonantWheelGame() {
    final consonants = widget.game['consonants'] as List<dynamic>;
    
    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 4),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              consonants[Random().nextInt(consonants.length)],
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Create words using this consonant!',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: !_isGameActive ? null : () {
            setState(() {
              _currentScore += 10;
            });
          },
          child: const Text('Add Word'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceScrambleGame() {
    return Column(
      children: [
        const Text(
          'Drag the words to form the correct sentence:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // Scrambled words
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _scrambledWords.map((word) {
            return Draggable<String>(
              data: word,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  word,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              feedback: Material(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    word,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              childWhenDragging: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  word,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        // Drop zone
        DragTarget<String>(
          onAccept: (data) {
            setState(() {
              if (_userSentence.isEmpty) {
                _userSentence = data;
              } else {
                _userSentence += ' $data';
              }
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Center(
                child: Text(
                  _userSentence.isEmpty ? 'Drop words here' : _userSentence,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: !_isGameActive ? null : () {
                  setState(() {
                    _userSentence = '';
                  });
                },
                child: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: !_isGameActive || _userSentence.isEmpty ? null : _checkSentence,
                child: const Text('Check'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenericGame() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.games,
                size: 80,
                color: AppColors.primary,
              ),
              SizedBox(height: 16),
              Text(
                'Game Ready!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameControls() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isGameActive ? null : _startGame,
            child: Text(_isGameCompleted ? AppStrings.playAgain : 'Start Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (_isGameActive) ...[
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _endGame,
              child: const Text('End Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Game logic methods
  void _startGame() {
    setState(() {
      _isGameActive = true;
      _isGameCompleted = false;
      _currentScore = 0;
      _gameStatus = 'Game Active';
    });
    
    // Reset game-specific state
    _initializeGame();
  }

  void _endGame() {
    setState(() {
      _isGameActive = false;
      _isGameCompleted = true;
      _gameStatus = 'Game Ended';
    });
    
    _completeGame();
  }

  void _completeGame() {
    widget.onComplete(_currentScore);
    
    if (_currentScore >= 50) {
      _confettiController.play();
    }
  }

  // Hangman game methods
  void _guessLetter(String letter) {
    setState(() {
      _guessedLetters.add(letter);
      
      if (_currentWord.contains(letter)) {
        _currentScore += 10;
        if (_getDisplayWord().replaceAll(' ', '') == _currentWord) {
          _isGameActive = false;
          _isGameCompleted = true;
          _gameStatus = 'You Won!';
          _currentScore += 50;
          _completeGame();
        }
      } else {
        _wrongGuesses++;
        if (_wrongGuesses >= 6) {
          _isGameActive = false;
          _isGameCompleted = true;
          _gameStatus = 'Game Over';
          _completeGame();
        }
      }
    });
  }

  String _getDisplayWord() {
    return _currentWord.split('').map((letter) {
      return _guessedLetters.contains(letter) ? letter : '_';
    }).join(' ');
  }

  // Bingo game methods
  void _selectBingoItem(int index) {
    setState(() {
      _bingoGrid[index]['isSelected'] = !_bingoGrid[index]['isSelected'];
      final letter = _bingoGrid[index]['letter'] as String;
      
      if (_bingoGrid[index]['isSelected']) {
        _selectedBingoItems.add(letter);
        _currentScore += 5;
      } else {
        _selectedBingoItems.remove(letter);
        _currentScore -= 5;
      }
    });
  }

  // Charades game methods
  void _nextCharade() {
    setState(() {
      _currentCharadeIndex++;
      _currentScore += 20;
      
      if (_currentCharadeIndex >= (widget.game['activities'] as List).length) {
        _isGameActive = false;
        _isGameCompleted = true;
        _gameStatus = 'All activities completed!';
        _completeGame();
      }
    });
  }

  // Word race game methods
  void _checkWordRace(String input) {
    if (input.toUpperCase() == _currentRaceWord.toUpperCase()) {
      setState(() {
        _raceWordsCompleted++;
        _currentScore += 15;
        
        if (_raceWordsCompleted >= _wordRaceWords.length) {
          _isGameActive = false;
          _isGameCompleted = true;
          _gameStatus = 'All words completed!';
          _completeGame();
        } else {
          _currentRaceWord = _wordRaceWords[_raceWordsCompleted];
        }
      });
    }
  }

  // Memory match game methods
  void _flipCard(int index) {
    setState(() {
      _memoryCards[index]['isFlipped'] = true;
      _flippedCards.add(index);
      
      if (_flippedCards.length == 2) {
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    final card1 = _memoryCards[_flippedCards[0]];
    final card2 = _memoryCards[_flippedCards[1]];
    
    if (card1['pairId'] == card2['pairId']) {
      // Match found
      setState(() {
        _memoryCards[_flippedCards[0]]['isMatched'] = true;
        _memoryCards[_flippedCards[1]]['isMatched'] = true;
        _matchedCards.addAll(_flippedCards);
        _currentScore += 20;
        _flippedCards.clear();
        
        if (_matchedCards.length == _memoryCards.length) {
          _isGameActive = false;
          _isGameCompleted = true;
          _gameStatus = 'All matches found!';
          _completeGame();
        }
      });
    } else {
      // No match
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _memoryCards[_flippedCards[0]]['isFlipped'] = false;
          _memoryCards[_flippedCards[1]]['isFlipped'] = false;
          _flippedCards.clear();
        });
      });
    }
  }

  // Security scanner game methods
  void _scanItem(String item, bool decision) {
    final items = widget.game['items'] as List<dynamic>;
    final itemData = items.firstWhere((i) => i['item'] == item) as Map<String, dynamic>;
    final isAllowed = itemData['allowed'] as bool;
    
    if (decision == isAllowed) {
      setState(() {
        _currentScore += 10;
      });
    } else {
      Provider.of<AppProvider>(context, listen: false).logEvent('mistake', {
        'type': 'security_scan',
        'item': item,
        'userDecision': decision,
        'correct': isAllowed,
      });
    }
  }

  // Sentence scramble game methods
  void _checkSentence() {
    final sentences = widget.game['sentences'] as List<dynamic>;
    final correctSentence = sentences[0]['correct'] as List<dynamic>;
    final userWords = _userSentence.split(' ');
    
    bool isCorrect = true;
    if (userWords.length != correctSentence.length) {
      isCorrect = false;
    } else {
      for (int i = 0; i < userWords.length; i++) {
        if (userWords[i] != correctSentence[i]) {
          isCorrect = false;
          break;
        }
      }
    }
    
    if (isCorrect) {
      setState(() {
        _currentScore += 50;
        _isGameActive = false;
        _isGameCompleted = true;
        _gameStatus = 'Correct!';
      });
      _completeGame();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Try again!'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _speakText(String text) async {
    await _flutterTts?.speak(text);
  }
}

// Custom painter for hangman
class HangmanPainter extends CustomPainter {
  final int wrongGuesses;
  
  HangmanPainter(this.wrongGuesses);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw gallows
    if (wrongGuesses >= 1) {
      // Base
      canvas.drawLine(
        Offset(size.width * 0.1, size.height * 0.9),
        Offset(size.width * 0.6, size.height * 0.9),
        paint,
      );
      // Pole
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.9),
        Offset(size.width * 0.2, size.height * 0.1),
        paint,
      );
    }
    
    if (wrongGuesses >= 2) {
      // Top beam
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.1),
        Offset(size.width * 0.6, size.height * 0.1),
        paint,
      );
    }
    
    if (wrongGuesses >= 3) {
      // Noose
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.1),
        Offset(size.width * 0.6, size.height * 0.25),
        paint,
      );
    }
    
    if (wrongGuesses >= 4) {
      // Head
      canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.35),
        size.width * 0.08,
        paint,
      );
    }
    
    if (wrongGuesses >= 5) {
      // Body
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.43),
        Offset(size.width * 0.6, size.height * 0.7),
        paint,
      );
    }
    
    if (wrongGuesses >= 6) {
      // Arms
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.5),
        Offset(size.width * 0.5, size.height * 0.6),
        paint,
      );
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.5),
        Offset(size.width * 0.7, size.height * 0.6),
        paint,
      );
      // Legs
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.7),
        Offset(size.width * 0.5, size.height * 0.8),
        paint,
      );
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.7),
        Offset(size.width * 0.7, size.height * 0.8),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
