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
    
    @IBOutlet weak var iconImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleGroupBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet var descriptionLabels: [UILabel]!
    @IBOutlet var contentLabels: [UILabel]!
    @IBOutlet weak var optionsGroupBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoGroup: UIStackView!
    @IBOutlet weak var priceAndHoursGroup: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconImage.image = StyleKit.imageOfIconBig(size: iconImage.bounds.size, resizing: .AspectFill)
        menuInEventsSwitch.on = PreferencesManager.includeMenuInEventsNotes
        
        if UIDevice.currentDevice().isSmalliPhone {
            iconImageWidthConstraint.constant = 160
            titleGroupBottomConstraint.constant = 40
            appNameLabel.font = appNameLabel.font.fontWithSize(28)
            authorLabel.font = authorLabel.font.fontWithSize(15)
            optionsGroupBottomConstraint.constant = 16
            descriptionLabels.forEach { $0.font = $0.font.fontWithSize(13) }
            contentLabels.forEach { $0.font = $0.font.fontWithSize(15) }
            infoGroup.spacing = 14
            priceAndHoursGroup.spacing = 20
        }
    }
    

    @IBAction func sendFeedback(sender: UIButton) {
        
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["ugrmenu.feedback@icloud.com"])
//            composeVC.setSubject("UGR Menu Feedback")
            
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