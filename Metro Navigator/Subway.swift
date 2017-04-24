//
//  Subway.swift
//  Metro Navigator
//
//  Created by Illia Lysenko on 4/24/17.
//  Copyright © 2017 intellogic. All rights reserved.
//

import Foundation
import UIKit

class Subway {
    
    var stations: [Subway.Station] = []
    
    init(){}
    
    init(city: String){
        stations = []
        let path = Bundle.main.path(forResource: city, ofType: "plist")!
        let stationsArray = NSArray(contentsOfFile: path)!
        for station in stationsArray {
            if let station = station as? [String: Any]{
                let name = station["name"] as! String
                let line = station["line"] as! String
                let origin = station["position"] as! [NSNumber]
                let position = CGPoint(x: CGFloat(origin[0]), y: CGFloat(origin[1]))
                stations.append(Station(name: name, line: line, position: position))
            }
        }

    }
    
    struct Station {
        let name: String
        let line: String
        var label: UILabel?
        let position: CGPoint
                
        init(name: String, line: String, position: CGPoint) {
            self.name = name
            self.line = line
            self.position = position
        }
    }
}
