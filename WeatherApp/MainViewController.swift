//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ken on 2023/2/1.
//

import UIKit
import SDWebImage

struct WeatherForecast {
    var time: String
    var weatherImage: UIImage
    var temperature: String
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var realFeelTemperatureLabel: UILabel!
    
    @IBOutlet weak var ISOButton: UIButton!
    
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
    
    var weatherCurrentArray: CurrentWeatherDataList?
    var weatherForecastArray: ForecastWeatherDataList?

    override func viewDidLoad() {
        super.viewDidLoad()
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
            self.weatherCollectionView.reloadData()
            self.setBackground()
        }
        present(loadingViewController!, animated: true)
    }
    
    func setBackground() {
        backgroundImage.image = checkDayOrNight()
        UIView.animate(withDuration: 0.5, animations: {
             self.weatherCollectionView.contentOffset.x = 0
        })
        currentDateLabel.text = dateStringTransfer(GMTSecs: TimeInterval(NSDate().timeIntervalSince1970), formatterType: "current")
        ISOButton.setTitle(weatherCurrentArray?.sys.country, for: .normal)
        locationButton.setTitle((weatherCurrentArray?.name ?? "") + "  ", for: .normal)
        currentTemperatureLabel.text = "\(Int(weatherCurrentArray!.main.temp))°C"
        currentTemperatureLabel.textColor = .white
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
    
    func dateStringTransfer(GMTSecs: Double, formatterType: String) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: weatherCurrentArray?.timezone ?? 0)
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
        let time = Date(timeIntervalSince1970: GMTSecs)
        let dateString = dateFormatter.string(from: time)
        return dateString
    }
    
    func checkDayOrNight() -> UIImage {
        let currentTimeInterval = Int(Date().timeIntervalSince1970)
        let sunriseTime = weatherCurrentArray?.sys.sunrise ?? 0
        let sunsetTime = weatherCurrentArray?.sys.sunset ?? 0
        guard currentTimeInterval >= sunriseTime && currentTimeInterval < sunsetTime else {
            return UIImage(named: "nighttime")!
        }
        return UIImage(named: "daytime")!
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(WeatherCollectionViewCell.self)", for: indexPath) as! WeatherCollectionViewCell
        let currentIconUrlString: String = "https://openweathermap.org/img/wn/\(weatherCurrentArray?.weather[0].icon ?? "01d")@2x.png"
        let forecastIconUrlString: String = "https://openweathermap.org/img/wn/\(weatherForecastArray?.list[0].weather[0].icon ?? "01d")@2x.png"

        if indexPath.row == 0 {
            cell.timeLabel.text = "NOW"
            cell.temperatureLabel.text = "\(Int(weatherCurrentArray!.main.temp))°C"
            cell.weatherImage.sd_setImage(with: URL(string: currentIconUrlString))
        } else {
            cell.timeLabel.text = dateStringTransfer(GMTSecs: Double(weatherForecastArray?.list[indexPath.row - 1].dt ?? 0), formatterType: "forecast")
            cell.temperatureLabel.text = "\(Int(weatherForecastArray!.list[indexPath.row - 1].main.temp))°C"
            cell.weatherImage.sd_setImage(with: URL(string: forecastIconUrlString))
        }
        return cell
    }
}
