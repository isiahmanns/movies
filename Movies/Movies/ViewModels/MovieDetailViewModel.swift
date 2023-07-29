struct MovieDetailViewModel {
    let movie: Movie
    private let api: MoviesAPI

    init(movie: Movie, api: MoviesAPI) {
        self.movie = movie
        self.api = api
    }


}
