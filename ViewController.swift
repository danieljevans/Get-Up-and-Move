//
//  ViewController.swift
//  GetUpAndMove
//
//  Created by Daniel Evans on 2/16/19.
//  Copyright © 2019 Daniel Evans. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate
{
    // api: AIzaSyAiZ3phLPH1TPezzMDu488BeVyb6wwBsOs
    var restaurants:RestaurantList = RestaurantList()
    
    @IBOutlet weak var tableView: UITableView!
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView?
    var location:CLLocation?
    var currentLat:Double?
    var currentLong:Double?
    
    var locationManager:CLLocationManager!
    
    // LOAD THE VIEW
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    
    
    
    
    
    // LOCATION AND SEARCH OPERATIONS
    
    func localSearch()
    {
        // 33.424733,-111.936128
        let urlAsString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(self.currentLat!),\(self.currentLong!)&radius=1000&type=restaurant&keyword=lunch&key=AIzaSyAiZ3phLPH1TPezzMDu488BeVyb6wwBsOs"
        print(urlAsString)
        
        
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            if (err != nil)
            {
                print("JSON Error \(err!.localizedDescription)")
            }
            
            
            let results = jsonResult["results"] as! NSArray
            let numPlaces = results.count
            
            for i in 0..<numPlaces
            {
                let place = results[i] as! [String:AnyObject]
                let newName = place["name"] as! String
                let newRating = place["rating"] as! Double
                
                let geometry = place["geometry"] as! [String:AnyObject]
                let location = geometry["location"] as! [String:AnyObject]
                let newLat = location["lat"] as! Double
                let newLong = location["lng"] as! Double
                
                let newPlace = DisplayRestaurant(newName, newRating, newLat, newLong)
                self.restaurants.restaurantList.append(newPlace)
                print("Added: \(self.restaurants.restaurantList[i].name!)")
                
                // update tableView in main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        
        jsonQuery.resume()
        // stop updating once tableView array is populated
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.location = locations[0]
        
        let currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
        
        currentLat = currentLocation.latitude
        currentLong = currentLocation.longitude
        print("\(currentLat!), \(currentLong!)")
    }
    
    

    
    // SEGUE OPERATIONS
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "navView")
        {
            let selectedIndex: IndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
            
            let place = restaurants.restaurantList[selectedIndex.row]
            
            if let viewController: NavigationViewController = segue.destination as? NavigationViewController
            {
                print("Navigating to \(place.name!)")
                viewController.placeName = place.name
                viewController.targetLat = place.lat
                viewController.targetLong = place.long
            }
        }
    }
    
    
    
    
    
    // TABLE VIEW OPERATIONS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // determines number of rows needed (number of restaurants)
        return restaurants.restaurantList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPrototype", for: indexPath) as! RestaurantTableViewCell
        cell.layer.borderWidth = 1.0
        
        // set tableViewCell with JSON call
        cell.nameLabel.text = restaurants.restaurantList[indexPath.row].name
        cell.ratingLabel.text = "\(restaurants.restaurantList[indexPath.row].rating!)"
        
        return cell
    }
    
    @IBAction func updateEntries(_ sender: Any)
    {
        // remove old entries
        self.restaurants.restaurantList.removeAll()
        
        DispatchQueue.global().sync {
            // update for a new location
            self.locationManager.startUpdatingLocation()
        }
        DispatchQueue.global().sync {
            // call local search
            self.localSearch()
        }
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) -> CGFloat
    {
        return 70
    }
}
