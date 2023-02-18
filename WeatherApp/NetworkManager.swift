//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Ken on 2023/2/1.
//

import Foundation

enum Api: String {
    
    case currentWeather = "/weather"
    case forecastWeather = "/forecast"
    
    private var baseUrl: String { "https://api.openweathermap.org/data/2.5" }
    
    var path: String { baseUrl + self.rawValue }
}

class NetworkManager {
    
    func request(url: URL, resultHandler: ((Data?) -> Void)? = nil) {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                resultHandler?(data)
            }
            if let response = response as? HTTPURLResponse {
                print("statusCode:", response.statusCode)
            }
            if let error = error {
                print("error:",error)
                return
            }
        }
        task.resume()
    }
    
    func getUrlAddress(searchType: Api, cityId: String) -> String {
        switch searchType {
        case .currentWeather:
            return searchType.path + "?" + "q=\(cityId)&appid=9e8de8930618664ac4e71687dc3e86d8&units=metric"
        case .forecastWeather:
            return searchType.path + "?" + "id=\(cityId)&appid=9e8de8930618664ac4e71687dc3e86d8&units=metric"
        }
    }
    
    func fetchCurrentWeather(cityName: String, _ completion: @escaping (CurrentWeatherDataList?) -> ()) {
        guard let url: URL = URL(string: getUrlAddress(searchType: .currentWeather, cityId: cityName)) else { return }
        request(url: url) { data in
            if let data = data{
                guard let currentWeatherData: CurrentWeatherDataList = ParseJson.currentWeather(data: data) else {
                    completion(nil)
                    return
                }
                completion(currentWeatherData)
            }
        }
    }
    
    func fetchForecastWeather(cityId: String,_ completion: @escaping (ForecastWeatherDataList?) -> ()) {
        guard let url: URL = URL(string: getUrlAddress(searchType: .forecastWeather, cityId: cityId)) else { return }
        request(url: url) { data in
            if let data = data{
                guard let forecastWeatherData: ForecastWeatherDataList = ParseJson.forecastWeather(data: data) else {
                    completion(nil)
                    return
                }
                completion(forecastWeatherData)
            }
        }
    }
}
