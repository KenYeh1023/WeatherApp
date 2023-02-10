//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Ken on 2023/2/1.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let networkManager = NetworkManager()
    
    private func enterInitialView(windScene: UIWindowScene, initView: UIViewController) {
        let window = UIWindow(windowScene: windScene)
        self.window = window
        self.window?.rootViewController = initView
        self.window?.makeKeyAndVisible()
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windScene: UIWindowScene = (scene as? UIWindowScene) else { return }
        
        var currentWeatherDataList: CurrentWeatherDataList?
        var forecastWeatherDataList: ForecastWeatherDataList?
        
        let currentWeatherUrl: URL = URL(string: networkManager.getUrlAddress(searchType: .currentWeather, cityId: "1668341"))!
        let forecastWeatherUrl: URL = URL(string: networkManager.getUrlAddress(searchType: .forecastWeather, cityId: "1668341"))!
        
        networkManager.request(url: currentWeatherUrl) { data in
            guard data != nil else { return }
            currentWeatherDataList = self.currentWeather(data: data!)
            self.networkManager.request(url: forecastWeatherUrl) { data in
                forecastWeatherDataList = self.forecastWeather(data: data!)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
                viewController.weatherCurrentArray = currentWeatherDataList
                viewController.weatherForecastArray2 = forecastWeatherDataList
                self.enterInitialView(windScene: windScene, initView: viewController)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func currentWeather(data: Data) -> CurrentWeatherDataList? {
        do {
            let result = try JSONDecoder().decode(CurrentWeatherDataList.self, from: data)
            return result
        } catch {
            print(error)
            return nil
        }
    }
    
    func forecastWeather(data: Data) -> ForecastWeatherDataList? {
        do {
            let result = try JSONDecoder().decode(ForecastWeatherDataList.self, from: data)
            return result
        } catch {
            print(error)
            return nil
        }
    }
}

