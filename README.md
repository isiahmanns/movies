# Movies 🍿

This is an iOS app that demonstrates how to consume a REST API ([TMDB][TMDB-link]) and show the data in a collection view.

Features:
- `UIKit`
- Modern concurrency (asynchronous image fetching, async/await, task management, actors)
- Image caching with `NSCache`
- Asset loading states for UI feedback during and after network requests
- Pagination + efficient table updates with `UICollectionView` 
- JSON parsing with `Decodable`
- MV* architecture, DI
- Persistence via Core Data

The Now Playing and Upcoming movie lists are driven by network calls to TMDB.  
The Watchlist is an offline list powered by Core Data, which fetches movies from disk that the user previously bookmarked.  
This app is ready to run after setting an `API_KEY` in the configuration file 🥂.

[TMDB-link]: https://www.themoviedb.org/?language=en-US
