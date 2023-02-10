
struct ForecastWeatherDataList: Codable {
    var list: [List]
}

struct List: Codable {
    var main: Main
    var weather: [Weather]
    var dt_dxt: String
}
