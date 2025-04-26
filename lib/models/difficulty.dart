enum Difficulty {
  Easy,
  Normal,
  Hard,
}

// Optional: Helper for display names
String difficultyToString(Difficulty difficulty) {
  switch (difficulty) {
    case Difficulty.Easy:
      return 'Easy';
    case Difficulty.Normal:
      return 'Normal';
    case Difficulty.Hard:
      return 'Hard';
  }
}
