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
    var adjacentStations: [[Int: Int]] = []
    init(){}
    
    init(city: String){
        stations = []
        let path = Bundle.main.path(forResource: city, ofType: "plist")!
        let stationsArray = NSArray(contentsOfFile: path)!
        var currentID = 0
        for station in stationsArray {
            if let station = station as? [String: Any]{
                let nameString = station["name"] as! String
                let name = NSLocalizedString(nameString, comment: nameString)
                let line = station["line"] as! String
                let origin = station["position"] as! [NSNumber]
                let labelLayoutType = station["labelLayoutType"] as! String
                let position = CGPoint(x: CGFloat(origin[0]), y: CGFloat(origin[1]))
                let geoPosition = station["geoPosition"] as! [NSNumber]
                let latitude = Double(geoPosition[0])
                let longitude = Double(geoPosition[1])
                stations.append(Station(name: name, ID: currentID, line: line, position: position, latitude: latitude, longitude: longitude, labelLayoutType: labelLayoutType))
                adjacentStations.append(Dictionary<Int, Int>())
                currentID += 1
            }
        }
        currentID = 0
        for station in stationsArray {
            if let station = station as? [String: Any]{
                let neighbors = station["neighbors"] as! [Any]
                for neighbor in neighbors {
                    let neighbor = neighbor as! [String: NSNumber]
                    let neighborID = neighbor["station"] as! Int
                    let neighborInterval = neighbor["interval"] as! Int
                    adjacentStations[currentID][neighborID] = neighborInterval
                    adjacentStations[neighborID][currentID] = neighborInterval
                }
            }
            currentID += 1
        }
      
    }
    
    func stationsByLine() -> [[Subway.Station]] {
        var stationsListByLine: [[Subway.Station]] = []
        
        var stationsAtParticularLine: [Subway.Station] = []
        var previousStationLine = ""
        
        for station in stations {
            if previousStationLine == "" {
                stationsAtParticularLine.append(station)
                previousStationLine = station.line
            } else {
                if (station.line == previousStationLine) {
                    stationsAtParticularLine.append(station)
                } else {
                    stationsListByLine.append(stationsAtParticularLine)
                    stationsAtParticularLine = [station]
                    previousStationLine = station.line
                }
            }
        }
        
        stationsListByLine.append(stationsAtParticularLine)
        
        return stationsListByLine
    }
    
    func calculatePath(from sourceID: Int, to destinationID: Int) -> ([Subway.Station], Int, Int, [(Int, Int, String)]?) {
        var usedStations = Array(repeating: false, count: stations.count)
        var distances = Array(repeating: Int.max, count: stations.count)
        var parent = Array(repeating: -1, count: stations.count)
        distances[sourceID] = 0
        var stationIndex = 0
        var stationsNodes: [Node<Int, Int>] = []
        for distance in distances {
            let newNode = Node<Int, Int>(key: stationIndex, value: distance)
            stationIndex += 1
            stationsNodes.append(newNode)
        }
        let stationsHeap = BinaryHeap(with: stationsNodes)
        while (stationsHeap.size > 0) {
            let currentStation = stationsHeap.getMin()
            let currentID = currentStation.key
            let currentDistance = currentStation.value
            usedStations[currentID] = true
            for (stationID, distance) in adjacentStations[currentID] {
                if !usedStations[stationID]  && (distances[stationID] > currentDistance + distance) {
                    let newDistance = currentDistance + distance
                    distances[stationID] = newDistance
                    stationsHeap.updateValue(for: stationID, with: newDistance)
                    parent[stationID] = currentID
                }
            }
        }
        
        var currentID = destinationID
        var path: [Subway.Station] = []
        var time = 0
        var numberOfTransfers = 0
        var lineTransferInformation: [(Int, Int, String)]? = nil
        while currentID != -1 {
            path.append(stations[currentID])
            if (parent[currentID] != -1) {
                time += adjacentStations[currentID][parent[currentID]]!
                if stations[parent[currentID]].line != stations[currentID].line
                {
                    numberOfTransfers += 1
                    if (lineTransferInformation == nil){
                        lineTransferInformation = [(parent[currentID], currentID, stations[parent[currentID]].line + "-" + stations[currentID].line)]
                    } else {
                        lineTransferInformation?.append((parent[currentID], currentID, stations[parent[currentID]].line + "-" + stations[currentID].line))
                    }
                }
            }
            currentID = parent[currentID]
        }
        path = path.reversed()
        for index in 0..<(path.count) {
            var typeString = path[index].line
            switch index {
                case 0:
                    typeString += "Source"
                    if (path[index].line != path[index + 1].line) {
                        typeString += "Transfer"
                    }
                case path.count - 1:
                    typeString += "Destination"
                    if (path[index].line != path[index - 1].line) {
                        typeString += "Transfer"
                    }
                case let index where (path[index].line != path[index + 1].line):
                    typeString += "FirstInTransfer"
                case let index where (path[index].line != path[index - 1].line):
                    typeString += "SecondInTransfer"
                default:
                    typeString += "Default"
            }
            path[index].typeInPath = typeString
        }
        return (path, time, numberOfTransfers, lineTransferInformation)
    }
    
    
    struct Station {
        let name: String
        let ID: Int
        let line: String
        var label: UILabel?
        let position: CGPoint
        var typeInPath: String?
        let latitude: Double
        let longitude: Double
        let labelLayoutType: String
                
        init(name: String, ID: Int, line: String, position: CGPoint, latitude: Double, longitude: Double, labelLayoutType: String) {
            self.name = name
            self.ID = ID
            self.line = line
            self.position = position
            self.latitude = latitude
            self.longitude = longitude
            self.labelLayoutType = labelLayoutType
        }
        
        func lineMark() -> UIImage {
            let imageName = line + "LinePoint"
            return UIImage(named: imageName)!
        }
    }
}
