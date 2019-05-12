//
//  ACRoomCell.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/16.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit


//MARK: - ACRoomCell
class ACRoomCell: UITableViewCell {
    
    var cellModel: ACRoomModel? {
        didSet {
            titleLbl.text = cellModel?.title
        }
    }
    var intoCallBack: ((_ model: ACRoomModel?)->())?
    
    @IBOutlet weak var titleLbl: UILabel!
    
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
