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

class LoadingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchView: UIView!
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        fetchWeatherInfo()
    }
    
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var locationImageView: UIImageView!
    
    private var animationView: LottieAnimationView?
    private var messageLabel: UILabel = UILabel()
    
    private var networkManager = NetworkManager()
    
    var searchTextField: UITextField = UITextField()
    
    var completionHandler: ((WeatherBrain)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
    }
    
    func fetchWeatherInfo() {
        guard searchTextField.text != nil || searchTextField.text != "" else { return }
        
        var currentWeatherDataList: CurrentWeatherDataList?
        var forecastWeatherDataList: ForecastWeatherDataList?
        
        var userInputText: String = searchTextField.text!
        userInputText = removeAdditionalSpaceInString(userInputText)
        
        startAnimation(type: .loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.networkManager.fetchCurrentWeather(cityName: userInputText) { data in
                guard let data = data else { self.startAnimation(type: .noResult)
                    return }
                currentWeatherDataList = data
                self.networkManager.fetchForecastWeather(cityId: "\(data.id)") { data in
                    guard let data = data else { self.startAnimation(type: .noResult)
                        return }
                    forecastWeatherDataList = data
                    self.completionHandler?(WeatherBrain(weatherData: WeatherData(currentWeatherData: currentWeatherDataList!, forecastWeatherData: forecastWeatherDataList!)))
                    self.dismiss(animated: true)
                }
            }
        }
        
        func removeAdditionalSpaceInString(_ string: String) -> String {
            var result = ""
            let stringArray: [String] = string.components(separatedBy: " ")
            guard stringArray.count > 1 else { return string }
            result = stringArray[0]
            for i in 1..<stringArray.count {
                if stringArray[i] == "" {
                    continue
                } else {
                    result += " " + stringArray[i]
                }
            }
            return result
        }
    }
    
    func setBackground() {
        searchTextField = self.view.viewWithTag(999) as! UITextField
        searchTextField.delegate = self
        searchTextField.attributedPlaceholder = NSAttributedString(string: "City Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapGesture(_:)))
        backgroundView.addGestureRecognizer(gesture)
        
        locationImageView.image = UIImage(named: "location")?.withRenderingMode(.alwaysTemplate)
        locationImageView.tintColor = .lightGray
        
        searchButton.imageView?.image = UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate)
        searchButton.layer.cornerRadius = 20
        searchButton.backgroundColor = UIColor(hexString: "#e2f6fd")
        searchButton.layer.opacity = 0.65
        
        searchButton.tintColor = .black
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        fetchWeatherInfo()
        return true
    }
}
