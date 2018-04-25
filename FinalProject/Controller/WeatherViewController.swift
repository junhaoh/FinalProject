//
//  MenuViewController.swift
//  FinalProject
//
//  Created by Junhao Huang on 4/17/18.
//  Copyright © 2018 Junhao Huang. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchWeather: UITextField!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var sunrise: UILabel!
    @IBOutlet weak var sunset: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let API_KEY = "8168da90c742bff558606086db896a95"
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }
    
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                print("Got weather data successfully!")
                let weatherJSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updataWeatherData(json: weatherJSON)
            } else {
                print("Error: \(String(describing: response.result.error))")
                self.cityName.text = "Failed Loading Weather"
            }
        }
    }
    
    func updataWeatherData(json: JSON) {
        let temp = json["main"]["temp"].doubleValue
        weatherDataModel.temperature = Int(temp - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.sunrise = json["sys"]["sunrise"].doubleValue
        weatherDataModel.sunset = json["sys"]["sunset"].doubleValue
        weatherDataModel.windSpeed = json["wind"]["speed"].doubleValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
        updateUI()
    }
    
    func updateUI() {
        cityName.text = weatherDataModel.city
        temperature.text = "\(weatherDataModel.temperature)°C"
        
        let sunriseTime = Date(timeIntervalSince1970: weatherDataModel.sunrise)
        let sunsetTime = Date(timeIntervalSince1970: weatherDataModel.sunset)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EDT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm"
        
        sunrise.text = dateFormatter.string(from: sunriseTime)
        sunset.text = dateFormatter.string(from: sunsetTime)
        
        let wind = String(format: "%.1f", weatherDataModel.windSpeed)
        windSpeed.text = "\(wind) m/s"
        
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            self.locationManager.startUpdatingLocation()
            let lat = "\(location.coordinate.latitude)"
            let lon = "\(location.coordinate.longitude)"
            
            let params = ["lat": lat, "lon": lon, "appid": API_KEY]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityName.text = "Location Unavailable"
    }
    
    
    @IBAction func getWeatherPressed(_ sender: UIButton) {
        let params = ["q": searchWeather.text!, "appid": API_KEY]
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }
    
}
