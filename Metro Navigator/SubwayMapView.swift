//
//  SubwayMapView.swift
//  Metro Navigator
//
//  Created by Illia Lysenko on 4/21/17.
//  Copyright © 2017 intellogic. All rights reserved.
//

import UIKit

class SubwayMapView: UIImageView {

    var stations: [Subway.Station]
    
    let stationPointSize: CGFloat = 30.05
    
    var label = UILabel()
    
    override init(frame: CGRect) {
        stations = []
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        stations = []
        super.init(coder: aDecoder)
    }
    
    convenience init(city: String){
        let image = UIImage(named: city)!
        self.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: image.size))
        self.image = image
        setLabels()
    }
    
    func usersTapOnLabel(gesture: UITapGestureRecognizer){
        print(gesture.view)
    }
    
    func setLabels(){
        let path = Bundle.main.path(forResource: "Kiev", ofType: "plist")!
        let stations = NSArray(contentsOfFile: path)!
        var number = 0
        for station in stations {
            if let station = station as? [String: Any]{
                let name = station["name"] as! String
                let origin = station["position"] as! [NSNumber]
                let label = UILabel()
                label.text = name
                label.font = UIFont(name: "Helvetica", size: 45.0)
                label.sizeToFit()
                var x = CGFloat(origin[0])
                var y = CGFloat(origin[1])
                label.backgroundColor =  UIColor.green

                switch number {
                    case 0...6:
                        x -= label.frame.size.width + stationPointSize
                        y -= label.frame.size.height / 2
                        label.backgroundColor = UIColor.clear
                    case 7, 8, 11, 16:
                        x += stationPointSize + 5
                        y -= label.frame.size.height / 2
                        label.backgroundColor = UIColor.clear
                    case 9:
                        x -= label.frame.size.width + stationPointSize
                        y -= label.frame.size.height / 2 + 5
                        label.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
                    case 10:
                        x += stationPointSize + 15
                        y -= label.frame.size.height / 2 + 5
                        label.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
                    case 12:
                        x += stationPointSize + 5
                        y -= label.frame.size.height / 2 + 5
                        label.backgroundColor = UIColor.clear
                    case 13:
                        y += stationPointSize
                        label.backgroundColor = UIColor.clear
                    case 14...17:
                        x += stationPointSize
                        y -= label.frame.size.height / 2
                        label.backgroundColor = UIColor.clear
                    case 18...21:
                        x -= label.frame.size.width + stationPointSize
                        y -= label.frame.size.height / 2
                        label.backgroundColor = UIColor.clear
                    case 22...33:
                        x += stationPointSize
                        y -= label.frame.size.height / 2
                        label.backgroundColor = UIColor.clear
                    case 34...40:
                        x += stationPointSize
                        y -= label.frame.size.height / 2
                        label.backgroundColor = UIColor.clear
                    case 41:
                        x += stationPointSize + 15 + 49
                        y -= label.frame.size.height / 2
                        label.backgroundColor = UIColor.clear
                    case 42:
                        x -= label.frame.size.width + stationPointSize + 15
                        y -= label.frame.size.height / 2
                        label.backgroundColor = UIColor.clear
                    case 50:
                        x -= label.frame.size.width - stationPointSize
                        y += stationPointSize
                        label.backgroundColor = UIColor.clear
                    case 51:
                        x -= label.frame.size.width + stationPointSize
                        y += stationPointSize
                        label.backgroundColor = UIColor.clear
                    case 43...49:
                        x -= label.frame.size.width + stationPointSize
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
    
}
