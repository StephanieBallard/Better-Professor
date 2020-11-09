//
//  Project.swift
//  BetterProfessor
//
//  Created by Hunter Oppel on 6/24/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import Foundation

struct Project: Codable {
    let projectID: Int
    let projectName: String
    let dueDate: Date
    let studentId: String
    let studentName: String
    let projectType: String
    let description: String
    let completed: Bool

    enum CodingKeys: String, CodingKey {
        case projectID = "id"
        case projectName
        case dueDate
        case studentId
        case studentName = "name"
        case projectType
        case description = "desc"
        case completed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.projectID = try container.decode(Int.self, forKey: .projectID)
        self.projectName = try container.decode(String.self, forKey: .projectName)
        self.studentId = try container.decode(String.self, forKey: .studentId)
        self.studentName = try container.decode(String.self, forKey: .studentName)
        self.projectType = try container.decode(String.self, forKey: .projectType)
        self.description = try container.decode(String.self, forKey: .description)

        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let dateString = try container.decode(String.self, forKey: .dueDate)
        self.dueDate = formatter.date(from: dateString) ?? Date()

        let completedInt = try container.decode(Int.self, forKey: .completed)
        if completedInt == 0 {
            self.completed = false
            return
        } else {
            self.completed = true
        }
    }
}
