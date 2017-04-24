//
//  Subway.swift
//  Metro Navigator
//
//  Created by Illia Lysenko on 4/24/17.
//  Copyright © 2017 intellogic. All rights reserved.
//

import Foundation

class Subway {
    
    let stations: [Subway.Station]
    
    init(){
        stations = []
    }
    
    class Station {
        var name: String
        var line: String
        
        
        init(name: String, line: String) {
            self.name = name
            self.line = line
        }
    }
}
