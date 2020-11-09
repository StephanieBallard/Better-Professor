//
//  StudenRepresentation.swift
//  BetterProfessor
//
//  Created by Bhawnish Kumar on 6/23/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import Foundation

class StudentRepresentation: Codable {
    var id: Int64?
    var name: String
    var email: String
    var subject: String
 
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case subject
      
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
         try container.encode(email, forKey: .email)
         try container.encode(subject, forKey: .subject)
      
        
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        subject = try container.decode(String.self, forKey: .subject)
       
    }

}
