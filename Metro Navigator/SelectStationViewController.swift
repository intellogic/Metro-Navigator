//
//  SelectStationViewController.swift
//  Metro Navigator
//
//  Created by Illia Lysenko on 4/26/17.
//  Copyright © 2017 intellogic. All rights reserved.
//

import UIKit

class SelectStationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var stations: [[Subway.Station]]?
    var forSource = true
    let indices = ["1", "2", "3"]
    let linesNames = ["Святошинсько-Броварська", "Сирецько-Печерська", "Куренівсько-Червоноармійська"]
    
    @IBOutlet weak var stationsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stationsTableView.delegate = self
        stationsTableView.dataSource = self
        // Do any additional setup after loading the view.
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stationTableCell = stationsTableView.dequeueReusableCell(withIdentifier: "stationTableViewCell", for: indexPath) as! StationTableViewCell
        stationTableCell.station = stations![indexPath.section][indexPath.row]
        return stationTableCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations![section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let homeViewController = presentingViewController as! ViewController
        if forSource {
            homeViewController.source = stations![indexPath.section][indexPath.row]
        } else {
            homeViewController.destination = stations![indexPath.section][indexPath.row]

        }
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stations!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return linesNames[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indices
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelSelecting(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class StationTableViewCell : UITableViewCell {
    @IBOutlet weak var linePoint: UIImageView!
    @IBOutlet weak var stationLabel: UILabel!
    
    var station: Subway.Station? {
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        linePoint.image = UIImage.point(for: station!.line)
        stationLabel.text = station!.name
    }
}
