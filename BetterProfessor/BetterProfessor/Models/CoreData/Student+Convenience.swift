//
//  Student+Convenience.swift
//  BetterProfessor
//
//  Created by Stephanie Ballard on 6/22/20.
//  Copyright © 2020 Stephanie Ballard. All rights reserved.
//

import Foundation
import CoreData

extension Student {
    @discardableResult convenience init(id: Int64,
                                        name: String,
                                        email: String,
                                        subject: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.name = name
        self.email = email
        self.subject = subject
    }

    @discardableResult convenience init?(representation: StudentRepresentation,
                                            context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

           guard let id = representation.id else {
               NSLog("Representation passed in with invalid id")
               return nil
           }
        self.init(id: id,
                  name: representation.name,
                  email: representation.email,
                  subject: representation.subject)
    }
}
