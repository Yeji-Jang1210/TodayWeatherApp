//
//  APIService.swift
//  TodayWeatherApp
//
//  Created by 장예지 on 6/20/24.
//

import UIKit
import CoreLocation

import Alamofire

class APIService {
    static let shared = APIService()
    
    private init(){}
    
    func callAPI(_ location: CLLocationCoordinate2D, completion: @escaping (NetworkResult) -> Void ){
        let queryString = APIParameters(lon: location.longitude, lat: location.latitude).convertQueryString()
        
        guard let url = URL(string: APIInfo.url) else { return }
        
        AF.request(url, parameters: queryString).responseDecodable(of: CurrentWeather.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

enum NetworkResult {
    case success(CurrentWeather)
    case failure(AFError)
}
