//
//  CalendarDateCell.swift
//  Respectful Spaces
//
//  Created by Babin,Emily on 2025-04-25.
//

import UIKit
import JTAppleCalendar

class CalendarDateCell: JTACDayCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventDot: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        eventDot.layer.cornerRadius = eventDot.frame.size.height / 2
        eventDot.isHidden = true // Hide dot by default
    }
}

