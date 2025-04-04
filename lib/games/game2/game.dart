import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game_arcade/games/game2/constants.dart';
import 'package:game_arcade/games/game2/components/background.dart';
import 'package:game_arcade/games/game2/components/bird.dart';
import 'package:game_arcade/games/game2/components/ground.dart';
import 'package:game_arcade/games/game2/components/pipe.dart';
import 'package:game_arcade/games/game2/components/pipe_manager.dart';
import 'package:game_arcade/games/game2/components/score.dart'; // Ensure this import is included
import 'package:game_arcade/controllers/score_controller.dart';

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Bird bird;
  late Background background;
  late Ground ground;
  late PipeManager pipe;
  late ScoreText scoreText;

  bool isGameOver = false;
  final double groundScrollingSpeed = 100;

  // ScoreController instance
  final ScoreController _scoreController = ScoreController();

  @override
  Future<void> onLoad() async {
    // Add background
    add(Background());

    // Add bird
    bird = Bird();
    add(bird);

    // Add ground
    add(Ground());

    // Add pipe manager
    add(PipeManager());

    add(ScoreText());
  }

  /*
  TAP
  */
  @override
  void onTap() {
    bird.flap();
  }

  // SCORES

  int score = 0;

  void incrementScore() {
    score += 1;
  }

  // GAME OVER

  void gameOver() {
    // prevent multiple game over triggers
    if (isGameOver) return;

    isGameOver = true;
    pauseEngine();

    // Save the score to Firestore using the ScoreController
    _scoreController.saveScore(
      gameName: 'FlappyBird',
      score: score,
    );

    // show dialog box for user
    showDialog(
      context: buildContext!,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text("High Score: $score"),
        actions: [
          TextButton(
            onPressed: () {
              // Pop the dialog box
              Navigator.pop(context);

              // Reset the game
              resetGame();
            },
            child: const Text("Restart"),
          ),
          TextButton(
            onPressed: () {
              // Navigate back to the main screen
              Navigator.pop(context); // Close the dialog
              Navigator.pop(buildContext!); // Navigate back to the main screen
            },
            child: const Text("Main Menu"),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    bird.position = Vector2(birdStartX, birdStartY);
    bird.velocity = 0;
    score = 0;
    isGameOver = false;
    children.whereType<Pipe>().forEach((Pipe pipe) => pipe.removeFromParent());
    resumeEngine();
  }
}