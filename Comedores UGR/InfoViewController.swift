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
    @IBOutlet weak var sourceGroup: UIStackView!
    @IBOutlet weak var infoGroupBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleGroupToIconConstraint: NSLayoutConstraint!
    @IBOutlet weak var optionsLabel: UILabel!
    @IBOutlet var infoSubgroups: [UIStackView]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconImage.image = StyleKit.imageOfIconBig(size: iconImage.bounds.size, resizing: .AspectFill)
        menuInEventsSwitch.on = PreferencesManager.includeMenuInEventsNotes
        
        // Set appearance for small screens
        if UIDevice.currentDevice().isSmalliPhone {
            iconImageWidthConstraint.constant = 160
            appNameLabel.font = appNameLabel.font.fontWithSize(28)
            authorLabel.font = authorLabel.font.fontWithSize(15)
            descriptionLabels.forEach { $0.font = $0.font.fontWithSize(13) }
            contentLabels.forEach { $0.font = $0.font.fontWithSize(15) }
            optionsGroupBottomConstraint.constant = 16
            optionsLabel.font = optionsLabel.font.fontWithSize(15)
            infoSubgroups.forEach { $0.spacing = 6 }
            updateMutableConstraints()
        }
    }
    
    
    /// Updates constraints that change accoding to device orientation.
    func updateMutableConstraints() {
        if UIDevice.currentDevice().orientation.isPortrait {
            if UIDevice.currentDevice().isSmalliPhone {
                titleGroupBottomConstraint.constant = 20
                priceAndHoursGroup.axis = .Horizontal
                priceAndHoursGroup.spacing = 20
                infoGroup.spacing = 14
                infoGroupBottomConstraint.constant = 20
                sourceGroup.sizeToFit()
            } else {
                infoGroupBottomConstraint.constant = 50
                titleGroupBottomConstraint.constant = 64
            }
        } else {
            if UIDevice.currentDevice().isSmalliPhone {
                titleGroupBottomConstraint.constant = 20
                priceAndHoursGroup.axis = .Vertical
                priceAndHoursGroup.spacing = 10
                infoGroup.spacing = 10
                infoGroupBottomConstraint.constant = 10
                sourceGroup.sizeToFit()
                titleGroupToIconConstraint.constant = 20
            } else {
                infoGroupBottomConstraint.constant = 30
                titleGroupBottomConstraint.constant = 30
                titleGroupToIconConstraint.constant = 40
            }
        }
        view.updateConstraints()
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        updateMutableConstraints()
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