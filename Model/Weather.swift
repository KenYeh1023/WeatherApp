//
//  Weather.swift
//  WeatherApp
//
//  Created by Ken on 2023/2/23.
//

import Foundation

struct WeatherData {
    
    var currentWeatherData: CurrentWeatherDataList
    var forecastWeatherData: ForecastWeatherDataList
    
    init(currentWeatherData: CurrentWeatherDataList, forecastWeatherData: ForecastWeatherDataList) {
        self.currentWeatherData = currentWeatherData
        self.forecastWeatherData = forecastWeatherData
    }
    
}
