//
//  SelectStationViewController.swift
//  Metro Navigator
//
//  Created by Illia Lysenko on 4/26/17.
//  Copyright © 2017 intellogic. All rights reserved.
//

import UIKit

class SelectStationTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var stations: [[Subway.Station]]?
    var filteredStations: [[Subway.Station]]?
    var forSource = true
    let indices = ["1", "2", "3"]
    let linesNames = ["Святошинсько-Броварська", "Сирецько-Печерська", "Куренівсько-Червоноармійська"]
    
    @IBOutlet weak var stationsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stationsTableView.delegate = self
        stationsTableView.dataSource = self
        stationsTableView.keyboardDismissMode = .onDrag
        searchBar.delegate = self
        filteredStations = stations
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText != "") {
            //filteredStations = [[]]
            filterStations(for: searchText)
        } else {
            filteredStations = stations
        }
        stationsTableView.reloadData()
    }

    func filterStations(for searchText: String) {
        for lineIndex in 0...(stations!.count - 1) {
            filteredStations![lineIndex] =  stations![lineIndex].filter({ (station) -> Bool in
                station.name.lowercased().contains(searchText.lowercased())
            })
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stationTableCell = stationsTableView.dequeueReusableCell(withIdentifier: "stationTableViewCell", for: indexPath) as! SelectStationTableViewCell
        stationTableCell.station = filteredStations![indexPath.section][indexPath.row]
        return stationTableCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStations![section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        let homeViewController = presentingViewController as! MainViewController
        if forSource {
            homeViewController.source = filteredStations![indexPath.section][indexPath.row]
        } else {
            homeViewController.destination = filteredStations![indexPath.section][indexPath.row]

        }
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredStations!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filteredStations![section].count > 0 {
            let lineName = User.city + "SubwayLine" + String(section + 1);
            return NSLocalizedString(lineName, comment: lineName)
        } else {
            return nil
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indices
    }
    
    @IBAction func cancelSelection(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

