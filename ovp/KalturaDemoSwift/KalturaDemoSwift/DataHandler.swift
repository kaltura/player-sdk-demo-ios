//
//  DataHandler.swift
//  KalturaDemoSwift
//
//  Created by Nissim Pardo on 13/01/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

import Foundation

protocol DataHandlerDelegate {
    func reload();
}

class DataHandler: NSObject {
    var cellsData: [NSMutableDictionary]
    var delegate: DataHandlerDelegate!
    var config: [String: String]!
    
    var flavourId: String {
        get {
            return self.config["FlavourId"]!
        }
    }
    
    var playerConfig: KPPlayerConfig! {
        get {
            let domain: String = self.config["Domain"]!
            let uiConf: String = self.config["UIConf"]!
            let partnerId: String = self.config["PartnerId"]!
            let entryId: String = self.config["EntryId"]!
            let ks: String = self.config["KS"]!
            let temp: KPPlayerConfig = KPPlayerConfig(domain: domain, uiConfID: uiConf, partnerId: partnerId)!
            temp.ks = ks
            temp.entryId = entryId
            temp.cacheSize = 1.0
            return temp
        }
    }
    
    override init() {
        self.cellsData = [NSMutableDictionary]();
        if let path = NSBundle.mainBundle().pathForResource("demoParams", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                   do {
                    cellsData = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! [NSMutableDictionary]
                    if NSUserDefaults.standardUserDefaults().objectForKey("config") != nil {
                        cellsData.first!["value"] = NSUserDefaults.standardUserDefaults().objectForKey("config")
                    }
                   } catch {
                    print("failed to parse demoParams");
                }
            } catch {
                print("failed to load demoParams");
            }
        }
    }
    
    func cellParamAtIndex(index: Int) -> NSMutableDictionary {
        return cellsData[index];
    }
    
    func cellIdentifier(index: Int) -> String {
        switch (cellParamAtIndex(index)["cellType"]!.integerValue) {
        case 0:
            return "Input"
        case 1:
            return "Action"
        default:
            return ""
        }
    }
    
    func cellTitleAtIndex(index: Int) -> String {
        return cellParamAtIndex(index)["title"] as! String
    }
    
    func updateTextAtIndex(index: Int, text: String) {
        let dict: NSMutableDictionary =  self.cellParamAtIndex(index)
        dict["value"] = text;
    }
    
    func cellsCount() -> Int {
        return self.cellsData.count;
    }
    
    func valueForIndexPath(indexPath: NSIndexPath) -> String? {
        if self.cellIdentifier(indexPath.row) == "Input" {
            let dict: NSMutableDictionary = self.cellsData[indexPath.row]
            return self.config[dict["title"] as! String]
        }
        return nil
    }
    
    func fetchConfiguration() {
        let url: NSURL = NSURL(string: NSUserDefaults.standardUserDefaults().objectForKey("config") as! String)!
        KConnection.fetchConfigFileAtURL(url) { (config, error) -> Void in
            if config != nil {
                self.config = config.first
                for cell: NSMutableDictionary in self.cellsData {
                    if cell["cellType"] as! Int == 0 {
                        cell["value"] = self.config[cell["title"] as! String]
                    }
                }
                self.delegate.reload()
            }
        }
    }
}
