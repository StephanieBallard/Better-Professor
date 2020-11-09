//
//  TimerController.swift
//  BetterProfessor
//
//  Created by Bhawnish Kumar on 6/25/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import Foundation

protocol TimerModelDelegate {
     // swiftlint:disable:next all
    func create(name: String, dateTime: Date, timerType: TimerType, active: Bool, tag: String)
  // swiftlint:disable:next all
    func update(timer t: StudentTimer,
                name: String, dateTime: Date,
                timerType: TimerType,
                active: Bool,
                tag: String)
}

class TimerController: TimerModelDelegate  {

    var timers: [StudentTimer] = []

    // This initilizer is treated as the viewDidLoad of the model controller.
    init() {
        loadFromPersistentStore()
    }
    
    var filter = ""
    var filteredTimers: [StudentTimer] {
        return timers.filter { $0.noteText.lowercased() == filter }
    }
    
    var activeTimers: [StudentTimer] {
        return timers.filter { $0.active == true }
    }
    
    var completedTimers: [StudentTimer] {
        return timers.filter { $0.active == false }
    }

    //These find* are leveraging equatable
    func findTimer(_ timer: StudentTimer) -> StudentTimer? {
        let matches = timers.filter { $0 == timer }
        assert(matches.count == 1)
        return matches[0]
    }
     // swiftlint:disable:next all
    func findTimerIndex(_ t: StudentTimer) -> Int? {
        if let index = timers.firstIndex(where: { $0 == t }) {
            return index
        } else {
            return nil
        }
    }
    
    // MARK: - CRUD
    
    // Create
    func create(name: String,
                dateTime: Date,
                timerType: TimerType = .time,
                active: Bool = true,
                tag: String = "") {
        
        let timer = StudentTimer(name: name,
                                   dateTime: dateTime,
                                   timerType: timerType,
                                   active: active,
                                   noteText: tag)

        timers.append(timer)

        //timers = timers.sorted { $0.name.lowercased() < $1.name.lowercased() }

        saveToPersistentStore()

        if let uuid = notificationController.scheduleNotification(timer: timer) {
            timerController.notificationScheduled(timer: timer, timerUuid: uuid)
        }
    }

    // Update
     // swiftlint:disable:next all
    func update(timer t: StudentTimer, name: String, dateTime: Date, timerType: TimerType, active: Bool, tag: String) {
        guard let index = findTimerIndex(t) else { fatalError("Timer Object Not Found") }
        
        timers[index].name = name
        timers[index].dateTime = dateTime
        timers[index].timerType = timerType
        timers[index].active = active
        timers[index].noteText = tag

        if timers[index] /* Now "updated" */ == t /* The Prior State */ {
            // This is a nop. User didn't make any changes and clicked up. Just exit.
            return
        }

        saveToPersistentStore()

        if let uuid = notificationController.scheduleNotification(timer: timers[index]) {
            timerController.notificationScheduled(timer: timers[index], timerUuid: uuid)
        }
    }
     // swiftlint:disable:next all
    func notificationScheduled(timer t: StudentTimer, timerUuid: String) {
        if let index = timers.firstIndex(where: { $0 == t }) {
            timers[index].timerUuid = timerUuid
            timers[index].active = true
        }

        saveToPersistentStore()
    }
 // swiftlint:disable:next all
    func notificationCanceled(timer t: StudentTimer) {
        if let index = timers.firstIndex(where: { $0 == t }) {
            timers[index].timerUuid = nil
            timers[index].active = false
        }

        saveToPersistentStore()
    }
    // Delete
     func delete(timer timerToDelete: StudentTimer) {
         let timerMinusTimersToDelete = timers.filter { $0 != timerToDelete }
         timers = timerMinusTimersToDelete

         saveToPersistentStore()
     }

    // MARK: Persistent Store

     var timerURL: URL? {
         let fileManager = FileManager.default

         let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first

         let timerURL = documentsDir?.appendingPathComponent("timer.plist")

         return timerURL
     }

     func saveToPersistentStore() {
         // Convert our timer Property List

         let encoder = PropertyListEncoder()

         do {
             let timerData = try encoder.encode(timers)

             guard let timerURL = timerURL else { return }

             try timerData.write(to: timerURL)

         } catch {
             print("Unable to save timer to plist: \(error)")
         }
     }

     func loadFromPersistentStore() {

         do {
             guard let timerURL = timerURL else { return }

             let timerData = try Data(contentsOf: timerURL)
             let decoder = PropertyListDecoder()
             let decodedCart = try decoder.decode([StudentTimer].self, from: timerData)

             self.timers = decodedCart
         } catch {
             print("Unable to open shopping cart plist: \(error)")
         }
     }
}
