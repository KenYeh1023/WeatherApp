//
//  ParseJson.swift
//  WeatherApp
//
//  Created by Ken on 2023/2/10.
//

import Foundation

class ParseJson {
    
    private init() { }
    
    static func currentWeather(data: Data) -> CurrentWeatherDataList? {
        do {
            let result = try JSONDecoder().decode(CurrentWeatherDataList.self, from: data)
            return result
        } catch {
            print(error)
            return nil
        }
    }
    
    static func forecastWeather(data: Data) -> ForecastWeatherDataList? {
        do {
            let result = try JSONDecoder().decode(ForecastWeatherDataList.self, from: data)
            return result
        } catch {
            print(error)
            return nil
        }
    }
}
