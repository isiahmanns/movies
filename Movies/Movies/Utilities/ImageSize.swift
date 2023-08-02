protocol ImageSize {}

enum PosterSize: String, ImageSize {
    case w92
    case w154
    case w185
    case w342
    case w500
    case w780
    case original
}

enum ProfileSizes: String, ImageSize {
    case w45
    case w185
    case h632
}
