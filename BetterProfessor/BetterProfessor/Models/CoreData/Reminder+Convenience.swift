//
//  Reminder+Convenience.swift
//  BetterProfessor
//
//  Created by Stephanie Ballard on 6/22/20.
//  Copyright © 2020 Stephanie Ballard. All rights reserved.
//

import Foundation
import CoreData

extension Reminder {
    @discardableResult convenience init(name: String,
                                        bodyText: String,
                                        timestamp: Date = Date(),
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.name = name
        self.bodyText = bodyText
        self.timestamp = timestamp
    }
}
