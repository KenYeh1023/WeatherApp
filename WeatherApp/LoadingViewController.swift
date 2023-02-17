//
//  LoadingViewController.swift
//  WeatherApp
//
//  Created by Ken on 2023/2/7.
//

import UIKit
import Lottie

enum AnimationType: String {
    case noResult = "noResult"
    case loading = "loading"
}

struct WeatherInformationPack {
    var location: LocationIdentifiers
    var currentWeatherDataList: CurrentWeatherDataList
    var forecastWeatherDataList: ForecastWeatherDataList
}

class LoadingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchView: UIView!
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        fetchWeatherInfo()
    }
    
    @IBOutlet var backgroundView: UIView!
    
    private var animationView: LottieAnimationView?
    private var messageLabel: UILabel = UILabel()
    
    private var networkManager = NetworkManager()
    
    var searchTextField: UITextField = UITextField()
    
    var completionHandler: ((WeatherInformationPack)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
    }
    
    func fetchWeatherInfo() {
        guard searchTextField.text != nil || searchTextField.text != "" else { return }
        var currentWeatherDataList: CurrentWeatherDataList?
        var forecastWeatherDataList: ForecastWeatherDataList?
        
        var userInputText: String = searchTextField.text!
        userInputText = userInputText.replacingOccurrences(of: " ", with: "").uppercased()
        let index = Locations.locations.firstIndex(where: {$0.key == userInputText})
        startAnimation(type: .loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard let index = index else {
                self.startAnimation(type: .noResult)
                return }
            let location = Locations.locations[index]
            
            let currentWeatherUrl: URL = URL(string: self.networkManager.getUrlAddress(searchType: .currentWeather, cityId: location.value.cityIdentifier))!
            let forecastWeatherUrl: URL = URL(string: self.networkManager.getUrlAddress(searchType: .forecastWeather, cityId: location.value.cityIdentifier))!
            
            self.networkManager.request(url: currentWeatherUrl) { data in
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
    
    func startAnimation(type: AnimationType) {
        animationView?.removeFromSuperview()
        messageLabel.removeFromSuperview()
        
        animationView = .init(name: type.rawValue)
        switch type {
        case .noResult:
            view.addSubview(messageLabel)
            messageLabel.text = "Oops! Invalid Location ;("
            messageLabel.font = UIFont(name: "system", size: 16)
            messageLabel.textColor = .white
            messageLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
            messageLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
            messageLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            messageLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 100).isActive = true
            //put it third
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
        default: break
        }
        
        //Mark:- 順序很重要！！！！！
        //put it first
        view.addSubview(animationView!)
        //put them second
        animationView?.widthAnchor.constraint(equalToConstant: 200).isActive = true
        animationView?.heightAnchor.constraint(equalToConstant: 200).isActive = true
        animationView?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        animationView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        //put it third
        animationView?.translatesAutoresizingMaskIntoConstraints = false

        
        animationView!.contentMode = .scaleAspectFit
        animationView?.loopMode = .loop
        animationView!.animationSpeed = 0.8
//        view.addSubview(animationView!)
        animationView?.play()
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
        let noNeedToRestrict = CharacterSet(charactersIn: " ") //可以打空白
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
