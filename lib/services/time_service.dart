class TimeService {
  DateTime _currentDate = DateTime(2025, 1, 1);

  DateTime get currentDate => _currentDate;

  void initialize(DateTime date) {
    _currentDate = date;
  }

  // Advance by one week (7 days)
  void advanceWeek() {
    _currentDate = _currentDate.add(const Duration(days: 7));
  }

  // Check if it's a new month (run at start of week processing)
  bool isFirstWeekOfMonth() {
    return _currentDate.day <= 7;
  }

  // Check if it's the end of the season (e.g., late May)
  bool isEndOfSeason() {
    return _currentDate.month == 5 && _currentDate.day >= 22;
  }
}
