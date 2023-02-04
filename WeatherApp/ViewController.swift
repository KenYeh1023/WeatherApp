//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ken on 2023/2/1.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var temperatureView: UIView!
    
    @IBOutlet weak var windView: UIView!
    
    @IBOutlet weak var pressureView: UIView!
    
    @IBOutlet weak var humidityView: UIView!
    
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
        temperatureView.layer.cornerRadius = 10
        windView.backgroundColor = UIColor.init(hexString: "#222A36")
        windView.layer.cornerRadius = 10
        
        pressureView.backgroundColor = UIColor.init(hexString: "#222A36")
        pressureView.layer.cornerRadius = 10
        
        humidityView.backgroundColor = UIColor.init(hexString: "#222A36")
        humidityView.layer.cornerRadius = 10
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
