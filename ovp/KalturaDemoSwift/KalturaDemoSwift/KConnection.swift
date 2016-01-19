//
//  KConnection.swift
//  KalturaDemoSwift
//
//  Created by Nissim Pardo on 17/01/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

import Foundation

protocol KConnectionDelegate {
    func updateProgress(progress: Float!)
    func didVideoDownloaded(path: String!)
}

class KConnection: NSObject, NSURLSessionDownloadDelegate {
    var url: NSURL
    var progressBlock: (progress: Float) -> Void
    var completionBlock: ((localURL: NSURL!, error: NSError!) -> Void)?
    var isDRM: Bool!
    
    init(url: NSURL) {
        self.url = url
        progressBlock = {_ in }
        completionBlock = {_ in }
    }
    
    static func fetchVideoAtURL(url: NSURL, progressBlock: (progress: Float!) -> Void, completion: (LocalUrl: NSURL!, error: NSError!) -> Void) {
        let connection: KConnection = KConnection(url: url)
        connection.progressBlock =  progressBlock
        connection.completionBlock = completion
        connection.isDRM = url.pathComponents?.last?.hasSuffix(".wvm")
        connection.statrtDownload();
    }
    
    static func fetchConfigFileAtURL(url: NSURL, completion: (config: [[String: String]]!, error: NSError!) -> Void) {
        let task: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: url), completionHandler: { (data, response, error) -> Void in
            if data != nil {
                do {
                let temp: [[String: String]] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [[String: String]]
                    completion(config: temp, error: nil)
                } catch {
                    print("failed to parse demoConfig file")
                }
            } else if error != nil {
                completion(config: nil, error: error)
            }
        })
        task.resume()
    }
    
    
    func statrtDownload() {
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let request = NSURLRequest(URL: self.url)
        let session: NSURLSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let task: NSURLSessionDownloadTask = session.downloadTaskWithRequest(request)
        task.resume()
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentPath = paths.firstObject
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        let suffix: String = self.isDRM.boolValue ? "wvm" : "mp4"
        let destinationURL: NSURL = NSURL(fileURLWithPath: (documentPath?.stringByAppendingPathComponent("local.".stringByAppendingString(suffix)))!)
        if fileManager.fileExistsAtPath(destinationURL.path!) {
            do {
            try fileManager.replaceItemAtURL(destinationURL, withItemAtURL: destinationURL, backupItemName: nil, options: NSFileManagerItemReplacementOptions.UsingNewMetadataOnly, resultingItemURL: nil)
            } catch {
                print("failed store file")
            }
        } else {
            do {
                try fileManager.moveItemAtURL(location, toURL: destinationURL)
            } catch {
                print("failed store file")
            }
            
        }
        self.completionBlock!(localURL: destinationURL, error: nil)
        self.completionBlock = nil
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.progressBlock(progress: Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if self.completionBlock != nil {
            self.completionBlock!(localURL: nil, error: error)
        }
    }
}
