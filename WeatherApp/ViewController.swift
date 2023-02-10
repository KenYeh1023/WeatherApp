//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ken on 2023/2/1.
//

import UIKit

struct WeatherForecast {
    var time: String
    var weatherImage: UIImage
    var temperature: String
}

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var realFeelTemperatureLabel: UILabel!
    
    
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var temperatureView: UIView!
    @IBOutlet weak var windView: UIView!
    @IBOutlet weak var pressureView: UIView!
    @IBOutlet weak var humidityView: UIView!
    
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        presentLoadingView()
    }
    
    @IBOutlet weak var windImageView: UIImageView!
    @IBOutlet weak var pressureImageView: UIImageView!
    @IBOutlet weak var humidityImageView: UIImageView!
    
    var weatherCurrentArray: CurrentWeatherDataList?
    
    var weatherForecastArray: [WeatherForecast] = [WeatherForecast(time: "NOW", weatherImage: UIImage(named: "cloudy")!, temperature: "2°C"), WeatherForecast(time: "1 AM", weatherImage: UIImage(named: "cloudy")!, temperature: "5°C"), WeatherForecast(time: "2 AM", weatherImage: UIImage(named: "windy")!, temperature: "8°C"), WeatherForecast(time: "3 AM", weatherImage: UIImage(named: "storm")!, temperature: "8°C"), WeatherForecast(time: "4 AM", weatherImage: UIImage(named: "storm")!, temperature: "15°C")]

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
    }
    
    func setBackground() {
        
        currentTemperatureLabel.text = "\(Int(weatherCurrentArray!.main.temp))°C"
        realFeelTemperatureLabel.text = "Real Feel \(Int(weatherCurrentArray!.main.feels_like))°C"
        windLabel.text = "\(weatherCurrentArray!.wind.speed) m/s"
        pressureLabel.text = "\(weatherCurrentArray!.main.pressure) MB"
        humidityLabel.text = "\(weatherCurrentArray!.main.humidity) %"
        
        weatherCollectionView.backgroundColor = UIColor.init(hexString: "#222A36")
        weatherCollectionView.layer.cornerRadius = 30
        temperatureView.layer.cornerRadius = 30
        windView.backgroundColor = UIColor.init(hexString: "#222A36")
        windView.layer.cornerRadius = 30
        
        pressureView.backgroundColor = UIColor.init(hexString: "#222A36")
        pressureView.layer.cornerRadius = 30
        
        humidityView.backgroundColor = UIColor.init(hexString: "#222A36")
        humidityView.layer.cornerRadius = 30
        
        setImageView()
        
    }
    
    func setImageView() {
        let windImage = UIImage(named: "wind")?.withRenderingMode(.alwaysTemplate)
        windImageView.image = windImage
        windImageView.tintColor = .white
        
        let pressureImage = UIImage(named: "pressure")?.withRenderingMode(.alwaysTemplate)
        pressureImageView.image = pressureImage
        pressureImageView.tintColor = .white
        
        let humidityImage = UIImage(named: "humidity")?.withRenderingMode(.alwaysTemplate)
        humidityImageView.image = humidityImage
        humidityImageView.tintColor = .white
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(WeatherCollectionViewCell.self)", for: indexPath) as! WeatherCollectionViewCell
        cell.timeLabel.text = weatherForecastArray[indexPath.row].time
        cell.weatherImage.image = weatherForecastArray[indexPath.row].weatherImage
        cell.temperatureLabel.text = weatherForecastArray[indexPath.row].temperature
        
        return cell
    }
}
