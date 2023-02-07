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
        return searchType.path + "?" + "id=\(cityId)&appid=9e8de8930618664ac4e71687dc3e86d8&units=metric"
    }
    
}
