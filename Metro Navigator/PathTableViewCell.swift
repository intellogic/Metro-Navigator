//
//  PathTableViewCell.swift
//  Metro Navigator
//
//  Created by Illia Lysenko on 5/9/17.
//  Copyright © 2017 intellogic. All rights reserved.
//

import UIKit

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
