//
//  StudentTableViewCell.swift
//  BetterProfessor
//
//  Created by Bhawnish Kumar on 6/23/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit

class StudentTableViewCell: UITableViewCell {
    
    @IBOutlet var photoImage: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var subectLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var student: Student? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let student = student else { return }
        nameLabel.text = student.name
        emailLabel.text = student.email
        subectLabel.text = student.subject
    }
    
    
}

