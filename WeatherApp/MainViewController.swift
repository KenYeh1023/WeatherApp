//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ken on 2023/2/1.
//

import UIKit

struct Locations {
   static let locations: [String: LocationIdentifiers] = ["TAIPEI": LocationIdentifiers(locationName: "Taipei", localeIndentifier: "zh_Hant_TW", timeZoneIdentifier: "Asia/Taipei", cityIdentifier: "1668341"), "NEWYORK": LocationIdentifiers(locationName: "New York", localeIndentifier: "en_US", timeZoneIdentifier: "America/New_York", cityIdentifier: "5128581"), "LONDON": LocationIdentifiers(locationName: "London", localeIndentifier: "en_GB", timeZoneIdentifier: "Europe/London", cityIdentifier: "2643743")]
}

struct LocationIdentifiers {
    var locationName: String
    var localeIndentifier: String
    var timeZoneIdentifier: String
    var cityIdentifier: String
}

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
    @IBOutlet weak var locationButton: UIButton!
    
    var location: LocationIdentifiers?
    
    var locale: String {
        location?.localeIndentifier ?? "zh_Hant_TW"
    }
    var timeZone: String {
//        TimeZone.knownTimeZoneIdentifiers.filter{$0.contains(location)}[0]
        location?.timeZoneIdentifier ?? "Asia/Taipei"
    }
    
    var weatherCurrentArray: CurrentWeatherDataList?
    var weatherForecastArray: ForecastWeatherDataList?

    override func viewDidLoad() {
        super.viewDidLoad()
        weatherForecastArray = dateTimeFilter(array: weatherForecastArray!)
        setBackground()
    }
    
    func creatGradient(from: CGPoint, to: CGPoint, view: UIView)
        {
            let startGradientColor: UIColor = UIColor.init(hexString: "#b088fe")
            let endGradientColor: UIColor = UIColor.init(hexString: "#4e99ff")
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
            gradientLayer.startPoint = from
            gradientLayer.endPoint = to
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
    
    func presentLoadingView() {
        let loadingViewController = storyboard?.instantiateViewController(withIdentifier: "loadingViewController") as? LoadingViewController
        guard loadingViewController != nil else { return }
        loadingViewController?.modalTransitionStyle = .crossDissolve
        loadingViewController?.modalPresentationStyle = .overCurrentContext
        loadingViewController?.completionHandler = { data in
            self.weatherCurrentArray = data.currentWeatherDataList
            self.weatherForecastArray = data.forecastWeatherDataList
            self.location = data.location
            self.weatherCollectionView.reloadData()
            self.setBackground()
        }
        present(loadingViewController!, animated: true)
    }
    
    func setBackground() {
        currentDateLabel.text = dateStringTransfer(timeStamp: TimeInterval(NSDate().timeIntervalSince1970), formatterType: "current")
        
        locationButton.setTitle((location?.locationName ?? "Taipei") + "  ", for: .normal)
        currentTemperatureLabel.text = "\(Int(weatherCurrentArray!.main.temp))°C"
        realFeelTemperatureLabel.text = "Real Feel \(Int(weatherCurrentArray!.main.feels_like))°C"
        //風速顯示為小數點後一位
        windLabel.text = String(format: "%.1f", weatherCurrentArray!.wind.speed) + " m/s"
        pressureLabel.text = "\(weatherCurrentArray!.main.pressure) hPa"
        humidityLabel.text = "\(weatherCurrentArray!.main.humidity) %"
        
        weatherCollectionView.backgroundColor = UIColor.init(hexString: "#222A36")
        weatherCollectionView.layer.cornerRadius = 30
        temperatureView.layer.cornerRadius = 30
        
        windView.layer.cornerRadius = 30
        windView.layer.masksToBounds = true
        creatGradient(from: CGPoint(x: 0.5, y: 1), to: CGPoint(x: 0.5, y: 0),view: windView)
        
        pressureView.layer.cornerRadius = 30
        pressureView.layer.masksToBounds = true
        creatGradient(from: CGPoint(x: 0, y: 0.5), to: CGPoint(x: 1, y: 0.5),view: pressureView)

        humidityView.layer.cornerRadius = 30
        humidityView.layer.masksToBounds = true
        creatGradient(from: CGPoint(x: 0.5, y: 0), to: CGPoint(x: 0.5, y: 1),view: humidityView)

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
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
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