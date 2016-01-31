//
//  IncidentVC.swift
//  Danger
//
//  Created by James Trever on 30/01/2016.
//  Copyright © 2016 James Trever. All rights reserved.
//

import UIKit
import MapKit

class IncidentVC: UIViewController {
    
    @IBOutlet var cancelIncident: UIButton!
    @IBOutlet var majorIncident: UIButton!
    @IBOutlet var minorIncident: UIButton!
    
    var county: String?
    var coord: CLLocation?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.majorIncident.tintColor = UIColor.redColor()
        self.minorIncident.tintColor = UIColor.redColor()
        self.cancelIncident.tintColor = UIColor.redColor()
        
        majorIncident.addTarget(self, action: "lauchMoreDetails:", forControlEvents: UIControlEvents.TouchUpInside)
        minorIncident.addTarget(self, action: "lauchMoreDetails:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "IncidentDetailSegue"){
            let incidentDetailVC = segue.destinationViewController as? IncidentDetailVC
            if (sender as! UIButton! == majorIncident){
                incidentDetailVC!.isMajor = true
            }
            else {
                incidentDetailVC!.isMajor = false
            }
            incidentDetailVC?.county = county
            incidentDetailVC?.coord = coord
        }

    }
    
    func cancelIncidentPopup(sender: AnyObject) {
        performSegueWithIdentifier("unwindFromIncidentPopup", sender: sender)
        
    }
    
    func lauchMoreDetails(sender: UIButton!) {
        performSegueWithIdentifier("IncidentDetailSegue", sender: sender)
    }
    
    func unwindFromPopup(segue: UIStoryboardSegue) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
