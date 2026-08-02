# Football Academy Game

A comprehensive football academy management simulation game built with Flutter featuring a cutting-edge futuristic capsule dashboard UI.

![Futuristic Dashboard UI](assets/images/dashboard_preview.png)

## About The Game

Take on the role of a football academy manager and guide your institution to glory! This game challenges you to build a successful football academy from the ground up. You'll be responsible for nurturing young talent, competing for trophies, and managing all the off-field aspects of running a football institution.

## UI & Design Features

- **Futuristic Neumorphic Capsule Aesthetics**: High-tech curved pill containers, luxury matte dark mode, and soft glass light mode.
- **Floating Navigation Sidebar**: Quick capsule navigation between Home, Finance, Squad, Scouting, Staff, Facilities, Transfers, Tournaments, and Settings.
- **Dynamic Header Bar**: Real-time Light/Dark theme quick-toggle, search bar, date pill indicator, news feed badge, and Advance Week action pill.
- **Interactive Visual Data Widgets**:
  - **Financial Vault Sparkline**: Cubic-spline trend line displaying budget health.
  - **Academy Reputation Spoke Ring**: Radial visual indicator of academy reputation & tier rating.
  - **Roster & Readiness Showcase**: Dark contrast showcase card featuring squad capacity, staff roster, facility levels, and squad morale progress bars.

## Features

*   **Academy Management:**
    *   Control your academy's name, finances, players, and staff.
    *   **Finances:** Manage your balance, weekly income, and expenses (wages).
    *   **Facilities:** Upgrade training, scouting, and medical facilities. Build and upgrade a merchandise store. Facility levels provide bonuses and increase staff capacity.
    *   **Scouting:** Send scouts to discover new talent. The quality of scouted players depends on scout skill and scouting facility level.
    *   **Reputation:** Your academy and players have reputation scores that influence various game elements.
    *   **Merchandise & Fans:** Manage merchandise sales and grow your fanbase, contributing to income.
    *   **News Feed:** Stay informed about game events through a news feed (match results, transfers, player improvements, facility upgrades, etc.).

*   **Player Development:**
    *   Players possess a wide range of attributes:
        *   Mental (Aggression, Composure, Vision, etc.)
        *   Physical (Acceleration, Stamina, Strength, etc.)
        *   Technical/Attacking (Crossing, Finishing, Passing, etc.)
        *   Defending (Marking, Tackling, etc.)
        *   Goalkeeping (Handling, Reflexes, etc.)
    *   Each player has a current skill level, a potential skill cap, and affinities for different playing positions.
    *   Train your players to improve their skills, influenced by your coaching staff and training facility levels.
    *   Players have market values, weekly wages, and can be bought and sold via a transfer system.

*   **Staff Management:**
    *   Hire and fire various staff members:
        *   Managers
        *   Coaches
        *   Scouts
        *   Physios
        *   Merchandise Managers
    *   Staff members have skill levels that impact training effectiveness, scouting success, match performance, and merchandise income.
    *   Staff capacity is linked to the level of your academy's facilities.

*   **Competitions & The Game World:**
    *   Participate in diverse tournaments with different formats (Knockout, League) and team sizes (3v3, 5v5, 7v7, 11v11).
    *   Tournaments feature entry fees, prize money, and reputation requirements.
    *   The game simulates matches with detailed event logs (goals, assists, etc.).
    *   Compete in "Pro Youth Leagues" across different tiers, featuring AI-controlled professional clubs and other youth academies.
    *   Experience promotion and relegation between league tiers based on performance.
    *   The game world is populated with rival academies and AI-controlled professional clubs that manage their own teams, finances, and participate in tournaments.
    *   AI clubs can make transfer offers for your players and players from other AI/rival teams.

*   **Game Progression & Mechanics:**
    *   The game progresses on a weekly basis.
    *   Each week triggers various actions: financial updates, scouting reports, match simulations, player training, staff actions, and more.
    *   Choose from different difficulty levels to tailor your management challenge.
    *   Save and load your game progress.
    *   Customize the application's theme (light/dark mode).

## Getting Started & Gameplay Tutorial

This project is a Flutter application. To run the game:

1.  Ensure you have Flutter installed and configured on your system.
2.  Clone this repository.
3.  Navigate to the project directory in your terminal.
4.  Run the command: `flutter run`

This will build and launch the application on a connected device or emulator.

### Your First Steps: A Manager's Journey

Welcome to your new role as an Academy Manager! Here's a guide to get you started:

1.  **Starting a New Game:**
    *   When you first launch the game, you'll be prompted to start a new game.
    *   You'll choose your **Academy Name** and select a **Difficulty Level**. Difficulty affects your starting balance, weekly income, initial reputation, and the strength of rival academies.

2.  **The Dashboard - Your Command Center:**
    *   After starting, you'll land on the **Dashboard**. This is your main hub for managing the academy.
    *   Key sections accessible from the Dashboard (usually via a navigation menu or buttons):
        *   **Finances:** View your balance, income, and expenses.
        *   **Player Management:** See your current squad, their stats, and manage their training assignments.
        *   **Staff Management:** Hire, fire, and view your current staff.
        *   **Facilities:** Check the status of your Training, Scouting, Medical, and Merchandise facilities and upgrade them.
        *   **Scouting:** View players found by your scouts and decide whether to sign or reject them.
        *   **Tournaments:** See available tournaments, join them, and track your progress.
        *   **News:** Keep up-to-date with weekly summaries, match results, transfer offers, and other important events.
        *   **Settings:** Adjust game settings like difficulty (before starting a new game usually) and theme.

3.  **The Weekly Cycle - Core Gameplay:**
    *   The game progresses week by week. Advancing the week is typically done via a button on the Dashboard.
    *   Each week, several things happen automatically:
        *   **Financial Update:** You'll receive weekly income and pay staff/player wages.
        *   **Scouting Reports:** If you have active scouts, they may find new players. These will appear in the Scouting screen.
        *   **Match Simulation:** If you're in a tournament and have matches scheduled for the week, they will be simulated. Results will appear in the News and Tournament Details.
        *   **Player Training:** Players assigned to coaches will train, potentially improving their skills.
        *   **Staff Market Refresh:** New staff may become available for hire, and some existing ones might leave the market.
        *   **Rival/AI Actions:** Other academies and AI clubs will also perform their weekly actions (training, transfers, etc.).
        *   **News Updates:** A summary of the week's key events will be added to your News feed.

4.  **Key Management Tasks:**

    *   **Player Management:**
        *   **Scouting:** Hire Scouts from the Staff Management screen. Better scouts and higher-level Scouting Facilities improve the quality and quantity of players found.
        *   **Signing Players:** Go to the Scouting screen to review prospects. If you like a player and can afford their (initial) wage, sign them to your academy.
        *   **Training:** Once a player is signed, go to Player Management or a dedicated Player Assignment screen. Assign them to a Coach. Players improve faster with better coaches and higher-level Training Facilities.
        *   **Transfers:** Other clubs (especially AI Pro Clubs) may make offers for your talented players. These will appear in the News and a dedicated Transfer Offers screen. You can accept or reject these offers. Selling players can be a good source of income but means losing talent.

    *   **Staff Management:**
        *   **Hiring:** Go to Staff Management. You'll see a list of available staff. Hire staff based on your needs and budget.
            *   **Manager:** (You usually start with one or this is you) Influences overall team performance.
            *   **Coaches:** Train players. Their skill determines training effectiveness.
            *   **Scouts:** Find new players. Their skill impacts scouting results.
            *   **Physios:** Help players recover from fatigue faster. More important as you play more matches.
            *   **Merchandise Manager:** Improves income from merchandise sales.
        *   **Staff Limits:** The number of Coaches, Scouts, and Physios you can hire is limited by your facility levels.

    *   **Facility Upgrades:**
        *   Go to the Facilities screen. Upgrading facilities costs money but provides significant benefits:
            *   **Training Facility:** Increases coach capacity and can improve training effectiveness.
            *   **Scouting Facility:** Increases scout capacity and can improve scouting results.
            *   **Medical Bay:** Increases physio capacity and improves player fatigue recovery.
            *   **Merchandise Store:** (If applicable) Allows hiring of Store Managers and increases merchandise income potential.
        *   Upgrades are crucial for long-term success.

    *   **Tournament Participation:**
        *   Go to the Tournaments screen. You'll see a list of available tournaments (knockout cups, leagues).
        *   Each tournament has requirements: minimum number of players, academy reputation, and an entry fee.
        *   If you meet the criteria, you can join.
        *   Matches will be simulated during the weekly progression. Track your progress and aim for the prize money and reputation boost from winning!
        *   **Pro Youth Leagues:** These are special, tiered leagues primarily for AI professional clubs. Your academy might be able to join lower tiers if your reputation is high enough. Success here can lead to promotion to higher tiers.

5.  **Long-Term Goals & Strategy:**

    *   **Build Your Reputation:** Winning matches, especially in tournaments, increases your academy's reputation. Higher reputation attracts better staff, more fans, and can unlock opportunities.
    *   **Develop Star Players:** Scout for high-potential youngsters and train them into valuable assets. You can either build your team around them or sell them for a large profit.
    *   **Achieve Financial Stability:** Manage your wages and expenses carefully. Winning tournaments and selling players are key income sources. Merchandise can also contribute.
    *   **Win Trophies:** The ultimate mark of success!
    *   **Climb the Ranks:** If you join the Pro Youth Leagues, aim for promotion to higher tiers to compete against stronger opponents.

    **Tips for Success:**
    *   **Balance your budget:** Don't overspend on wages or too many facility upgrades at once.
    *   **Invest in scouting early:** Finding good young players is key.
    *   **Prioritize training:** Develop your players to increase their value and on-field performance.
    *   **Read the news:** Stay informed about offers, results, and opportunities.
    *   **Save regularly!**

Good luck, Manager! Your journey to footballing greatness starts now.

---

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
