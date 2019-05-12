//
//  ACDeviceCell.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/16.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit


//MARK: - ACDeviceCell
class ACDeviceCell: UITableViewCell {
    
    var cellModel: ACDeviceModel? {
        didSet {
            numLabel.text = cellModel?.num
            defaultLabel.isHidden = cellModel?.isUse != true
        }
    }
    var intoCallBack: ((_ model: ACDeviceModel?)->())?
    
    @IBOutlet weak var defaultLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    
    @IBAction func intoAction(_ sender: UIButton) {
        if intoCallBack != nil { intoCallBack!(cellModel) }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
