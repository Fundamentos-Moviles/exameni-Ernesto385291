import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscaminas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MinesweeperGame(),
    );
  }
}

class MinesweeperGame extends StatefulWidget {
  const MinesweeperGame({super.key});

  @override
  State<MinesweeperGame> createState() => _MinesweeperGameState();
}

class _MinesweeperGameState extends State<MinesweeperGame> {
  static const int gridSize = 6;

  // We add 8 bombs
  static const int bombCount = 8;

  late List<List<bool>> bombGrid;
  late List<List<bool>> revealedGrid;
  late List<List<bool>> flaggedGrid;
  bool gameOver = false;
  bool gameWon = false;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Initialize grids
    bombGrid = List.generate(gridSize, (_) => List.filled(gridSize, false));
    revealedGrid = List.generate(gridSize, (_) => List.filled(gridSize, false));
    flaggedGrid = List.generate(gridSize, (_) => List.filled(gridSize, false));

    // Place bombs randomly
    _placeBombs();

    gameOver = false;
    gameWon = false;
  }

  void _placeBombs() {
    int bombsPlaced = 0;
    while (bombsPlaced < bombCount) {
      int row = random.nextInt(gridSize);
      int col = random.nextInt(gridSize);

      if (!bombGrid[row][col]) {
        bombGrid[row][col] = true;
        bombsPlaced++;
      }
    }
  }

  void _onSquareTap(int row, int col) {
    if (gameOver || gameWon || revealedGrid[row][col]) {
      return;
    }

    setState(() {
      revealedGrid[row][col] = true;

      if (bombGrid[row][col]) {
        // Hit a bomb = game over
        gameOver = true;
        _revealAllBombs();
      } else {
        // Check if player won
        _checkWinCondition();
      }
    });
  }

  void _revealAllBombs() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (bombGrid[i][j]) {
          revealedGrid[i][j] = true;
        }
      }
    }
  }

  void _checkWinCondition() {
    int revealedCount = 0;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (revealedGrid[i][j]) {
          revealedCount++;
        }
      }
    }

    if (revealedCount == (gridSize * gridSize) - bombCount) {
      gameWon = true;
    }
  }

  void _restartGame() {
    setState(() {
      _initializeGame();
    });
  }

  Color _getSquareColor(int row, int col) {
    if (!revealedGrid[row][col]) {
      return Colors.grey[300]!;
    } else if (bombGrid[row][col]) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Buscaminas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Ernesto Vizcaino Alvarado',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    gameOver
                        ? 'Perdiste'
                        : gameWon
                        ? '¡Ganaste!'
                        : '¡No toques las bombas!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                      itemCount: gridSize * gridSize,
                      itemBuilder: (context, index) {
                        int row = index ~/ gridSize;
                        int col = index % gridSize;

                        return GestureDetector(
                          onTap: () => _onSquareTap(row, col),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getSquareColor(row, col),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _restartGame,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(
                gameOver ? 'Intentar de nuevo' : 'Reiniciar',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
