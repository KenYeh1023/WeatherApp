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
    
    var weatherBrain: WeatherBrain?
    
    override func viewWillAppear(_ animated: Bool) {
        self.animateCollection()
    }

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
            self.weatherBrain = data
            self.animateCollection()
            self.setBackground()
        }
        present(loadingViewController!, animated: true)
    }
    
    func setBackground() {
        backgroundImage.image = weatherBrain?.returnBackgroundImage()
        currentDateLabel.text = weatherBrain?.dateStringTransfer(GMTSecs: TimeInterval(NSDate().timeIntervalSince1970), formatter: "dd LLLL, EEEE")
        ISOButton.setTitle(weatherBrain?.weatherData.currentWeatherData.sys.country, for: .normal)
        locationButton.setTitle((weatherBrain?.weatherData.currentWeatherData.name ?? "") + "  ", for: .normal)
        currentTemperatureLabel.text = "\(Int(weatherBrain!.weatherData.currentWeatherData.main.temp))°C"
        currentTemperatureLabel.textColor = .white
        realFeelTemperatureLabel.text = "Real Feel \(Int(weatherBrain!.weatherData.currentWeatherData.main.feels_like))°C"
        //風速顯示為小數點後一位
        windLabel.text = String(format: "%.1f", weatherBrain!.weatherData.currentWeatherData.wind.speed) + " m/s"
        pressureLabel.text = "\(weatherBrain!.weatherData.currentWeatherData.main.pressure) hPa"
        humidityLabel.text = "\(weatherBrain!.weatherData.currentWeatherData.main.humidity) %"
        
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
        
    func animateCollection() {
        weatherCollectionView.contentOffset.x = 0
        weatherCollectionView.reloadData()
        //與 table view 不同, collection view 需要先呼叫 layoutSubviews() 或是 layoutIfNeeded() 才能正確獲取 visibleCells
        weatherCollectionView.layoutSubviews()
        let cells = weatherCollectionView.visibleCells
        let collectionWidth = weatherCollectionView.bounds.size.width
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: collectionWidth, y: 0)
        }
        
        var index = 0
        for cell in cells {
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                index += 1
            }
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(WeatherCollectionViewCell.self)", for: indexPath) as! WeatherCollectionViewCell
        
        let currentIconUrlString: String = weatherBrain!.getWeatherIconUrl(iconCode: weatherBrain!.weatherData.currentWeatherData.weather[0].icon)
        let forecastIconUrlString: String = weatherBrain!.getWeatherIconUrl(iconCode: weatherBrain!.weatherData.forecastWeatherData.list[0].weather[0].icon)
        
        if indexPath.row == 0 {
            cell.timeLabel.text = "NOW"
            cell.temperatureLabel.text = "\(Int(weatherBrain!.weatherData.currentWeatherData.main.temp))°C"
            cell.weatherImage.sd_setImage(with: URL(string: currentIconUrlString))
        } else {
            cell.timeLabel.text = weatherBrain?.dateStringTransfer(GMTSecs: Double(weatherBrain?.weatherData.forecastWeatherData.list[indexPath.row - 1].dt ?? 0), formatter: "h a")
            cell.temperatureLabel.text = "\(Int(weatherBrain!.weatherData.forecastWeatherData.list[indexPath.row - 1].main.temp))°C"
            cell.weatherImage.sd_setImage(with: URL(string: forecastIconUrlString))
        }
        return cell
    }
}
