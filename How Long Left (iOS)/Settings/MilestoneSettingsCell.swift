//
//  MilestoneSettingsCell.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 7/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit


class MilestoneSettingsCell: UITableViewCell {
    
    var milestone: Int?
    
    @IBOutlet weak var milestoneItemLabel: UILabel!
    
    
    func setupCell(milestone: HLLMilestone) {
        
        self.selectedBackgroundView = AppTheme.current.selectedCellView
        self.backgroundColor = AppTheme.current.tableCellBackgroundColor
        self.milestoneItemLabel.textColor = AppTheme.current.textColor
        
            milestoneItemLabel.text = milestone.settingsRowString
            
        }

    
}
