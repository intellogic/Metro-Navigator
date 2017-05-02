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
    @IBOutlet weak var sourceListOrCancelButton: UIButton!
    @IBOutlet weak var destinationListOrCancelButton: UIButton!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var pathControlView: UIStackView!
    @IBOutlet weak var pathInfoView: UIView!
    @IBOutlet weak var pathTimeLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var swipeArrowImageView: UIImageView!
    var mapView = SubwayMapView()
    var subway = Subway()
    
    var newView: UIView?
    
    var sourceIsChosen = false
    var destinationIsChosen = false
    
    var path: [Int]?
    
    var pathControlViewFrameOrigin: CGPoint?
    
    var detailedPathInfoIsVisible = false
    
    var source: Subway.Station? {
        didSet {
            
            pathInfoView.isHidden = true
            pathControlView.gestureRecognizers = []
            showStationsOutsidePath()
            
            if (source == nil && oldValue != nil) {
                deactivateSourceStation()
                mapView.deactivate(oldValue!)
            }
            if (source != nil){
                activateSourceStation()
                swapButton.alpha = 1.0
                if destination != nil {
                    findPath()
                }
            } else {
                if (destination == nil) {
                    swapButton.alpha = 0.5
                }
            }
        }
    }
    
    var destination: Subway.Station? {
        didSet {
            
            pathInfoView.isHidden = true
            pathControlView.gestureRecognizers = []
            showStationsOutsidePath()
            
            if (destination == nil && oldValue != nil) {
                deactivateDestinationStation()
                mapView.deactivate(oldValue!)
            }
            if (destination != nil) {
                activateDestinationStation()
                swapButton.alpha = 1.0
                if (source != nil) {
                    findPath()
                }
            } else {
                if (source == nil) {
                    swapButton.alpha = 0.5
                }
            }
        
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subway = Subway(city: "Kiev")
        mapView = SubwayMapView(city: "Kiev")
        mapView.setLabels(stations: &subway.stations)
        
        scrollView.delegate = self
        scrollView.contentSize = mapView.frame.size
        scrollView.addSubview(mapView)
    
        updateMinZoomScaleForSize(size: view.bounds.size)
        
        var tapLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(usersTap(tapRecognizer:)))
        tapLabelRecognizer.numberOfTapsRequired = 1
        tapLabelRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapLabelRecognizer)
    
        
        sourceListOrCancelButton.imageView?.contentMode = .scaleAspectFit
        destinationListOrCancelButton.imageView?.contentMode = .scaleAspectFit

        pathInfoView.isHidden = true
        
        swapButton.alpha = 0.5
        
        pathControlView.gestureRecognizers = []
    }
    
    
    var beginPoint = CGPoint.zero
    
    func swipe(swipeRecognizer: UIPanGestureRecognizer){
        let location = swipeRecognizer.location(in: view)
        switch swipeRecognizer.state {
            case .began:
                beginPoint = swipeRecognizer.location(in: view)
                print(beginPoint)
            case .changed:
                let newPanPoint = swipeRecognizer.location(in: view)
                print(newPanPoint)
                pathControlView.frame.origin.y -= beginPoint.y - newPanPoint.y
                beginPoint = newPanPoint
            case .ended:
                if ((location.y > view.frame.height * 0.8 && !detailedPathInfoIsVisible) || (location.y > view.frame.height * 0.2 && detailedPathInfoIsVisible)) {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.pathControlView.frame.origin = self.pathControlViewFrameOrigin!
                    }, completion: { (completed) in
                        self.swipeArrowImageView.image = UIImage(named: "SwipeUpArrow")
                        self.detailedPathInfoIsVisible = false
                    })
                } else {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.pathControlView.frame.origin = CGPoint(x: 0, y: UIApplication.shared.statusBarFrame.maxY)
                    }, completion: { (completed) in
                        self.swipeArrowImageView.image = UIImage(named: "SwipeDownArrow")
                        self.detailedPathInfoIsVisible = true
                    })
                }
            default: break
        }
    }
    
    private func deactivateStationsBetweenSourceAndDestination(){
        if let path = path {
            for index in path {
                if index != source?.ID && index != destination?.ID {
                    mapView.deactivate(subway.stations[index])
                }

                
            }
        }
    }
    
    private func findPath(){
        if let source = source, let destination = destination, source.ID != destination.ID {
            let (newPath, time, _, info) = subway.calculatePath(from: source.ID, to: destination.ID)
            path = newPath
            if let info = info {
                print(info)
            }
            hideStationsOutsidePath()
            setPathAndArrivalTime(for: time)
            pathInfoView.isHidden = false
            pathControlView.isUserInteractionEnabled = true
            pathControlViewFrameOrigin = pathControlView.frame.origin
            self.swipeArrowImageView.image = UIImage(named: "SwipeUpArrow")
            var swipeUpGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipe(swipeRecognizer:)))
            swipeUpGestureRecognizer.minimumNumberOfTouches = 1
            pathControlView.addGestureRecognizer(swipeUpGestureRecognizer)
        }
    }
    
    private func setPathAndArrivalTime(for time: Int){
        let timeInMinutes = time / 60
        pathTimeLabel.text = String(timeInMinutes) + " хв"
        var date = Date()
        print(date.description)
        date.addTimeInterval(TimeInterval(time))
        print(date.description)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        arrivalTimeLabel.text = "Прибуття о " + dateFormatter.string(from: date)
    }
    

    @IBAction func swapStations(_ sender: UIButton) {
        if (source != nil || destination != nil){
            let t = source
            source = destination
            destination = t
            if (destination == nil && source != nil){
                activateSourceStation()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setImageViewAtTheCenterOfScrollView()
        //controlView.frame = CGRect(origin: controlView.frame.origin, size: CGSize(width: view.frame.width, height: view.frame.height * 0.08))
        print("DID LAYOUT")
        pathControlViewFrameOrigin = pathControlView.frame.origin
    }
    
    @IBAction func cancelSourceChoice(_ sender: UIButton) {
        if (source != nil){
            source = nil
        } else {
            prepareForSelectingView(forSource: true)
        }

    }
    
    @IBAction func cancelDestinationChoice(_ sender: UIButton) {
        if (destination != nil){
            destination = nil
        } else {
            prepareForSelectingView(forSource: false)
        }
    }
    
    private func prepareForSelectingView(forSource: Bool){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectStationViewController = storyboard.instantiateViewController(withIdentifier: "SelectStationView") as! SelectStationViewController
        selectStationViewController.stations = subway.stationsByLine()
        selectStationViewController.forSource = forSource
        present(selectStationViewController, animated: true, completion: nil)

    }
    
    private func deactivateSourceStation(){
        sourceLinePoint.image = nil
        sourceLabel.text = "Звiдки"
        sourceListOrCancelButton.imageView?.image = UIImage(named: "list_icon")
    }
    
    private func activateSourceStation(){
        sourceLinePoint.image = UIImage.point(for: source!.line)
        sourceLabel.text = source!.name
        sourceListOrCancelButton.imageView?.image = UIImage(named: "cancel")
        mapView.activate(source!)
    }
    
    private func deactivateDestinationStation(){
        destinationLinePoint.image = nil
        destinationLabel.text = "Куди"
        destinationListOrCancelButton.imageView?.image = UIImage(named: "list_icon")
    }
    
    private func activateDestinationStation(){
        destinationLinePoint.image = UIImage.point(for: destination!.line)
        destinationLabel.text = destination!.name
        destinationListOrCancelButton.imageView?.image = UIImage(named: "cancel")
        mapView.activate(destination!)
    }
    
    private func hideStationsOutsidePath(){
        if let path = path {
            for station in subway.stations {
                if !path.contains(station.ID){
                    mapView.hide(station: station)
                }
            }
        }
    }
    
    private func showStationsOutsidePath(){
        if let path = path {
            for station in subway.stations {
                if !path.contains(station.ID){
                    mapView.show(station: station)
                }
            }
        }
    }
    
    
    func usersTap(tapRecognizer: UITapGestureRecognizer){
        guard (sourceIsChosen != true || destinationIsChosen != true) else {
            return
        }
        let tapLocation = tapRecognizer.location(in: self.mapView)
        if let currentStation = checkIfSomeStationIsChosen(for: tapLocation){
            var currentLinePoint = UIImageView()
            var currentStationLabel = UILabel()
            if (source == nil){
                source = currentStation
            } else if (destination == nil){
                destination = currentStation
            }
        }
        
    }

    
    private func checkIfSomeStationIsChosen(for tapLocation: CGPoint) -> Subway.Station? {
        if CGRect(origin: CGPoint.zero, size: mapView.image!.size).contains(tapLocation){
            var index = 0
            for view in mapView.subviews {
                if view.frame.contains(tapLocation), let view = view as? UILabel {
                    return subway.stations[index]
                }
                index += 1
            }
            var maxDistance = CGFloat.greatestFiniteMagnitude
            var closestStation = subway.stations.first!
            for station in subway.stations {
                let currentDistance = tapLocation.distance(to: station.position)
                if currentDistance < mapView.stationPointRadius * 1.5 {
                    return station
                }
                if currentDistance < maxDistance {
                    maxDistance = currentDistance
                    closestStation = station
                }
            }
            if maxDistance < mapView.stationPointRadius * 3 {
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

