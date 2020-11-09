//
//  ReminderTableViewController.swift
//  BetterProfessor
//
//  Created by Bhawnish Kumar on 6/25/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit

import UIKit

extension String {
    static var defaultTimerFormat = "defaultTimerFormat"
}
extension Date {

    func offsetFrom(date: Date, type: TimerType) -> String {

        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self)

        var seconds = ""
        var minutes = ""
        var hours = ""
        var days = ""
        var typeStr = ""

        switch type {
        case .both:
            typeStr = " 📆⏰"
            seconds = "\(difference.second ?? 0)s"
            minutes = "\(difference.minute ?? 0)m" + " " + seconds
            hours = "\(difference.hour ?? 0)h" + " " + minutes
            days = "\(difference.day ?? 0)d" + " " + hours
        case .date:
            typeStr = " 📆"
            days = "\(difference.day ?? 0) Days"
        case .time:
            typeStr = " ⏰"
            seconds = "\(difference.second ?? 0)s"
            minutes = "\(difference.minute ?? 0)m" + " " + seconds
            hours = "\(difference.hour ?? 0)h" + " " + minutes
            days = "\(difference.day ?? 0)d" + " " + hours
        }

        if let day = difference.day, day          > 0 { return days + typeStr }
        if let hour = difference.hour, hour       > 0 { return hours + typeStr }
        if let minute = difference.minute, minute > 0 { return minutes + typeStr }
        if let second = difference.second, second > 0 { return seconds + typeStr }
        return .finishedMsg
    }

}

extension String {
    static var finishedMsg = "Done"
    static var appTitle = "Better Professor"
    static var noTag = "no tag"
}

var timerController = TimerController()
var notificationController = NotificationController()

class ReminderTableViewController: UITableViewController {

    @IBOutlet weak var notificationButton: UIBarButtonItem!

    @IBAction func notificationButtonPress(_ sender: Any) {
        showAlert(msg: "Notifications have been turned off. Please turn them on in the Settings app under Notifications.")
    }

    // MARK: - Filter code
    var filterEnabled = false {
        didSet {
            filterFunc()
        }
    }

    @IBAction func filterButton(_ sender: Any) {
        // Grab a list of all the tag types
        // Crudely going to force them all lowercase to avoid duplicates based on letter case
        var uniqueValues: [String] = []
         // swiftlint:disable:next all
        for t in timerController.activeTimers {
            if !uniqueValues.contains(t.noteText.lowercased()) {
                uniqueValues += [t.noteText.lowercased()]
            }
        }

        if uniqueValues.count < 2 {
           showAlert(msg: "Not enough tags to create a filter.")
            return
        }

        uniqueValues.sort()

        // Create alert actions for each tag type
        let alert = UIAlertController(title: .appTitle,
                                      message: "Select Tag to Filter On",
                                      preferredStyle: .alert)
 // swiftlint:disable:next all
        for u in uniqueValues {
            var tag = u
            if u == "" { tag = .noTag }
            let itemToFilter = UIAlertAction(title: tag, style: .default) { (action:UIAlertAction!) in
                //print("\(tag) button tapped")
                timerController.filter = tag
                self.filterEnabled = true
            }

            alert.addAction(itemToFilter)
        }

        // Give user option Cancel filter operation
        let itemToFilter = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            self.filterEnabled = false
            self.tableView.reloadData()
        }

        alert.addAction(itemToFilter)

        // Present alert to uesr to select tag they wish to filter on
        present(alert, animated: true, completion: nil)
    }

    func filterFunc() {
        if timerController.filter == .noTag {
            timerController.filter = ""
        }
        tableView.reloadData()
    }

    // MARK: - Alert
    private func showAlert(msg text: String ) {
        let alert = UIAlertController(title: .appTitle,
                                      message: text,
                                      preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction!) in
            self.tableView.reloadData()
        }
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationControllerUx()

        startTimer()
    }

    func notificationControllerUx() {
        if notificationController.notificationsEnabled {
            navigationItem.leftBarButtonItem = nil
        } else {
            notificationButton.isEnabled = true
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        cancelTimer()
    }

    // MARK: - Timer related code

    // called each time the timer object fires
    var systemStudentTimer: Timer?
    var timerIterations = 0

    private func startTimer() {
        print("Start timer")
        if systemStudentTimer == nil {
            systemStudentTimer = Timer.scheduledTimer(withTimeInterval: 1.00, repeats: true, block: timerFired(timer:))
        }
    }
    
    private func cancelTimer() {
        print("Cancel timer")
        // We must invalidate a timer, or it will continue to run even if we
        // start a new timer
        systemStudentTimer?.invalidate()
        systemStudentTimer = nil
    }

    private func timerFired(timer: Timer) {
        timerIterations += 1
        print("Timer Fired \(timerIterations)")
        updateTableViewTimer()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = timerController.activeTimers.count
        if filterEnabled {
            result = timerController.filteredTimers.count
        }
        return result
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath) as? RemindersTableViewCell else { fatalError("RemindersTableViewCell was expected" ) }

        var timer = timerController.activeTimers[indexPath.row]
        if filterEnabled {
            timer = timerController.filteredTimers[indexPath.row]
        }

        // Configure the cell
        cell.timer = timer
        
        return cell
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            var timerToBeDeleted = timerController.activeTimers[indexPath.row]
            if filterEnabled {
                timerToBeDeleted = timerController.filteredTimers[indexPath.row]
            }
            timerController.delete(timer: timerToBeDeleted)

            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filterEnabled {
            return "\(timerController.filter.capitalized) Filter Applied"
        }
        
        return ""
    }

    func updateTableViewTimer() {
        // TODO: Very unhappy with this. What if I have more than a screenful of data?
        var row = 0

        var timersToUpdate = timerController.activeTimers
        if filterEnabled {
            timersToUpdate = timerController.filteredTimers
        }

        for timer in timersToUpdate {
             // swiftlint:disable:next all
            let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! RemindersTableViewCell
            
            var displayTimer = "N/A"
            if let dateTime = timer.dateTime {
                displayTimer = dateTime.offsetFrom(date: Date(), type: timer.timerType)
            }
            
            cell.timerLabel.text = displayTimer

            if displayTimer == .finishedMsg, timer.active == true {
                // Calling cancel will set timer.active to false
                notificationController.cancelNotification(timer: timer)
                notificationController.beep()
                showAlert(msg: " \(timer.name)'s\nProject is due\nTimer has been turned off.")
            }
            row += 1
        }
    }

    // MARK: - Navigation

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.

        guard let detailVC = segue.destination as? ReminderDetailViewController else {return}
        detailVC.timerModelDelegate = timerController
        
        if segue.identifier == "AddDetailSegue" {
            print("AddDetailSegue called")
            
        } else if segue.identifier == "EditDetailSegue" {
            print("EditDetailSegue called")
            // Find the timer the user tapped on and set the VC's timer object to it.
            guard let indexPath = tableView?.indexPathForSelectedRow else { return }
            var timer = timerController.activeTimers[indexPath.row]
            if filterEnabled {
                timer = timerController.filteredTimers[indexPath.row]
            }
            detailVC.timer = timer
       }
    }

    override func viewWillAppear(_ animated: Bool) {
        notificationControllerUx()
        tableView.reloadData()
        startTimer()
    }
}
