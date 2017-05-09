//
//  SubwayMapView.swift
//  Metro Navigator
//
//  Created by Illia Lysenko on 4/21/17.
//  Copyright © 2017 intellogic. All rights reserved.
//

import UIKit

class SubwayMapView: UIImageView {
  
    let stationPointRadius: CGFloat = 30.05
    var labels: [UILabel] = []
    var locationMarkImageView: UIImageView?
    
    convenience init(){
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(city: String){
        let image = UIImage(named: city)!
        self.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: image.size))
        self.image = image
    }

    func activate(_ station: Subway.Station){
        station.label?.textColor = UIColor.white
        station.label?.backgroundColor = UIColor.darkGray
    }
    
    func deactivate(_ station: Subway.Station){
        station.label?.textColor = UIColor.black
        station.label?.backgroundColor = UIColor.clear
    }
    
    func hide (station: Subway.Station){
        station.label?.alpha = 0.1
    }
    
    func show(station: Subway.Station){
        station.label?.alpha = 1.0
    }
    
    func putLocationMark(on station: Subway.Station){
        let locationMark = UIImage(named: "locationMark" + station.line)
        if locationMarkImageView == nil {
            locationMarkImageView = UIImageView(image: locationMark)
            locationMarkImageView?.contentMode = .scaleAspectFit
            self.addSubview(locationMarkImageView!)
            locationMarkImageView?.isHidden = false
        } else {
            locationMarkImageView?.image = locationMark
        }
        locationMarkImageView?.frame.origin = CGPoint(x: station.position.x - locationMarkImageView!.frame.width / 2.0, y: station.position.y - locationMarkImageView!.frame.height / 2.0)

    }
    
    func setLabels( stations: inout [Subway.Station]){
        var number = 0    
        for station in stations {
            let name = station.name
            let origin = station.position
            let layoutType: String =  station.labelLayoutType
            let label = UILabel()
            label.text = name
            label.font = UIFont(name: "Helvetica", size: 45.0)
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.sizeToFit()
            stations[number].label = label
            var x = origin.x
            var y = origin.y
            
            
            if layoutType.contains("centerY") {
                y -= label.frame.height / 2.0
            }
            
            if layoutType.contains("centerX") {
                x -= label.frame.width / 2.0
            }
            
            if layoutType.contains("specialCenterX") {
                x -= label.frame.width
            }
            
            if layoutType.contains("leftX") {
                x -= label.frame.width + stationPointRadius
            }
            
            if layoutType.contains("rightX") {
                x += stationPointRadius
            }
            
            if layoutType.contains("downY") {
                y += stationPointRadius
            }
            
            if layoutType.contains("upY") {
                y -= label.frame.height + stationPointRadius
            }
            
            if layoutType.contains("transferLeft") {
                x += 15
            }
            
            if layoutType.contains("specialTransferLeft") {
                x += 63.5
            }
            
            if layoutType.contains("transferRight") {
                x -= 15
            }
            
            if layoutType.contains("notTransparent") {
                label.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
            } else {
                label.backgroundColor = UIColor.clear
            }
           
            number += 1
            label.frame.origin = CGPoint(x: x, y: y)
            self.addSubview(label)
        }
        
    }
    
}
