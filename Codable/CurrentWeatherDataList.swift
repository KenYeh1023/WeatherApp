
struct CurrentWeatherDataList: Codable {
    var id: Int
    var name: String
    var timezone: Int
    var weather: [Weather]
    var main: Main
    var wind: Wind
    var sys: Sys
    var cod: Int
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
    var pressure: Int
    var humidity: Int
}

struct Wind: Codable {
    var speed: Float
}

struct Sys: Codable {
    var country: String
    var sunrise: Int
    var sunset: Int
}
