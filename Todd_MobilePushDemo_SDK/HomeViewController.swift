//
//  ViewController.swift
//  Todd_MobilePushDemo_SDK
//
//  Created by Todd Isaacs on 9/9/19.
//  Copyright © 2019 Todd Isaacs. All rights reserved.
//

import UIKit
import MarketingCloudSDK


class HomeViewController: UIViewController {

  @IBOutlet weak var appIDLabel: UILabel!
  @IBOutlet weak var midLabel: UILabel!
  @IBOutlet weak var urlLabel: UILabel!
  @IBOutlet weak var tokenLabel: UILabel!
  @IBOutlet weak var inboxLabel: UILabel!
  @IBOutlet weak var etanalyticslabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var pianalytcsLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setupView()
  }
  
  private func setupView() {
    
    let mid = Model.builder["mid"] as? String ?? ""
    let appid = Model.builder["appid"] as? String ?? ""
    let url = Model.builder["marketing_cloud_server_url"] as? String ?? ""
    let token = Model.builder["accesstoken"] as? String ?? ""
    midLabel.text = mid
    appIDLabel.text = appid
    urlLabel.text = url
    tokenLabel.text = token
    
    if let inbox = Model.builder["inbox"] as? NSNumber {
      inboxLabel.text = (inbox == 1) ? "true" : "false"
    }
    if let location = Model.builder["location"] as? NSNumber {
      locationLabel.text = (location == 1) ? "true" : "false"
    }
    if let pianalytics = Model.builder["pianalytics"] as? NSNumber {
      pianalytcsLabel.text = (pianalytics == 1) ? "true" : "false"
    }
    if let etanalytics = Model.builder["etanalytics"] as? NSNumber {
      etanalyticslabel.text = (etanalytics == 1) ? "true" : "false"
    }
    
    for (key, value) in Model.builder {
      print(key, value)
    }
  }

}
