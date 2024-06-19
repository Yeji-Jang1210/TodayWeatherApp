//
//  Weather.swift
//  TodayWeatherApp
//
//  Created by 장예지 on 6/19/24.
//

import UIKit
import Kingfisher

struct CurrentWeather: Decodable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
}

struct Main: Decodable {
    let temp: Double
    let humidity: Int
    
    var convertCelsius: Int {
        return Int(round(temp - 273.15))
    }
}

struct Weather : Decodable{
    let main: String
    let icon: String
}

struct Wind : Decodable{
    let speed: Double
}
