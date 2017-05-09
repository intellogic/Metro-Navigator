//
//  ViewController.swift
//  Metro Navigator
//
//  Created by Illia Lysenko on 4/17/17.
//  Copyright © 2017 intellogic. All rights reserved.
//

import UIKit
import CoreLocation


class MainViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate {
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
    @IBOutlet weak var pathTableView: UITableView!
    @IBOutlet weak var getLocationButton: UIButton!
    
    var beginPoint = CGPoint.zero
    
    var mapView = SubwayMapView()
    var subway = Subway()
    
    var locationManager: CLLocationManager!
    
    var path: [Subway.Station]?
    
    var pathControlViewFrameOrigin: CGPoint {
        get {
            return CGPoint(x: 0, y: view.frame.height - pathControlView.frame.height)
        }
    }
    
    var pathControlViewIsInTranformationProcess = false
    var pathControlViewIsTransformed = false {
        didSet {
            if (!pathControlViewIsTransformed){
                movePathControlViewToOrigin()
            }
        }
    }
    
    var source: Subway.Station? {
        didSet {
            
            pathControlViewIsTransformed = false
            
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
            
            pathControlViewIsTransformed = false
            
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
        subway = Subway(city: User.city)
        mapView = SubwayMapView(city: User.city)
        mapView.setLabels(stations: &subway.stations)
        
        scrollView.delegate = self
        scrollView.contentSize = mapView.frame.size
        scrollView.addSubview(mapView)
        scrollView.maximumZoomScale = 0.4
    
        updateMinZoomScaleForSize(size: view.bounds.size)
        
        let tapLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        tapLabelRecognizer.numberOfTapsRequired = 1
        tapLabelRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapLabelRecognizer)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    
        pathTableView.delegate = self
        pathTableView.dataSource = self
        
        sourceListOrCancelButton.imageView?.contentMode = .scaleAspectFit
        destinationListOrCancelButton.imageView?.contentMode = .scaleAspectFit
        
        pathControlView.frame.origin = pathControlViewFrameOrigin

        pathInfoView.isHidden = true
        
        swapButton.alpha = 0.5
        
        pathControlView.gestureRecognizers = []
        
        getLocationButton.isEnabled = true
        
        if (CLLocationManager.authorizationStatus() != .denied && CLLocationManager.authorizationStatus() !=  .restricted) {
            if (CLLocationManager.locationServicesEnabled()) {
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                locationManager.requestWhenInUseAuthorization()
            } else {
                getLocationButton.isEnabled = false
            }
        } else {
            getLocationButton.isEnabled = false
            
        }
   
        
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first {
            var minDistance = currentLocation.distance(from: CLLocation(latitude: subway.stations[0].latitude, longitude: subway.stations[0].longitude))
            var minDistanceStationID = 0
            for station in subway.stations {
                let distance = currentLocation.distance(from: CLLocation(latitude: station.latitude, longitude: station.longitude))
                if (distance < minDistance){
                    minDistance = distance
                    minDistanceStationID = station.ID
                }
            }
            
            mapView.putLocationMark(on: subway.stations[minDistanceStationID])
            
            //if (source != nil) {
              //  deactivateSourceStation()
            //}
            //source = subway.stations[minDistanceStationID]
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }
    
    @IBAction func getLocation(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
   
    
    func handlePan(panRecognizer: UIPanGestureRecognizer){
        let location = panRecognizer.location(in: view)
        switch panRecognizer.state {
            case .began:
                beginPoint = panRecognizer.location(in: view)
                pathControlViewIsInTranformationProcess = true
            case .changed:
                let newPanPoint = panRecognizer.location(in: view)
                pathControlView.frame.origin.y -= beginPoint.y - newPanPoint.y
                beginPoint = newPanPoint
                pathControlViewIsInTranformationProcess = true
                updatePathTableViewFrame()
            case .ended:
                if ((location.y > view.frame.height * 0.8 && !pathControlViewIsTransformed) || (location.y > view.frame.height * 0.2 && pathControlViewIsTransformed)) {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.pathControlView.frame.origin = self.pathControlViewFrameOrigin
                        self.updatePathTableViewFrame()
                    }, completion: { (completed) in
                        self.swipeArrowImageView.image = UIImage(named: "SwipeUpArrow")
                        self.pathControlViewIsInTranformationProcess = false
                        self.pathControlViewIsTransformed = false
                    })
                } else {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.pathControlView.frame.origin = CGPoint(x: 0, y: UIApplication.shared.statusBarFrame.maxY)
                        self.updatePathTableViewFrame()
                    }, completion: { (completed) in
                        self.swipeArrowImageView.image = UIImage(named: "SwipeDownArrow")
                        self.pathControlViewIsTransformed = true
                    })
                }
            default: break
        }
    }
    
    private func deactivateStationsBetweenSourceAndDestination(){
        if let path = path {
            for station in path {
                if station.ID != source?.ID && station.ID != destination?.ID {
                    mapView.deactivate(station)
                }
            }
        }
    }
    
    private func movePathControlViewToOrigin(){
        pathControlView.frame.origin = pathControlViewFrameOrigin
    }
    
    func updatePathTableViewFrame(){
        pathTableView.frame = CGRect(origin: CGPoint(x: 0, y: pathControlView.frame.maxY),  size: CGSize(width: view.frame.width, height: view.frame.height - pathControlView.frame.height - UIApplication.shared.statusBarFrame.height))

    }
    
    private func findPath(){
        if let source = source, let destination = destination, source.ID != destination.ID {
            let (newPath, time, _, _) = subway.calculatePath(from: source.ID, to: destination.ID)
            UIView.animate(withDuration: 0.5, animations: {
                self.updateMinZoomScaleForSize(size: self.view.frame.size)
            })
            path = newPath
            pathControlViewIsTransformed = false
            hideStationsOutsidePath()
            setPathAndArrivalTime(for: time)
            pathInfoView.isHidden = false
            pathTableView.isHidden = false
            pathTableView.reloadData()
            pathControlView.isUserInteractionEnabled = true
            self.swipeArrowImageView.image = UIImage(named: "SwipeUpArrow")
            let swipeUpGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(panRecognizer:)))
            swipeUpGestureRecognizer.minimumNumberOfTouches = 1
            pathControlView.addGestureRecognizer(swipeUpGestureRecognizer)
        }
    }
    
    private func setPathAndArrivalTime(for time: Int){
        let timeInMinutes = time / 60
        pathTimeLabel.text = String(timeInMinutes) + " " + NSLocalizedString("minutes", comment: "minutes")
        var date = Date()
        date.addTimeInterval(TimeInterval(time))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        arrivalTimeLabel.text = NSLocalizedString("Arrival at", comment: "Arrival at") + " " + dateFormatter.string(from: date)
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
        if (!pathControlViewIsInTranformationProcess || !pathControlViewIsTransformed) {
            pathControlView.frame.origin = pathControlViewFrameOrigin
        }
        updatePathTableViewFrame()
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
        let selectStationViewController = storyboard.instantiateViewController(withIdentifier: "SelectStationView") as! SelectStationTableViewController
        selectStationViewController.stations = subway.stationsByLine()
        selectStationViewController.forSource = forSource
        present(selectStationViewController, animated: true, completion: nil)

    }
    
    private func deactivateSourceStation(){
        sourceLinePoint.image = nil
        sourceLabel.text = NSLocalizedString("fromLabelPlaceholder", comment: "fromLabelPlaceholder")
        sourceListOrCancelButton.imageView?.image = UIImage(named: "list_icon")
        if let source = source {
            mapView.deactivate(source)
        }
    }
    
    private func activateSourceStation(){
        if let source = source {
            sourceLinePoint.image = source.lineMark()
            sourceLabel.text = source.name
            sourceListOrCancelButton.imageView?.image = UIImage(named: "cancel")
            mapView.activate(source)
        }
    }
    
    private func deactivateDestinationStation(){
        destinationLinePoint.image = nil
        destinationLabel.text = NSLocalizedString("toLabelPaceholder", comment: "toLabelPaceholder")
        destinationListOrCancelButton.imageView?.image = UIImage(named: "list_icon")
    }
    
    private func activateDestinationStation(){
        if let destination = destination {
            destinationLinePoint.image = destination.lineMark()
            destinationLabel.text = destination.name
            destinationListOrCancelButton.imageView?.image = UIImage(named: "cancel")
            mapView.activate(destination)
        }
    }
    
    private func hideStationsOutsidePath(){
        if let path = path {
            for station in subway.stations {
                if !path.contains(where: {
                    $0.ID == station.ID
                }) {
                    mapView.hide(station: station)
                }
            }
        }
    }
    
    private func showStationsOutsidePath(){
        if let path = path {
            for station in subway.stations {
                if !path.contains(where: {
                    $0.ID == station.ID
                }) {
                    mapView.show(station: station)
                }
            }
        }
    }
    
    
    func handleSingleTap(recognizer: UITapGestureRecognizer){
        guard (source == nil || destination == nil) else {
            return
        }
        let tapLocation = recognizer.location(in: self.mapView)
        if let currentStation = checkIfSomeStationIsChosen(for: tapLocation) {
            if let source = source{
                guard (currentStation.ID != source.ID) else {
                    return
                }
            }
            if let destination = destination{
                guard (currentStation.ID != destination.ID) else {
                    return
                }
            }

            if (source == nil){
                source = currentStation
            } else if (destination == nil){
                destination = currentStation
            }
        }
        
    }

    
    private func checkIfSomeStationIsChosen(for tapLocation: CGPoint) -> Subway.Station? {
        if CGRect(origin: CGPoint.zero, size: mapView.image!.size).contains(tapLocation){
            var maxDistance = CGFloat.greatestFiniteMagnitude
            var closestStation = subway.stations.first!
            for station in subway.stations {
                if station.label!.frame.contains(tapLocation){
                    return station
                }
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

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.path?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pathTableCell = self.pathTableView.dequeueReusableCell(withIdentifier: "pathTableViewCell", for: indexPath) as! PathTableViewCell
        pathTableCell.station = self.path![indexPath.row]
        return pathTableCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

class PathTableViewCell: UITableViewCell {
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var stationInPathImageView: UIImageView!
    
    var station: Subway.Station? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI(){
        stationNameLabel.text = station?.name
        if station!.typeInPath!.contains("Source") || station!.typeInPath!.contains("Destination") || station!.typeInPath!.contains("Transfer") {
            stationNameLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        } else {
            stationNameLabel.font = UIFont.systemFont(ofSize: 17)
        }
        let imageName =  station!.typeInPath!
        let stationImage = UIImage(named: "Path Icons/" + imageName)!
        stationInPathImageView.image = stationImage
        imageView?.frame.size = stationImage.size
        selectionStyle = .none
    }
}


extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return (dx * dx + dy * dy).squareRoot()
    }
}
