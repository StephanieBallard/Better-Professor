//
//  FetchedResultsController.swift
//  BetterProfessor
//
//  Created by Stephanie Ballard on 6/22/20.
//  Copyright © 2020 Stephanie Ballard. All rights reserved.
//

import CoreData
import UIKit

    // TODO: Add lazy in front of first var
    var studentFetchedResultsController: NSFetchedResultsController<Student> = {
    let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    let context = CoreDataStack.shared.mainContext
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: context,
                                         sectionNameKeyPath: "student", cacheName: nil)
//    frc.delegate = self
    do {
        try frc.performFetch()
    } catch {
        print("Error performing initial fetch inside fetchedResultsController: \(error)")
    }
    return frc
}()

    // TODO: Add lazy in front of first var
    var reminderFetchedResultsController: NSFetchedResultsController<Reminder> = {
    let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
    let context = CoreDataStack.shared.mainContext
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "timestamp", cacheName: nil)
//    frc.delegate = self
    do {
        try frc.performFetch()
    } catch {
        print("Error performing initial fetch inside fetchedResultsController: \(error)")
    }
    return frc
}()
