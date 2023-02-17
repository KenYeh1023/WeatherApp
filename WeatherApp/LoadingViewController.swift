//
//  LoadingViewController.swift
//  WeatherApp
//
//  Created by Ken on 2023/2/7.
//

import UIKit
import Lottie

struct WeatherInformationPack {
    var location: LocationIdentifiers
    var currentWeatherDataList: CurrentWeatherDataList
    var forecastWeatherDataList: ForecastWeatherDataList
}

class LoadingViewController: UIViewController {
    
    
    
    @IBOutlet weak var searchView: UIView!
    
    
    private var animationView: LottieAnimationView?
    
    private var networkManager = NetworkManager()
    
    var completionHandler: ((WeatherInformationPack)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
//        startAnimation()
    }
    
    func fetchWeatherInfo() {
        var currentWeatherDataList: CurrentWeatherDataList?
        var forecastWeatherDataList: ForecastWeatherDataList?
        
        if let location = Locations.locations.randomElement() {
            let currentWeatherUrl: URL = URL(string: networkManager.getUrlAddress(searchType: .currentWeather, cityId: location.value.cityIdentifier))!
            let forecastWeatherUrl: URL = URL(string: networkManager.getUrlAddress(searchType: .forecastWeather, cityId: location.value.cityIdentifier))!
            
            networkManager.request(url: currentWeatherUrl) { data in
                guard data != nil else { return }
                currentWeatherDataList = ParseJson.currentWeather(data: data!)
                self.networkManager.request(url: forecastWeatherUrl) { data in
                    forecastWeatherDataList = ParseJson.forecastWeather(data: data!)
                    self.completionHandler?(WeatherInformationPack(location: location.value, currentWeatherDataList: currentWeatherDataList!, forecastWeatherDataList: forecastWeatherDataList!))
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    func setBackground() {
        searchView.layer.cornerRadius = 20
        searchView.layer.masksToBounds = true
    }
    
    func startAnimation() {
        animationView = .init(name: "99274-loading")
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFit
        animationView?.loopMode = .playOnce
        animationView!.animationSpeed = 0.8
        view.addSubview(animationView!)
        animationView!.play()
        fetchWeatherInfo()
    }
}
