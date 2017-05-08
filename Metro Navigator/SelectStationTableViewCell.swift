//
//  SelectStationTableViewCell.swift
//  Metro Navigator
//
//  Created by Illia Lysenko on 5/7/17.
//  Copyright © 2017 intellogic. All rights reserved.
//

import UIKit

class SelectStationTableViewCell: UITableViewCell {

    @IBOutlet weak var linePoint: UIImageView!
    @IBOutlet weak var stationLabel: UILabel!
    
    var station: Subway.Station? {
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        linePoint.image = station!.lineMark()
        stationLabel.text = station!.name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
