//
//  ActionCell.swift
//  KalturaDemoSwift
//
//  Created by Nissim Pardo on 13/01/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

import UIKit

class ActionCell: InputCell {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var progress: Float {
        get {
            return progressView.progress
        }
        set {
            if progressView.hidden == true {
                progressView.hidden = false
                self.titleLabel.hidden = true
            }
            progressView.setProgress(newValue, animated: true)
        }
    }
    
    var title: String {
        get {
            return self.titleLabel.text!
        }
        set {
            self.titleLabel.text = newValue;
            progressView.hidden = true
            self.titleLabel.hidden = false
        }
    }
    
}
