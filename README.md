<<<<<<< HEAD
# FlixSphere
=======
# Flutter Movie App
>>>>>>> 852cb79ddbd2025262b00888027fd727166e0a3f

**FlixSphere** is a modern, premium Flutter application for discovering Movies and TV Series. Powered by the TMDB API, it provides users with up-to-date trending content, deep insights, trailers, and reviews, all wrapped in a sleek, glassmorphic dark theme.

## Features

- **Discover Content**: Browse Trending, Popular, Top Rated, Now Playing, and Upcoming Movies & TV Series.
- **Deep Details**: View comprehensive information including synopses, genres, runtimes, budgets, revenues, and release dates.
- **Watch Trailers**: Integrated YouTube player for watching official trailers natively across all platforms (Web, Android, iOS).
- **User Reviews**: Read what others are saying with the integrated user review system.
- **Search Engine**: Robust, debounced search functionality to instantly find your favorite movies or shows.
- **Modern UI/UX**: 
  - Premium dark theme with vibrant amber accents.
  - Smooth page transitions and micro-animations.
  - Glassmorphism UI components and gradient overlays.
  - Edge-to-edge UI support and Shimmer loading effects.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: Stateful/FutureBuilder (Optimized)
- **API**: [The Movie Database (TMDB) API](https://developer.themoviedb.org/docs)

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

- Flutter SDK (>=3.4.3 <4.0.0)
- TMDB API Key (Get one free at [TMDB](https://www.themoviedb.org/))

### Installation

1. **Clone the repository** (if applicable):
   ```bash
   git clone https://github.com/dwnwp/flutter-movie-app.git
   cd flutter-movie-app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up Environment Variables**:
   Create a `.env` file in the root directory of the project and add your TMDB API key:
   ```env
   TMDB_API_KEY=your_api_key_here
   ```

4. **Run the App**:
   ```bash
   flutter run
   ```

## Cross-Platform Support
FlixSphere is fully optimized for cross-platform deployment:
- **Mobile** (Android & iOS)
