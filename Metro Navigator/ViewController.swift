//
//  ViewController.swift
//  Metro Navigator
//
//  Created by Illia Lysenko on 4/17/17.
//  Copyright © 2017 intellogic. All rights reserved.
//

import UIKit



class ViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var sourceLinePoint: UIImageView!
    @IBOutlet weak var swapButton: UIButton!
    @IBOutlet weak var destinationLinePoint: UIImageView!
    @IBOutlet weak var destinationLabel: UILabel!
    
    var mapView = SubwayMapView()
    var subway = Subway()
    
    var sourceIsChosen = false
    var destinationIsChosen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subway = Subway(city: "Kiev")
        mapView = SubwayMapView(city: "Kiev")
        mapView.setLabels(stations: &subway.stations)
        
        scrollView.delegate = self
        scrollView.contentSize = mapView.frame.size
        scrollView.addSubview(mapView)
    
        updateMinZoomScaleForSize(size: view.bounds.size)
        
        var tapLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.usersTap(tapRecognizer:)))
        tapLabelRecognizer.numberOfTapsRequired = 1
        tapLabelRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapLabelRecognizer)
        
        swapButton.alpha = 0.5
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setImageViewAtTheCenterOfScrollView()
    }
    
    func usersTap(tapRecognizer: UITapGestureRecognizer){
        guard (sourceIsChosen != true || destinationIsChosen != true) else {
            return
        }
        let tapLocation = tapRecognizer.location(in: self.mapView)
        if let currentStation = checkIfSomeStationIsChosen(for: tapLocation){
            var currentLinePoint = UIImageView()
            var currentStationLabel = UILabel()
            if (!sourceIsChosen){
                currentLinePoint = sourceLinePoint
                currentStationLabel = sourceLabel
                sourceIsChosen = true
            } else {
                currentLinePoint = destinationLinePoint
                currentStationLabel = destinationLabel
                destinationIsChosen = true
            }
            currentLinePoint.image = UIImage.point(for: currentStation.line)
            currentStationLabel.text = currentStation.name
        }
        
    }

    
    private func checkIfSomeStationIsChosen(for tapLocation: CGPoint) -> Subway.Station? {
        if CGRect(origin: CGPoint.zero, size: mapView.image!.size).contains(tapLocation){
            var index = 0
            for view in mapView.subviews {
                if view.frame.contains(tapLocation), let view = view as? UILabel {
                    mapView.activateStation(at: subway.stations[index].position, on: view)
                    return subway.stations[index]
                }
                index += 1
            }
            var maxDistance = CGFloat.greatestFiniteMagnitude
            var closestStation = subway.stations.first!
            for station in subway.stations {
                let currentDistance = tapLocation.distance(to: station.position)
                if currentDistance < mapView.stationPointRadius * 1.5 {
                    mapView.activateStation(at: station.position, on: station.label!)
                    return station
                }
                if currentDistance < maxDistance {
                    maxDistance = currentDistance
                    closestStation = station
                }
            }
            if maxDistance < mapView.stationPointRadius * 3 {
                mapView.activateStation(at: closestStation.position, on: closestStation.label!)
                return closestStation
            }
        }
        
        return nil
    }
    
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / mapView.bounds.width
        let heightScale = size.height / mapView.bounds.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mapView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setImageViewAtTheCenterOfScrollView()
    }
    
    func setImageViewAtTheCenterOfScrollView(){
        if mapView.frame.height <= scrollView.frame.height {
            let shiftHeight = scrollView.frame.height/2.0 - scrollView.contentSize.height/2.0
            scrollView.contentInset.top = shiftHeight
        }
        if mapView.frame.width <= scrollView.frame.width {
            let shiftWidth = scrollView.frame.width/2.0 - scrollView.contentSize.width/2.0
            scrollView.contentInset.left = shiftWidth
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return (dx * dx + dy * dy).squareRoot()
    }
}

extension UIImage {
    static func point(for line: String) -> UIImage {
        switch line {
        case "Red":
            return UIImage(named: "red_line_point")!
        case "Green":
            return UIImage(named: "green_line_point")!
        case "Blue":
            return UIImage(named: "blue_line_point")!
        default:
            return UIImage()
        }
    }
}

