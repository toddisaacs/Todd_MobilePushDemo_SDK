//
//  InBoxViewController.swift
//  Todd_MobilePushDemo_SDK
//
//  Created by Todd Isaacs on 9/21/19.
//  Copyright © 2019 Todd Isaacs. All rights reserved.
//

import UIKit
import MarketingCloudSDK
import SafariServices

class InBoxViewController: UITableViewController {
  
  var dataSourceArray = [[String:Any]]()
  var inboxRefreshObserver: NSObjectProtocol?
  
  var dateFormatter:DateFormatter {
    let df = DateFormatter()
    df.dateFormat = "MM/dd/yyyy HH:mm"
    return df
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  private func setupView() {
    navigationItem.title = "Marketing Cloud InBox"
  }
 
  
  override func viewDidDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(inboxRefreshObserver as Any)
    inboxRefreshObserver = nil
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if inboxRefreshObserver == nil {
      inboxRefreshObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.SFMCInboxMessagesRefreshComplete, object: nil, queue: OperationQueue.main) {(_ note: Notification) -> Void in
        self.refreshControl?.endRefreshing()
        self.reloadData()
      }
    }
    
    reloadData()
  }
  
  // This method will fetch already-downloaded messages from the SDK, sort by the sendDateUtc value
  // into the data source for this UITableViewController.
  func reloadData() {
    if let inboxArray = MarketingCloudSDK.sharedInstance().sfmc_getAllMessages() as? [[String : Any]] {
      dataSourceArray = inboxArray.sorted {
        
        if $0["sendDateUtc"] == nil {
          return true
        }
        if $1["sendDateUtc"] == nil {
          return true
        }
        
        let s1 = $0["sendDateUtc"] as! Date
        let s2 = $1["sendDateUtc"] as! Date
        
        return s1 < s2
      }
      tableView.reloadData()
      
    }
  }
}

// MARK: - UITableViewDataSource
extension InBoxViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSourceArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "InBoxCell", for: indexPath)
    
    let message = dataSourceArray[indexPath.row]
    
    
    if let subject = message["subject"] as? String {
      cell.textLabel?.text = subject
    }
    
    if let subtitleString = message["subtitle"] as? String {
      
      var sentDateString = "nil date"
      if let d = message["sendDateUtc"] as? Date {
        sentDateString = dateFormatter.string(from: d)
      }
      
      cell.detailTextLabel?.text = "\(sentDateString) \(subtitleString)"
      
    }
    
     return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let inboxMessage = dataSourceArray[indexPath.row]
    
    // In a basic inbox implementation, the application should call the methods below to ensure that
    // analytics are being tracked correctly and that the SDK and Marketing Cloud accurately reflect
    // the read state of the message.
    MarketingCloudSDK.sharedInstance().sfmc_trackMessageOpened(inboxMessage)
    MarketingCloudSDK.sharedInstance().sfmc_markMessageRead(inboxMessage)
    
  }
}
