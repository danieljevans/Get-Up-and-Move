//
//  PreviousViewController.swift
//  GetUpAndMove
//
//  Created by Daniel Evans on 2/20/19.
//  Copyright © 2019 Daniel Evans. All rights reserved.
//

import UIKit
import CoreData

class PreviousViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    var lat:Double?
    var long:Double?
    var photo:UIImage?
    var name:String?
    
    // handler to the managege object context
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //this is the array to store Fruit entities from the coredata
    var fetchResults = [RestaurantEntity]()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool)
    {
        tableView.reloadData()
    }
    
    
    
    // SEGUE OPERATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "mapSegue")
        {
            let selectedIndex: IndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
            
            let place = fetchResults[selectedIndex.row]
            
            if let viewController: MapViewController = segue.destination as? MapViewController
            {
                print("Map for \(place.name!)")
                viewController.name = place.name
                viewController.lat = place.lat
                viewController.long = place.lon
            }
        }
    }
    
    
    
    
    
    
    
    // TABLE VIEW OPERATIONS
    
    // returns the number of entries
    func fetchRecord() -> Int
    {
        // Create a new fetch request using the CityEntity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RestaurantEntity")
        var x = 0

        // Execute the fetch request, and cast the results to an array of cityEntity objects
        fetchResults = ((try? managedObjectContext.fetch(fetchRequest)) as? [RestaurantEntity])!
        x = fetchResults.count

        return x
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows based on the coredata storage
        return fetchRecord()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPrototype2", for: indexPath) as! PreviousTableViewCell
        cell.layer.borderWidth = 1.0
        
        cell.nameLabel.text = fetchResults[indexPath.row].name
        // NSDATA to UIImage
        if let newPhoto = fetchResults[indexPath.row].photo
        {
            cell.photo.image =  UIImage(data: newPhoto  as Data)
        }
        else {
            print("Image is null")
            cell.photo.image = nil
        }

        return cell
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) -> CGFloat
    {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            // delete the selected object from the managedObjectContext
            managedObjectContext.delete(fetchResults[indexPath.row])
            // remove it from the fetch results array
            fetchResults.remove(at:indexPath.row)
            
            do
            {
                // save the updated managed object context
                try managedObjectContext.save()
            }
            catch
            {
                print("Unable to delete")
            }
            // reload the table after deleting the place
            tableView.reloadData()
        }
    }
}
