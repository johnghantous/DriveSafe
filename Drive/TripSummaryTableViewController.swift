//
//  TripSummaryTableViewController.swift
//  Drive
//
//  Created by Andrew Ke on 12/23/15.
//  Copyright © 2015 Andrew. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI
import Charts

// didDismiss is called when a modalally presented view controller dismisses itself
// This protocol is used to allow ViewController.swift to be notified so it can remove the blur when needed
protocol ModalPresenterVC
{
    func didDismiss()
}

class TripSummaryTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var chart: LineChartView!
    
    // MARK: - Properties
    var info = ["Average Speed", "Time Elapsed", "Driver Rating", "% of trip over limit"]
    var trip: Trip!
    var delegate: ModalPresenterVC?
    var notModal: Bool = false // If this is true, the view controller was pushed by a navigation controller. If false, it was modally presented
    
    var colors = [UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor()]
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.hideBottomHairline()
        (presentingViewController as! UINavigationController).navigationBarHidden = true

        if (!notModal)
        {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "doneButtonPressed:")
        }
        
        print("****DEBUG LOG****")
        print("\(trip.data.count) locations recorded, \(trip.limits.count) speed limits recorded")
        for (var i = 0; i < min(trip.data.count, trip.limits.count); i++)
        {
            print("\(i). Recorded: \(2.2374 * trip.data[i].speed)    Limit: \(trip.limits[i])")
        }
        
        var speeds: [ChartDataEntry] = []
        var limits: [ChartDataEntry] = []
        var xVals: [Int] = []
        
        for (var i = 0; i < min(trip.data.count, trip.limits.count); i++)
        {
            speeds.append(ChartDataEntry(value: trip.data[i].speed>0 ? 2.2374*trip.data[i].speed : 0 , xIndex: i))
            limits.append(ChartDataEntry(value: Double(trip.limits[i]), xIndex: i))
            xVals.append(i)
        }
        
        let set1 = LineChartDataSet(yVals: speeds, label: "Your Speed")
        set1.drawCubicEnabled = true
        set1.drawValuesEnabled = false
        set1.drawCirclesEnabled = false
        set1.lineWidth = 1.0

        let set2 = LineChartDataSet(yVals: limits, label: "Speed Limit")
        set2.drawCubicEnabled = true
        set2.drawValuesEnabled = false
        set2.drawCirclesEnabled = false
        set2.setColor(UIColor.redColor())
        set2.lineWidth = 1.0
        
        let data = LineChartData(xVals: xVals, dataSets: [set1, set2])
        chart.data = data
        
        
        chart.legend.textColor = UIColor.whiteColor()
        chart.descriptionText = ""
        chart.drawGridBackgroundEnabled = false
        
        chart.xAxis.drawLabelsEnabled = false
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.drawAxisLineEnabled = false
        
        let rightAxis = chart.rightAxis
        rightAxis.drawLabelsEnabled = false
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawAxisLineEnabled = false
        
        let leftAxis = chart.leftAxis
        leftAxis.labelTextColor = UIColor.whiteColor()
        leftAxis.xOffset = 10
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false

        
        chart.userInteractionEnabled = false
        chart.animate(xAxisDuration: 2.0)
        chart.noDataText = "No Data Availible"
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        if let delegate = delegate
        {
            delegate.didDismiss()
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            (presentingViewController as! UINavigationController).navigationBarHidden = false
        }
    }
    
    // MARK: - Email Sending
    @IBAction func sendEmail(sender: UIBarButtonItem) {
        revertNav()
        let vc = MFMailComposeViewController()
        vc.view.backgroundColor = UIColor.clearColor()
        vc.mailComposeDelegate = self
        vc.setSubject("My Driver Rating")
        vc.setMessageBody("On my latest drive, I got a driver rating of \(String(format: "%.1f", trip.driverRating)) out of 10!", isHTML: false)
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        setNav()
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        cell.textLabel?.text = info[indexPath.row]
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.backgroundColor = UIColor.clearColor()
        
        switch info[indexPath.row] {
        case "Time Elapsed":
            cell.detailTextLabel?.text = String(format: "%.1f minutes", trip.timeLapsed/60.0)
        case "Average Speed":
            cell.detailTextLabel?.text = String(format: "%.1f MPH", 2.2374 * trip.averageSpeed)
        case "Driver Rating":
            cell.detailTextLabel?.text = String(format: "%.1f out of 10", trip.driverRating)
        case "% of trip over limit":
            cell.detailTextLabel?.text = String(format: "%d", Int(100 - 10*trip.driverRating))
        default:
            break
        }
        return cell
    }


}
