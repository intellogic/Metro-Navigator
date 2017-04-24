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

    var mapView = SubwayMapView(city: "Kyiv-5_mod")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        

        scrollView.contentSize = mapView.frame.size
        scrollView.addSubview(mapView)
    
        updateMinZoomScaleForSize(size: view.bounds.size)
        
        var tapLabelRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.usersTap(tapRecognizer:)))
        tapLabelRecognizer.numberOfTapsRequired = 1
        tapLabelRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapLabelRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setImageViewAtTheCenterOfScrollView()
    }
    
    func usersTap(tapRecognizer: UITapGestureRecognizer){
        print("TAAAAP")
        print(tapRecognizer.location(in: self.mapView))
    }
    
    func usersTapOnLabel(recongizer: UITapGestureRecognizer){
        print("YYYYYY")
        if let label = recongizer.view as? UILabel{
            label.backgroundColor = UIColor.black
            label.textColor = UIColor.white
        }
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

