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
        station.label?.backgroundColor = UIColor.gray
    }
    
    func deactivate(_ station: Subway.Station){
        station.label?.textColor = UIColor.black
        station.label?.backgroundColor = UIColor.clear
    }
    
    func setLabels( stations: inout [Subway.Station]){
        var number = 0
        for station in stations {
            let name = station.name
            let origin = station.position
            var label = UILabel()
            label.text = name
            label.font = UIFont(name: "Helvetica", size: 45.0)
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.sizeToFit()
            stations[number].label = label
            var x = origin.x
            var y = origin.y
            switch number {
                case 0...6:
                    x -= label.frame.size.width + stationPointRadius
                    y -= label.frame.size.height / 2
                    label.backgroundColor = UIColor.clear
                case 7, 8, 11, 16:
                    x += stationPointRadius + 5
                    y -= label.frame.size.height / 2
                    label.backgroundColor = UIColor.clear
                case 9:
                    x -= label.frame.size.width + stationPointRadius
                    y -= label.frame.size.height / 2 + 5
                    label.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
                case 10:
                    x += stationPointRadius + 15
                    y -= label.frame.size.height / 2 + 5
                    label.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
                case 12:
                    x += stationPointRadius + 5
                    y -= label.frame.size.height / 2 + 5
                    label.backgroundColor = UIColor.clear
                case 13:
                    y += stationPointRadius
                    label.backgroundColor = UIColor.clear
                case 14...17:
                    x += stationPointRadius
                    y -= label.frame.size.height / 2
                    label.backgroundColor = UIColor.clear
                case 18...21:
                    x -= label.frame.size.width + stationPointRadius
                    y -= label.frame.size.height / 2
                    label.backgroundColor = UIColor.clear
                case 22...33:
                    x += stationPointRadius
                    y -= label.frame.size.height / 2
                    label.backgroundColor = UIColor.clear
                case 34...40:
                    x += stationPointRadius
                    y -= label.frame.size.height / 2
                    label.backgroundColor = UIColor.clear
                case 41:
                    x += stationPointRadius + 15 + 49
                    y -= label.frame.size.height / 2
                    label.backgroundColor = UIColor.clear
                case 42:
                    x -= label.frame.size.width + stationPointRadius + 15
                    y -= label.frame.size.height / 2
                    label.backgroundColor = UIColor.clear
                case 50:
                    x -= label.frame.size.width - stationPointRadius
                    y += stationPointRadius
                    label.backgroundColor = UIColor.clear
                case 51:
                    x -= label.frame.size.width + stationPointRadius
                    y += stationPointRadius
                    label.backgroundColor = UIColor.clear
                case 43...49:
                    x -= label.frame.size.width + stationPointRadius
                    y -= label.frame.size.height / 2
                    label.backgroundColor = UIColor.clear
                default:
                    break
            }
            number += 1
            label.frame.origin = CGPoint(x: x, y: y)
            self.addSubview(label)
        }
        
    }
    
}
