//
//  APIInfo.swift
//  TodayWeatherApp
//
//  Created by 장예지 on 6/19/24.
//

import Foundation

struct APIInfo {
    private init(){}
    
    static var url = "https://api.openweathermap.org/data/2.5/weather"
    static var apiKey = "011403b307bff9d59e037082360b03a1"
    
    static func getIconUrl(icon: String)-> String{
        return "https://openweathermap.org/img/wn/\(icon)@2x.png"
    }
}


struct APIParameters {
    let lon: Double
    let lat: Double
    
    func convertQueryString() -> [String: Any] {
        return ["lat": lat, "lon": lon, "appid": APIInfo.apiKey]
    }
}
