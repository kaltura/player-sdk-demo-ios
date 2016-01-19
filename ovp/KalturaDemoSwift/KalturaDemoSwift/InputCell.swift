//
//  InputCell.swift
//  KalturaDemoSwift
//
//  Created by Nissim Pardo on 13/01/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

import UIKit

protocol CellDelegate {
    func textUpdated(text: String, cell: InputCell);
}

class InputCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: CellDelegate!
    
    var params: NSDictionary {
        get {
            return self.params;
        }
        set {
            titleLabel.text = newValue["title"] as? String;
            if let str = newValue["value"] as? String {
                textField.text = str
            }
        }
    }
    
        
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        self.delegate.textUpdated(textField.text! + string, cell: self);
        return true;
    }
    
    
    
}