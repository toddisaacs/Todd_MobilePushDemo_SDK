//
//  AppDelegate.swift
//  Todd_MobilePushDemo_SDK
//
//  Created by Todd Isaacs on 9/9/19.
//  Copyright © 2019 Todd Isaacs. All rights reserved.
//

import UIKit
import MarketingCloudSDK


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  var window: UIWindow?
  
  let inbox = true
  let location = true
  let pushAnalytics = true
  let piAnalytics = true
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let builder = MarketingCloudSDKConfigBuilder()
      .sfmc_setApplicationId(appID)
      .sfmc_setAccessToken(accessToken)
      .sfmc_setMarketingCloudServerUrl(appEndpoint)
      .sfmc_setMid(mid)
      .sfmc_setInboxEnabled(inbox as NSNumber)
      .sfmc_setLocationEnabled(location as NSNumber)
      .sfmc_setAnalyticsEnabled(pushAnalytics as NSNumber)
      .sfmc_setPiAnalyticsEnabled(piAnalytics as NSNumber)
      .sfmc_build()!
    
    Model.builder = builder
    
    var success = false
    
    // Once you've created the builder, pass it to the sfmc_configure method.
    do {
      try MarketingCloudSDK.sharedInstance().sfmc_configure(with:builder)
      success = true
    } catch let error as NSError {
      // Errors returned from configuration will be in the NSError parameter and can be used to determine
      // if you've implemented the SDK correctly.
      
      let configErrorString = String(format: "MarketingCloudSDK sfmc_configure failed with error = %@", error)
      print(configErrorString)
    }
    
    if success == true {
      // The SDK has been fully configured and is ready for use!
      
      // Enable logging for debugging. Not recommended for production apps, as significant data
      // about MobilePush will be logged to the console.
      #if DEBUG
        MarketingCloudSDK.sharedInstance().sfmc_setDebugLoggingEnabled(true)
      #endif
      
      // Set the MarketingCloudSDKURLHandlingDelegate to a class adhering to the protocol.
      // In this example, the AppDelegate class adheres to the protocol
      // and handles URLs passed back from the SDK.
      // For more information, see https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/sdk-implementation/implementation-urlhandling.html
      MarketingCloudSDK.sharedInstance().sfmc_setURLHandlingDelegate(self)
      
      // Make sure to dispatch this to the main thread, as UNUserNotificationCenter will present UI.
      DispatchQueue.main.async {
        if #available(iOS 10.0, *) {
          // Set the UNUserNotificationCenterDelegate to a class adhering to thie protocol.
          // In this exmple, the AppDelegate class adheres to the protocol (see below)
          // and handles Notification Center delegate methods from iOS.
          UNUserNotificationCenter.current().delegate = self
          
          // Request authorization from the user for push notification alerts.
          UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {(_ granted: Bool, _ error: Error?) -> Void in
            if error == nil {
              if granted == true {
                // Your application may want to do something specific if the user has granted authorization
                // for the notification types specified; it would be done here.
                print(MarketingCloudSDK.sharedInstance().sfmc_deviceToken() ?? "error: no token - was UIApplication.shared.registerForRemoteNotifications() called?")
              }
            }
          })
        }
        
        // In any case, your application should register for remote notifications *each time* your application
        // launches to ensure that the push token used by MobilePush (for silent push) is updated if necessary.
        
        // Registering in this manner does *not* mean that a user will see a notification - it only means
        // that the application will receive a unique push token from iOS.
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
    
    return true
  }
  
  // MobilePush SDK: REQUIRED IMPLEMENTATION
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    MarketingCloudSDK.sharedInstance().sfmc_setDeviceToken(deviceToken)
  }
  
  // MobilePush SDK: REQUIRED IMPLEMENTATION
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print(error)
  }
  
  // MobilePush SDK: REQUIRED IMPLEMENTATION
  /** This delegate method offers an opportunity for applications with the "remote-notification" background mode to fetch appropriate new data in response to an incoming remote notification. You should call the fetchCompletionHandler as soon as you're finished performing that operation, so the system can accurately estimate its power and data cost.
   This method will be invoked even if the application was launched or resumed because of the remote notification. The respective delegate methods will be invoked first. Note that this behavior is in contrast to application:didReceiveRemoteNotification:, which is not called in those cases, and which will not be invoked if this method is implemented. **/
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    MarketingCloudSDK.sharedInstance().sfmc_setNotificationUserInfo(userInfo)
    completionHandler(.newData)
  }
  
  // MobilePush SDK: REQUIRED IMPLEMENTATION
  // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    // Required: tell the MarketingCloudSDK about the notification. This will collect MobilePush analytics
    // and process the notification on behalf of your application.
    MarketingCloudSDK.sharedInstance().sfmc_setNotificationRequest(response.notification.request)
    completionHandler()
  }
  
  // MobilePush SDK: REQUIRED IMPLEMENTATION
  // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler(.alert)
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
      print("applicationWillTerminate")
  }
}
extension AppDelegate: MarketingCloudSDKURLHandlingDelegate {
  /**
   This method, if implemented, can be called when a Alert+CloudPage, Alert+OpenDirect, Alert+Inbox or Inbox message is processed by the SDK.
   Implementing this method allows the application to handle the URL from Marketing Cloud data.
   
   Prior to the MobilePush SDK version 6.0.0, the SDK would automatically handle these URLs and present them using a SFSafariViewController.
   
   Given security risks inherent in URLs and web pages (Open Redirect vulnerabilities, especially), the responsibility of processing the URL shall be held by the application implementing the MobilePush SDK. This reduces risk to the application by affording full control over processing, presentation and security to the application code itself.
   
   @param url value NSURL sent with the Location, CloudPage, OpenDirect or Inbox message
   @param type value NSInteger enumeration of the MobilePush source type of this URL
   */
  func sfmc_handle(_ url: URL, type: String) {
    
    // Very simply, show a Safari view controller in the root VC with the URL returned from the MobilePush SDK.
    //let vc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
    //window?.topMostViewController()?.present(vc, animated: true)
  }
}
