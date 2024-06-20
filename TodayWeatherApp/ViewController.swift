//
//  ViewController.swift
//  TodayWeatherApp
//
//  Created by 장예지 on 6/19/24.
//

import UIKit
import CoreLocation

import Lottie
import SnapKit

class ViewController: UIViewController {
    
    //MARK: - object
    let loadingBackView: UIView = {
        let object = UIView()
        object.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        object.isHidden = true
        return object
    }()
    
    let loadingAnimationView: LottieAnimationView = {
        let object = LottieAnimationView(name: "loading")
        object.loopMode = .loop
        object.contentMode = .scaleAspectFit
        return object
    }()
    
    let backgroundImage: UIImageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFill
        return object
    }()
    
    let dateLabel: UILabel = {
        let object = UILabel()
        object.font = DefaultFont.lightMediumLarge
        object.textColor = .white
        return object
    }()
    
    let locationImageView: UIImageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFit
        object.image = UIImage(systemName: "location.fill")
        object.tintColor = .white
        return object
    }()
    
    let locationLabel: UILabel = {
        let object = UILabel()
        object.font = DefaultFont.BoldLarge
        object.textColor = .white
        return object
    }()
    
    let sharedButton: UIButton = {
        let object = UIButton()
        object.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        object.tintColor = .white
        return object
    }()
    
    let refreshButton: UIButton = {
        let object = UIButton()
        object.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        object.tintColor = .white
        return object
    }()
    
    let tableView: UITableView = {
        let object = UITableView()
        object.allowsSelection = false
        object.isScrollEnabled = false
        object.backgroundColor = .clear
        object.separatorStyle = .none
        object.isHidden = true
        return object
    }()
    
    //MARK: - properties
    let locationManager = CLLocationManager()
    let defaultLocation = CLLocation(latitude: 37.5665, longitude: 126.9780)
    let geocoder = CLGeocoder()
    
    var locateText: String = "" {
        didSet {
            locationLabel.text = locateText
        }
    }
    
    var currentWeather: CurrentWeather?
    var currentTime: String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM월 dd일 HH시 mm분"
        return dateFormat.string(from: Date.now)
    }
    
    var isLoad: Bool = false {
        didSet {
            if isLoad {
                loadingBackView.isHidden = false
                loadingAnimationView.play()
            } else {
                loadingAnimationView.stop()
                loadingBackView.isHidden = true
            }
        }
    }
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        configureHierarchy()
        configureLayout()
        configureUI()
        
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    }
    
    //MARK: - configure function
    private func configureHierarchy(){
        view.addSubview(backgroundImage)
        view.addSubview(dateLabel)
        view.addSubview(locationImageView)
        view.addSubview(locationLabel)
        view.addSubview(sharedButton)
        view.addSubview(refreshButton)
        
        view.addSubview(tableView)
        
        view.addSubview(loadingBackView)
        loadingBackView.addSubview(loadingAnimationView)
    }
    
    private func configureLayout(){
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        locationImageView.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.leading)
            make.size.equalTo(24)
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.leading.equalTo(locationImageView.snp.trailing).offset(12)
            make.centerY.equalTo(locationImageView.snp.centerY)
        }
        
        sharedButton.snp.makeConstraints { make in
            make.leading.equalTo(locationLabel.snp.trailing).offset(12)
            make.centerY.equalTo(locationImageView.snp.centerY)
            make.size.equalTo(24)
        }
        
        refreshButton.snp.makeConstraints { make in
            make.leading.equalTo(sharedButton.snp.trailing).offset(20)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.size.equalTo(24)
            make.centerY.equalTo(locationImageView.snp.centerY)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(refreshButton.snp.bottom).offset(20)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        loadingBackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingAnimationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(200)
        }
        
    }
    
    private func configureUI(){
        configureTableView()
    }
    
    private func configureTableView(){
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: WeatherTableViewCell.identifier)
        tableView.register(WeatherImageTableViewCell.self, forCellReuseIdentifier: WeatherImageTableViewCell.identifier)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // 현재 트레이트 컬렉션 (라이트 모드 또는 다크 모드) 가져오기
        let currentTraitCollection = traitCollection

        // 트레이트 컬렉션에 따라 배경 이미지 설정
        if currentTraitCollection.userInterfaceStyle == .dark {
            backgroundImage.image = UIImage(named: "night")
        } else {
            backgroundImage.image = UIImage(named: "after_noon")
        }
    }
    
    func setInitialBackground(imageName: String) {
        backgroundImage.image = UIImage(named: imageName)
    }
    
    //MARK: - function
    private func checkDeviceLoationAuthorization(){
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.checkCurrentLocationAuthorizationStatus()
            } else {
                print("위치 서비스가 꺼져 있어서, 위치 권한 요청을 할 수 없어요.")
            }
        }
    }
    
    private func checkCurrentLocationAuthorizationStatus(){
        var status: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            showAlert()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            print("status: \(status)")
        }
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정>개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
        
        let settingAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let setting = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(setting)
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel){ _ in
            self.reverseGeocode(location: self.defaultLocation)
        }
        
        alert.addAction(settingAction)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    @objc func refreshButtonTapped(){
        locationManager.startUpdatingLocation()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        guard let data = currentWeather else { return cell }
        
        switch indexPath.row {
        case 0:
            cell.setText("지금은 \(data.main.convertCelsius)°C 에요")
        case 1:
            cell.setText("\(data.main.humidity)% 만큼 습해요")
        case 2:
            cell.setText("\(data.wind.speed)m/s 만큼 불어요")
        case 3:
            let imageCell = tableView.dequeueReusableCell(withIdentifier: WeatherImageTableViewCell.identifier, for: indexPath) as! WeatherImageTableViewCell
            if let url = data.weather.first?.icon {
                imageCell.setImage(APIInfo.getIconUrl(icon: url))
                return imageCell
            }
        case 4:
            cell.setText("오늘도 즐거운 하루 보내세요")
        default:
            break
        }
        
        return cell
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            reverseGeocode(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(#function)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLoationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function)
    }
    
    func reverseGeocode(location: CLLocation){
        // 역지오코딩 시작
        print("1")
        isLoad = true
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            print("2")
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
            } else if let placemarks = placemarks, let placemark = placemarks.first {
                // 행정 구역 정보 가져오기
                let city = placemark.locality ?? "Unknown City"
                let district = placemark.subLocality ?? "Unknown District"
                
                print("3")
                self.locateText = "\(city), \(district)"
            }
        }
        
        print("4")
        APIService.shared.callAPI(location.coordinate){ networkResult in
            print("5")
            switch networkResult {
            case .success(let data):
                print("6")
                self.dateLabel.text = self.currentTime
                self.currentWeather = data
                self.tableView.reloadData()
                self.tableView.isHidden = false
                print("7")
            case .failure(let error):
                print(error)
            }
            self.isLoad = false
            print("8")
        }
        
        print("9")
        // 위치 업데이트 멈추기
        locationManager.stopUpdatingLocation()
    }
}

