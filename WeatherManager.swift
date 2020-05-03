//
//  WeatherManager.swift
//  Clima
//
//  Created by Abhas Kumar on 4/27/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func  didUpdateWeather(_ weatherManager: WeatherManager, _: WeatherModel)
    func didFailedWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=0841f492da3d955f18d6a0cfa7ccc4a5&units=imperial"
    let temperature:Double = 0.0
    let city:String = ""
    var delegate:WeatherManagerDelegate?
    
    func fetchWeather(_ cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString)
    }
    
    func performRequest(_ urlString:String) {
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailedWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather)
                    }
                }
            }
            task.resume()
        }
        
    }
    func parseJSON(_ weatherData:  Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityname: name, temperature: temp)
            print(weather.temperatureString)
            return weather
        } catch {
            delegate?.didFailedWithError(error: error)
            return nil
        }
        
    }
    
}

