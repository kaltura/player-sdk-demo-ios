//
//  ViewController.swift
//  KalturaDemoSwift
//
//  Created by Nissim Pardo on 20/12/2015.
//  Copyright © 2015 kaltura. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KPSourceURLProvider, KPViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, CellDelegate, DataHandlerDelegate {
    var player : KPViewController!
    var handler: DataHandler!
    var tapRecognizer: UITapGestureRecognizer!
    var offlineURL: NSURL!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        handler = DataHandler()
        handler.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didKeyboardOpened:"), name: UIKeyboardWillShowNotification, object: nil);
    }
    
    func didKeyboardOpened(notification: NSNotification!) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didKeyboardClosed:"), name: UIKeyboardWillHideNotification, object: nil)
        let keyboardRect: NSValue = notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let newHeight: CGFloat = self.tableView.frame.size.height - keyboardRect.CGRectValue().size.height
        UIView.animateWithDuration(0.25, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.tableView.frame = CGRect(origin: self.tableView.frame.origin, size: CGSize(width: self.tableView.frame.size.width, height: newHeight))
            }) { (success) -> Void in
        }
    }
    
    func didKeyboardClosed(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didKeyboardOpened:"), name: UIKeyboardWillShowNotification, object: nil)
        let keyboardRect: NSValue = notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let newHeight: CGFloat = self.tableView.frame.size.height + keyboardRect.CGRectValue().size.height
        UIView.animateWithDuration(0.25, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.tableView.frame = CGRect(origin: self.tableView.frame.origin, size: CGSize(width: self.tableView.frame.size.width, height: newHeight))
            }) { (success) -> Void in
                
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func urlForEntryId(entryId: String!, currentURL current: String!) -> String! {
        return offlineURL.absoluteString;
    }
    

    func updateCurrentPlaybackTime(currentPlaybackTime: Double) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return handler.cellsCount();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier: String = handler.cellIdentifier(indexPath.row);
        let cell: InputCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! InputCell
        cell.delegate = self;
        cell.params = handler.cellParamAtIndex(indexPath.row);
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row < 8 {
            return
        }
        let cell: ActionCell = tableView.cellForRowAtIndexPath(indexPath) as! ActionCell
        switch (indexPath.row) {
        case 8:
            if cell.title == "Get License" {
                KPLocalAssetsManager.registerAsset(handler.playerConfig, flavor: handler.flavourId, path: self.offlineURL.absoluteString, callback: { (error) -> Void in
                    if error != nil {
                        cell.title = "License Error"
                    } else {
                        cell.title = "Licensed"
                    }
                })
            } else {
                let idx: NSIndexPath = NSIndexPath(forItem: 7, inSection: 0)
                KConnection.fetchVideoAtURL(NSURL(string: handler.valueForIndexPath(idx)!)!, progressBlock: {(progress) -> Void in
                    cell.progress = progress
                    }, completion: {(url, error) -> Void in
                        self.offlineURL = url!
                        cell.title = "Get License"
                })
            }
            break;
        case 9:
            
            break;
        case 10:
            if player == nil {
                player = KPViewController(configuration: handler.playerConfig)
                player.customSourceURLProvider = self
                player.delegate = self
                self.presentViewController(player, animated: true, completion: nil)
            }
            break;
        case 11:
            handler.fetchConfiguration()
            break;
        default:
            break;
        }
        
    }
    
    func textUpdated(text: String, cell: InputCell) {
        if tableView.indexPathForCell(cell)?.row == 0 {
            NSUserDefaults.standardUserDefaults().setObject(text, forKey: "config")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        self.handler.updateTextAtIndex((self.tableView.indexPathForCell(cell)?.row)!, text: text);
    }
    
    
    func kPlayer(player: KPViewController!, playerLoadStateDidChange state: KPMediaLoadState) {
        if state == KPMediaLoadState.Playable {
//            self.tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("tap"))
//            self.tapRecognizer.delegate = self;
//            self.player.view.addGestureRecognizer(self.tapRecognizer);
        }
    }
    
    func reload() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
//    func tap() {
//        print("Works!!");
//    }
//    
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true;
//    }
    
    
}

