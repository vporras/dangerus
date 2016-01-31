//
//  Incident.swift
//  Danger
//
//  Created by James Trever on 30/01/2016.
//  Copyright © 2016 James Trever. All rights reserved.
//

import Foundation
import MapKit
import AddressBook

class Incident: NSObject, MKAnnotation {
    let title: String?
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    let radius: Int?
    let report_count: Int?
    let level: String
    let message: String?
    let id: String?
    
    init(locationName: String?, coordinate: CLLocationCoordinate2D, radius: Int?, report_count: Int?, level: String, message: String?) {
        self.locationName = locationName
        self.coordinate = coordinate
        self.radius = radius
        self.report_count = report_count
        self.level = level
        self.message = message
        self.id = nil
        self.title = message
        super.init()
    }
    
    var subtitle: String? {
        return "\(report_count!) reports of this incident \(radius!) meter area"
    }
    
    // annotation callout info button opens this mapItem in Maps app
//    func mapItem() -> MKMapItem {
//        let addressDictionary = [String(kABPersonAddressStreetKey): (subtitle as! AnyObject)]
//        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
//        
//        let mapItem = MKMapItem(placemark: placemark)
//        mapItem.name = title
//        
//        return mapItem
//    }
}