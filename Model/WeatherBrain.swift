//
//  WeatherBrain.swift
//  WeatherApp
//
//  Created by Ken on 2023/2/23.
//

import Foundation
import UIKit

struct WeatherBrain {
    
    var weatherData: WeatherData
        
    init(weatherData: WeatherData) {
        self.weatherData = weatherData
    }
    
    func dateStringTransfer(GMTSecs: Double, formatter: String) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: weatherData.currentWeatherData.timezone)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.dateFormat = formatter
        
        let time = Date(timeIntervalSince1970: GMTSecs)
        let dateString = dateFormatter.string(from: time)
        return dateString
    }
    
    func returnBackgroundImage() -> UIImage {
        let currentTimeInterval = Int(Date().timeIntervalSince1970)
        let sunriseTime = weatherData.currentWeatherData.sys.sunrise
        let sunsetTime = weatherData.currentWeatherData.sys.sunset
        guard currentTimeInterval >= sunriseTime && currentTimeInterval < sunsetTime else {
            return UIImage(named: "nighttime")!
        }
        return UIImage(named: "daytime")!
    }
    
    func getWeatherIconUrl(iconCode: String) -> String {
        return "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
    }
    
}
