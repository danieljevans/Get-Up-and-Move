//
//  NavigationViewController.swift
//  GetUpAndMove
//
//  Created by Daniel Evans on 2/16/19.
//  Copyright © 2019 Daniel Evans. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class NavigationViewController: UIViewController, CLLocationManagerDelegate,UIImagePickerControllerDelegate,
UINavigationControllerDelegate
{
    let photoPicker = UIImagePickerController ()
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchResults = [RestaurantEntity]()
    
    @IBOutlet weak var cardinalLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var PictureButton: UIBarButtonItem!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    var northWestArrow = "↖"
    var northEastArrow = "↗"
    var southWestArrow = "↙"
    var southEastArrow = "↘"
    var directionName:String?
    
    let locationManager = CLLocationManager()
    var currentLat:Double?
    var currentLong:Double?
    
    var targetLat:Double?
    var targetLong:Double?
    var placeName:String?
    var targetPhoto:UIImage?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RestaurantEntity")
        fetchResults = ((try? managedObjectContext.fetch(fetchRequest)) as? [RestaurantEntity])!
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startUpdatingLocation()
            nameLabel.text = placeName
        }
    }

    
    // LOCATION MANAGER
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0]
   
        let currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        // get weather and display
        self.getWeather()
        
        
        currentLat = currentLocation.latitude
        currentLong = currentLocation.longitude
        let currentLatStr = NSString(format: "%.3f", currentLat!)
        let currentLongStr = NSString(format: "%.3f", currentLong!)
        let targetLatStr = NSString(format: "%.3f", targetLat!)
        let targetLongStr = NSString(format: "%.3f", targetLong!)
        
        targetLabel.text = "Go to \(targetLatStr), \(targetLongStr)"
        currentLabel.text = "You are at \(currentLatStr), \(currentLongStr)"
        
        // South East
        if currentLat! > targetLat! && currentLong! < targetLong!
        {
            directionLabel.text = southEastArrow
            cardinalLabel.text = "SE"
        }
        // South West
        else if currentLat! > targetLat! && currentLong! > targetLong!
        {
            directionLabel.text = southWestArrow
            cardinalLabel.text = "SW"
        }
        // North East
        else if currentLat! < targetLat! && currentLong! < targetLong!
        {
            directionLabel.text = northEastArrow
            cardinalLabel.text = "NE"
        }
        // North West
        else if currentLat! < targetLat! && currentLong! > targetLong!
        {
            directionLabel.text = northWestArrow
            cardinalLabel.text = "NW"
        }
        
    }
    
    
    
    
    // CORE DATA OPERATIONS
    // CAMERA OPERATIONS
    
    @IBAction func LaunchCamera(_ sender: UIBarButtonItem)
    {
        if segmentController.selectedSegmentIndex == 0
        {
            if UIImagePickerController.isSourceTypeAvailable(.camera)
            {
                DispatchQueue.global().sync
                    {
                        // create a new entity object
                        let newEntity = NSEntityDescription.entity(forEntityName: "RestaurantEntity", in: self.managedObjectContext)
                        //add to the manege object context
                        let newPlace = RestaurantEntity(entity: newEntity!, insertInto: self.managedObjectContext)
                        
                        newPlace.name = self.placeName
                        newPlace.photo = nil
                        newPlace.lat = self.targetLat!
                        newPlace.lon = self.targetLong!
                        
                        fetchResults.append(newPlace)
                }
                DispatchQueue.global().sync
                {
                    self.photoPicker.delegate = self
                    self.photoPicker.sourceType = .camera
                    self.photoPicker.cameraCaptureMode = .photo
                    self.photoPicker.modalPresentationStyle = .fullScreen
                    // display image selection view
                    self.present(self.photoPicker, animated: true, completion: nil)

                    // save the updated context
                    do {
                        try self.managedObjectContext.save()
                    } catch _ {
                    }
                }
                
            } else {
                print("No camera")
            }
        }
        else
        {
            DispatchQueue.global().sync
            {
                // create a new entity object
                let newEntity = NSEntityDescription.entity(forEntityName: "RestaurantEntity", in: self.managedObjectContext)
                //add to the manege object context
                let newPlace = RestaurantEntity(entity: newEntity!, insertInto: self.managedObjectContext)
                
                newPlace.name = self.placeName
                newPlace.photo = nil
                newPlace.lat = self.targetLat!
                newPlace.lon = self.targetLong!
                
                fetchResults.append(newPlace)
            }
            DispatchQueue.global().sync
            {
                // load image
                self.photoPicker.delegate = self
                self.photoPicker.sourceType = .photoLibrary
                // display image selection view
                self.present(self.photoPicker, animated: true, completion: nil)
                
                // save the updated context
                do {
                    try self.managedObjectContext.save()
                }
                catch _ {
                }
            }
        }
    }
    
    func imagePickerController(_ photoPicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        photoPicker.dismiss(animated: true, completion: nil)
        
        // fetch resultset has the recently added row without the image
        print(fetchResults.count)
        
        if let place = fetchResults.last, let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            place.photo = image.jpegData(compressionQuality: 0.75)! as NSData
            
            do {
                try managedObjectContext.save()
                print("image saved successfully")
            }
            catch {
                print("Error while saving the new image")
            }
        }
        else {
            print("Unable to save image")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    
    
    
    
    // WEATHER DATA
    
    func getWeather()
    {
        let urlAsString = "http://api.openweathermap.org/data/2.5/weather?lat=\(targetLat!)&lon=\(targetLong!)&APPID=a71708390d45040e48a3a5ecab96c55c"
        
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            if (err != nil) {
                print("JSON Error \(err!.localizedDescription)")
            }
            
            let main = jsonResult["main"] as! [String:AnyObject]
            let temperature = main["temp"] as! AnyObject
            
            let tempK = Double(temperature as! NSNumber) as? Double
            
            // 47.642040, -122.358477
            
            // F = (298.11K − 273.15) × 9/5 + 32
            let temp = (tempK! - 273.15)*(9/5) + 32
            let str = NSString(format: "%.1f", temp)
            
            DispatchQueue.main.async {
                self.tempLabel.text = "\(str) °F"
            }
        })
        
        jsonQuery.resume()
    }
    
    
}






