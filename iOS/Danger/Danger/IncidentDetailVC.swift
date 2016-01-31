//
//  IncidentDetailVC.swift
//  Danger
//
//  Created by James Trever on 31/01/2016.
//  Copyright © 2016 James Trever. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class IncidentDetailVC: UIViewController {
    
    @IBOutlet var cancelIncident: UIButton!
    @IBOutlet var type: UISegmentedControl!
    @IBOutlet var subtype: UISegmentedControl!
    @IBOutlet var details: UITextField?
    @IBOutlet var otherType: UITextField?
    @IBOutlet var submitButton: UIButton!

    var id: String!

    var isMajor: Bool!
    var county: String?
    var coord: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.id = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        self.type.setTitle("Mass Shooting", forSegmentAtIndex: 0)
        self.type.setTitle("Natural Disaster", forSegmentAtIndex: 1)
        self.type.insertSegmentWithTitle("Other", atIndex: 2, animated: false)
        

        self.subtype.setTitle("Shooting", forSegmentAtIndex: 0)
        self.subtype.setTitle("Robbery", forSegmentAtIndex: 1)
        self.subtype.insertSegmentWithTitle("Bombing", atIndex: 2, animated: false)

        self.type.tintColor = UIColor.redColor()
        self.subtype.tintColor = UIColor.redColor()
        self.submitButton?.tintColor = UIColor.redColor()
        self.submitButton.layer.cornerRadius = 5;
        self.submitButton.layer.borderWidth = 1;
        self.submitButton.layer.borderColor = UIColor.redColor().CGColor
        self.cancelIncident.tintColor = UIColor.redColor()
        self.cancelIncident.layer.cornerRadius = 5;
        self.cancelIncident.layer.borderWidth = 1;
        self.cancelIncident.layer.borderColor = UIColor.redColor().CGColor
        
        self.otherType?.hidden = true
        self.subtype.selectedSegmentIndex = UISegmentedControlNoSegment
        
        self.otherType?.layer.borderColor = UIColor.redColor().CGColor
        self.otherType?.layer.borderWidth = 1
        self.otherType?.layer.cornerRadius = 5;
        
        self.details?.layer.borderColor = UIColor.redColor().CGColor
        self.details?.layer.borderWidth = 1
        self.details?.layer.cornerRadius = 5;

        
        self.submitButton.addTarget(self, action: "submitAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func submitAction(sender: UIButton) {
        var theTypeText: String?
        var theSubTypeText = ""
        
        let typeVal = self.type.selectedSegmentIndex
        let subTypeVal = self.subtype.selectedSegmentIndex
        
        if (typeVal == 0){
            theTypeText = "Mass Shooting"
        }
        else if (typeVal == UISegmentedControlNoSegment){
            if(subTypeVal == 0){
                theTypeText = "Shooting"
            }
            else if (subTypeVal == 1){
                theTypeText = "Robbery"
            }
            else {
                theTypeText = "Bombing"
            }
        }
        else if (typeVal == 1){
            theTypeText = "Natural Disaster"
            if(subTypeVal == 0){
                theSubTypeText = "Flood"
            }
            else if (subTypeVal == 1){
                theSubTypeText = "Fire"
            }
            else {
                theSubTypeText = "Earthquake"
            }
        }
        else {
            theTypeText = "Other"
            theSubTypeText = (self.otherType?.text)!
        }
        
        let descriptionText: String
        if let _ = self.details?.text {
            descriptionText = (self.details?.text)!
        }else {
            descriptionText = "\(theTypeText) \(theSubTypeText)"
        }

        
        
        
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let lat = self.coord!.coordinate.latitude
        let long = self.coord?.coordinate.longitude
        let parameters = [
            "type" : theTypeText!,
            "subtype" : theSubTypeText,
            "description" : descriptionText,
            "user_id" : self.id!,
            "lat" : lat,
            "lon" : long!,
            "region" : self.county!
        ]
        Alamofire.request(.POST, "http://188.166.154.26/reports", headers: headers, parameters: parameters as? [String : AnyObject], encoding: .JSON)
        
        self.dismissViewControllerAnimated(true, completion: {});
    }

    @IBAction func segmentSwitch(sender: UISegmentedControl) {
        if (sender == type){
            let selectedSegment = self.type.selectedSegmentIndex;
            switch (selectedSegment) {
                case 0:
                    self.otherType?.hidden = true
                    self.subtype.selectedSegmentIndex = UISegmentedControlNoSegment
                    self.subtype.hidden = false
                    self.subtype.setTitle("Shooting", forSegmentAtIndex: 0)
                    self.subtype.setTitle("Robbery", forSegmentAtIndex: 1)
                    self.subtype.setTitle("Bombing", forSegmentAtIndex: 2)
                    break;
                case 1:
                    self.otherType?.hidden = true
                    self.subtype.selectedSegmentIndex = 0
                    self.subtype.hidden = false
                    self.subtype.setTitle("Flood", forSegmentAtIndex: 0)
                    self.subtype.setTitle("Fire", forSegmentAtIndex: 1)
                    self.subtype.setTitle("Earthquake", forSegmentAtIndex: 2)
                    break;
                default:
                    self.otherType?.hidden = false
                    self.subtype.selectedSegmentIndex = UISegmentedControlNoSegment
                    self.subtype.hidden = true
                    self.subtype.setTitle("Shooting", forSegmentAtIndex: 0)
                    self.subtype.setTitle("Robbery", forSegmentAtIndex: 1)
                    self.subtype.setTitle("Bombing", forSegmentAtIndex: 2)
                    break;
            }
        }
        else {
            let selectedSegment = self.subtype.selectedSegmentIndex;
            switch (selectedSegment) {
            case 0:
                self.otherType?.hidden = true
                self.type.selectedSegmentIndex = UISegmentedControlNoSegment
                self.subtype.hidden = false
                break;
            case 1:
                self.otherType?.hidden = true
                self.type.selectedSegmentIndex = UISegmentedControlNoSegment
                self.subtype.hidden = false
                break;
            default:
                self.otherType?.hidden = true
                self.type.selectedSegmentIndex = UISegmentedControlNoSegment
                self.subtype.hidden = false
                break;
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
