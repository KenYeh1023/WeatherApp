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

class LoadingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchView: UIView!
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        print(searchTextField.text ?? "???")
    }
    
    @IBOutlet var backgroundView: UIView!
    
    private var animationView: LottieAnimationView?
    
    private var networkManager = NetworkManager()
    
    var searchTextField: UITextField = UITextField()
    
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
        searchTextField = self.view.viewWithTag(999) as! UITextField
        searchTextField.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapGesture(_:)))
        backgroundView.addGestureRecognizer(gesture)
        
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
    
    @objc private func backgroundTapGesture(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
}

extension LoadingViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let countOfWords = string.count + textField.text!.count - range.length
        guard countOfWords < 20 else { return false }
        return string.containsValidCharacter
    }
}

//禁止使用者輸入特殊字元
extension String {
    var containsValidCharacter: Bool {
        guard self != "" else { return true }
        let noNeedToRestrict = CharacterSet(charactersIn: "_") //可以打斜線
        if noNeedToRestrict.containsUnicodeScalars(of: self.last!) {
            return true
        } else {
            return CharacterSet.alphanumerics.containsUnicodeScalars(of: self.last!)
        }
    }
}

extension CharacterSet {
    func containsUnicodeScalars(of character: Character) -> Bool {
        return character.unicodeScalars.allSatisfy(contains(_:))
    }
}
