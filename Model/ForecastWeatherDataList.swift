
struct ForecastWeatherDataList: Codable {
    var list: [List]
}

struct List: Codable {
    var dt: Int
    var main: Main
    var weather: [Weather]
    var dt_txt: String
}
