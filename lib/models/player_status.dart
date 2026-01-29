enum PlayerStatus {
  Starter, // Regularly selected for matches
  Bench, // Available for selection, but not first choice
  Reserve, // Not typically selected, maybe youth or recovering
  Injured, // Unavailable due to injury (TODO: Implement injuries)
  LoanedOut, // Unavailable, playing for another club (TODO: Implement loans)
}

// Helper function to get a display string for the status
String playerStatusToString(PlayerStatus status) {
  switch (status) {
    case PlayerStatus.Starter:
      return 'Starter';
    case PlayerStatus.Bench:
      return 'Bench';
    case PlayerStatus.Reserve:
      return 'Reserve';
    case PlayerStatus.Injured:
      return 'Injured';
    case PlayerStatus.LoanedOut:
      return 'Loaned Out';
    default:
      return 'Unknown';
  }
}
