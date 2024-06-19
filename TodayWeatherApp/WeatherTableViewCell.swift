//
//  WeatherTableViewCell.swift
//  TodayWeatherApp
//
//  Created by 장예지 on 6/19/24.
//

import UIKit

import SnapKit
import Kingfisher

class WeatherTableViewCell: UITableViewCell {
    static var identifier: String = String(describing: WeatherTableViewCell.self)
    
    //MARK: - object
    let backView: UIView = {
        let object = UIView()
        object.backgroundColor = .white
        object.clipsToBounds = true
        object.layer.cornerRadius = 4
        return object
    }()
    
    let weatherLabel : UILabel = {
       let object = UILabel()
        object.textColor = .black
        object.font = DefaultFont.lightMediumLarge
        return object
    }()
    
    //MARK: - properties
    
    //MARK: - life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - configure function
    private func configureHierarchy(){
        contentView.addSubview(backView)
        
        backView.addSubview(weatherLabel)
    }
    
    private func configureLayout(){
        backView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(20)
        }
        
        weatherLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
            make.height.equalTo(20)
        }
    }
    
    private func configureUI(){
        self.backgroundColor = .clear
    }
    
    //MARK: - function
    public func setText(_ text: String){
        weatherLabel.text = text
    }
}
