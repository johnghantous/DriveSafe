//
//  TripsTableViewController.swift
//  Drive
//
//  Created by Arnav Gudibande on 12/24/15.
//  Copyright © 2015 Arnav. All rights reserved.
//

import UIKit
var VC: TripSummaryTableViewController!

class TripsTableViewController: UITableViewController {
    
    
    var trips: [Trip]!
    var delegate: ModalPresenterVC?
    
    //MARK: - VC Lifecycle
    override func viewDidLoad() {
        
        
        // Extract trips from NSUserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        if let tripsData = defaults.objectForKey("trips") as? NSData
        {
            trips = NSKeyedUnarchiver.unarchiveObjectWithData(tripsData) as! [Trip]
            trips = trips.reverse()
        }else
        {
            trips = []
        }
        
        super.viewDidLoad()
        navigationController?.navigationBar.hideBottomHairline()
        (presentingViewController as! UINavigationController).navigationBarHidden = true
        clearsSelectionOnViewWillAppear = true
        
        //registerForPreviewingWithDelegate(self, sourceView: view)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow
        {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.tableView.alpha = 1
        })
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        (presentingViewController as! UINavigationController).navigationBarHidden = false
        if let delegate = delegate
        {
            delegate.didDismiss()
        }
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table View Datasource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = "\(indexPath.row)"
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.backgroundColor = UIColor.clearColor()
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .ShortStyle
        
        let trip = trips[indexPath.row]
        if let timeStamp = trip.data.first?.timestamp
        {
            cell.textLabel?.text = formatter.stringFromDate(timeStamp)
        }else
        {
            cell.textLabel?.text = "NA"
        }
        cell.detailTextLabel?.text = String(format: "%.1f", trip.driverRating)
        return cell
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goToTrip")
        {
            let trip = trips[tableView.indexPathForCell((sender as! UITableViewCell))!.row]
            let tripVC = segue.destinationViewController as! TripSummaryTableViewController
            tripVC.trip = trip
            tripVC.notModal = true
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.tableView.alpha = 0
            })
        }
    }
    
}
