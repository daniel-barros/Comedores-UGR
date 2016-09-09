//
//  AppDelegate.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/9/16.
/*
MIT License

Copyright (c) 2016 Daniel Barros

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    /// - returns: `session` property if watch is paired and reachable, and app is installed. `nil` otherwise
    var validSession: WCSession? {
        if let validSession = session where validSession.paired && validSession.watchAppInstalled && validSession.reachable {
            return validSession
        } else {
            return nil
        }
    }

    let fetcher = WeekMenuFetcher()
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window?.tintColor = UIColor.customRedColor()
        
        session?.delegate = self
        session?.activateSession()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


extension AppDelegate: WCSessionDelegate {
    
    // Sends back an archived version of the week menu, fetching first if necessary.
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {

        guard fetcher.isFetching == false else { return }
        
        func sendMenu(menu: [DayMenu]) {
            let archivedMenu = NSKeyedArchiver.archivedMenu(menu)
            validSession?.sendMessageData(archivedMenu, replyHandler: nil, errorHandler: nil)
        }
        
        if fetcher.needsToUpdateMenu {
            fetcher.fetchMenu(completionHandler: { newMenu in
                sendMenu(newMenu)
            }, errorHandler: { error in print(error) })
        } else {
            sendMenu(fetcher.savedMenu!)
        }
    }
    
    
    @available(iOS 9.3, *)
    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {
        
    }
    
    
    func sessionDidBecomeInactive(session: WCSession) {
        
    }
    
    
    func sessionDidDeactivate(session: WCSession) {
        
    }
}
