//
//  InfoViewController.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 4/1/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit
import MessageUI


class InfoViewController: UIViewController {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var menuInEventsSwitch: UISwitch!
    // TODO: Open link in safari
    @IBOutlet weak var sourceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconImage.image = StyleKit.imageOfIconBig(size: iconImage.bounds.size, resizing: .AspectFill)
        menuInEventsSwitch.on = PreferencesManager.includeMenuInEventsNotes
    }
    

    @IBAction func sendFeedback(sender: UIButton) {
        
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["ugrmenu.feedback@icloud.com"])
            composeVC.setSubject("UGR Menu Feedback")
            
            self.presentViewController(composeVC, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("Email Not Available"), message: NSLocalizedString("You need to set up an email account first on your device."), preferredStyle: .Alert)
            let action = UIAlertAction(title: NSLocalizedString("OK"), style: .Cancel, handler: { action in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(action)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func switchToggleState(sender: UISwitch) {
        PreferencesManager.includeMenuInEventsNotes = sender.on
    }
}


extension InfoViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}