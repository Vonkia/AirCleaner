//
//  ProgressHUD.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/17.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import SVProgressHUD

enum HUDType {
    case info
    case success
    case error
    case loading
    case progress
}

class ProgressHUD: NSObject {
    
    class func initProgressHUD() {
        SVProgressHUD.setFont(UIFont.systemFont(ofSize: 14.0))
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
        SVProgressHUD.setMaximumDismissTimeInterval(2.0)
        SVProgressHUD.setBackgroundColor(HEXCOLOR(0xbdbdbd))
    }
        
    class func showSuccess(_ status: String) {
        self.showProgressHUD(type: .success, status: status)
    }
    class func showError(_ status: String) {
        self.showProgressHUD(type: .error, status: status)
    }
    class func showLoading(_ status: String = "") {
        self.showProgressHUD(type: .loading, status: status)
    }
    class func showInfo(_ status: String) {
        self.showProgressHUD(type: .info, status: status)
    }
    class func showProgress(_ status: String = "", progress: CGFloat) {
        self.showProgressHUD(type: .progress, status: status, progress: progress)
    }
    class func dismissHUD(_ delay: TimeInterval = 0) {
        SVProgressHUD.dismiss(withDelay: delay)
    }
}


extension ProgressHUD {
    class func showProgressHUD(type: HUDType, status: String, progress: CGFloat = 0) {
        switch type {
        case .info:
            SVProgressHUD.showInfo(withStatus: status)
        case .success:
            SVProgressHUD.showSuccess(withStatus: status)
        case .error:
            SVProgressHUD.showError(withStatus: status)
        case .loading:
            if status.count > 0 {
                SVProgressHUD.show(withStatus: status)
            } else {
                SVProgressHUD.show()
            }
        case .progress:
            if status.count > 0 {
                SVProgressHUD.showProgress(Float(progress), status: status)
            } else {
                SVProgressHUD.showProgress(Float(progress))
            }
        }
    }
}

