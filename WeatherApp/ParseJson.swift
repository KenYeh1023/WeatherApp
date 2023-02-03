

struct DataList: Codable {
    var weather: [Weather]
    var main: Main
    var wind: Wind
}

struct Weather: Codable {
    var main: String
    var description: String
}

struct Main: Codable {
    var temp: Float
    var feels_like: Float
    var temp_min: Float
    var temp_max: Float
    var humidity: Int
}

struct Wind: Codable {
    var speed: Float
}