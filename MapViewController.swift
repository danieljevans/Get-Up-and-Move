//
//  PreviousViewController.swift
//  GetUpAndMove
//
//  Created by Daniel Evans on 2/20/19.
//  Copyright © 2019 Daniel Evans. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    var lat:Double?
    var long:Double?
    var name:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 33.422594, -111.939701
        let camera = GMSCameraPosition.camera(withLatitude: lat ?? 0, longitude: long ?? 0, zoom: 18.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat ?? 0, longitude: long ?? 0)
        marker.title = self.name
        marker.map = mapView
        
        mapView.selectedMarker = marker
    }
}
