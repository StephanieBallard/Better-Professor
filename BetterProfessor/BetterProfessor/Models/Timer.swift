//
//  Timer.swift
//  BetterProfessor
//
//  Created by Bhawnish Kumar on 6/25/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import Foundation

enum TimerType: Int, Codable {

    case date = 0
    case time
    case both
}

struct StudentTimer: Codable, Equatable {
    var name = ""
    //Supply by the user
    var dateTime: Date?
    var timerType = TimerType.time
    // Active means the time has been set. !Active means it has fired/completed.
    var active = false
    var noteText = ""
    //For the system timer objects
    var timerUuid: String?
    //    var timer: Timer?
}
