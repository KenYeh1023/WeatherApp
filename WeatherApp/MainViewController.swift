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
    
    @IBOutlet weak var currentDateLabel: UILabel!
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
    
    var location: String = "Taipei"
    var timeZone: String {
        TimeZone.knownTimeZoneIdentifiers.filter{$0.contains(location)}[0]
    }
    
    var weatherCurrentArray: CurrentWeatherDataList?
    var weatherForecastArray: ForecastWeatherDataList?

    override func viewDidLoad() {
        super.viewDidLoad()
        weatherForecastArray = dateTimeFilter(array: weatherForecastArray!)
        setBackground()
    }
    
    func setBackground() {
        currentDateLabel.text = dateStringTransfer(timeStamp: TimeInterval(NSDate().timeIntervalSince1970), formatterType: "current")
        
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
    
    func dateStringTransfer(timeStamp: Double, formatterType: String) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        switch formatterType {
        case "current":
            dateFormatter.dateFormat = "dd LLLL, EEEE"
        case "forecast":
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.dateFormat = "h a"
        default: break
        }
        let time = Date(timeIntervalSince1970: timeStamp)
        let dateString = dateFormatter.string(from: time)
        return dateString
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(WeatherCollectionViewCell.self)", for: indexPath) as! WeatherCollectionViewCell
        if indexPath.row == 0 {
            cell.timeLabel.text = "NOW"
            cell.temperatureLabel.text = "\(Int(weatherCurrentArray!.main.temp))°C"
        } else {
            cell.timeLabel.text = dateStringTransfer(timeStamp: Double(weatherForecastArray?.list[indexPath.row - 1].dt ?? 0), formatterType: "forecast")
            cell.temperatureLabel.text = "\(Int(weatherForecastArray!.list[indexPath.row - 1].main.temp))°C"
        }
        cell.weatherImage.image = UIImage(named: "storm")
        
        return cell
    }
    
    func dateTimeFilter(array: ForecastWeatherDataList) -> ForecastWeatherDataList {
        var array = array
        let currentTimeStamp: Double = getTimeIntervalByTimeZone(timeZoneId: timeZone)
        var forecastTimeStamp: Double = Double(array.list[0].dt)
        guard currentTimeStamp > forecastTimeStamp else { return array}
        for _ in 0..<array.list.count {
            array.list.remove(at: 0)
            forecastTimeStamp = Double(array.list[0].dt)
            if forecastTimeStamp > currentTimeStamp {
                break
            }
        }
        return array
    }
    
    func getTimeIntervalByTimeZone(timeZoneId: String) -> Double {
        let timezone = TimeZone(identifier: "America/New_York")!
        let seconds = TimeInterval(timezone.secondsFromGMT(for: Date()))
        //拿到該時區當下日期與時間
        let date = Date(timeInterval: seconds, since: Date())
        //轉換成 Time Interval
        let timeInterval = TimeInterval(date.timeIntervalSince1970)

        return timeInterval
    }
}
