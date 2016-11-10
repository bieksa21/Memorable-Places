//
//  PlacesViewController.swift
//  Memorable Places
//
//  Created by joey frenette on 2016-11-09.
//  Copyright © 2016 joey frenette. All rights reserved.
//

import UIKit

// Model consists of an array of dictionaries
var places = [[String:String]()]
//index of currently active place (-1 means no places, or currently in places view)
var activePlace = -1

class PlacesViewController: UITableViewController {

    @IBOutlet var table: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let tempPlaces = UserDefaults.standard.object(forKey: "places") as? [[String : String]] {
            places = tempPlaces
        }
        
        //one element in array, but no locations inside (empty dictionary)
        if places.count == 1 && places[0].count == 0 {
            places.remove(at: 0)
            places.append(["name" : "White House",
                           "lat": "38.8976763",
                           "lon" : "-77.0387185"])
            //update places model
            UserDefaults.standard.set(places, forKey: "places")
        }
        
        activePlace = -1
        table.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if places[indexPath.row]["name"] != nil {
            cell.textLabel?.text = places[indexPath.row]["name"]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activePlace = indexPath.row
        
        performSegue(withIdentifier: "toMap", sender: nil)
    }
    
    
    
    //allows table rows to be editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //allows for deletion of table rows
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            places.remove(at: indexPath.row)
            //update places model
            UserDefaults.standard.set(places, forKey: "places")
            
            table.reloadData()
        }
    }
}
