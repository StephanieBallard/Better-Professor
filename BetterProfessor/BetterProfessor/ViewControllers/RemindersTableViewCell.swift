//
//  RemindersTableViewCell.swift
//  BetterProfessor
//
//  Created by Bhawnish Kumar on 6/25/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit

class RemindersTableViewCell: UITableViewCell {

     var timer: StudentTimer? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet weak var timerNameLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    
    func updateViews() {
        guard let timer = timer else { return }

        timerNameLabel.text = timer.name
        tagLabel.text = timer.noteText

        if timer.active {
            // FIXME: Real value
            timerLabel.text = "🏃🏿‍♀️🏃🏿‍♂️"
        } else {
            timerLabel.text = "Not active"
        }
    }

}
