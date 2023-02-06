//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ken on 2023/2/1.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var temperatureView: UIView!
    @IBOutlet weak var windView: UIView!
    @IBOutlet weak var pressureView: UIView!
    @IBOutlet weak var humidityView: UIView!
    
    
    @IBOutlet weak var windImageView: UIImageView!
    
    
    @IBOutlet weak var pressureImageView: UIImageView!
    
    @IBOutlet weak var humidityImageView: UIImageView!
    
    let networkManager: NetworkManager = NetworkManager()
    let params: String = Api.currentWeather.path + "?q=london&appid=9e8de8930618664ac4e71687dc3e86d8&units=metric"

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
//        let url: URL = URL(string: params)!
//        self.view.backgroundColor = UIColor.init(hexString: "#222A36")
//        networkManager.request(url: url) { data in
//            print(self.parseJson(data: data!))
//        }
    }
    
    func setBackground() {
        
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
    
    func parseJson(data: Data) -> DataList? {
        do {
            let result = try JSONDecoder().decode(DataList.self, from: data)
            return result
        } catch {
            print(error)
            return nil
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(WeatherCollectionViewCell.self)", for: indexPath) as! WeatherCollectionViewCell
        cell.weatherImage.image = UIImage(named: "cloudy")
        cell.timeLabel.text = "3 AM"
        cell.temperatureLabel.text = "9°C"
        
        return cell
    }
}
