//
//  User.swift
//  BetterProfessor
//
//  Created by Bhawnish Kumar on 6/22/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import Foundation

struct User: Codable {

    var id: Int64?
    var username: String
    var password: String
    var department: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case password
        case department

        case session
        case user
    }

      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
        try container.encode(department, forKey: .department)
    }

    init(username: String, password: String, department: String, id: Int64? = nil) {
        self.id = id
        self.username = username
        self.password = password
        self.department = department
    }

     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sessionDictionary = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .session)
        let userDictionary = try sessionDictionary.nestedContainer(keyedBy: CodingKeys.self, forKey: .user)

        id = try userDictionary.decode(Int64.self, forKey: .id)
        username = try userDictionary.decode(String.self, forKey: .username)
        password = try userDictionary.decode(String.self, forKey: .password)
        department = nil
    }
}
