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
//    @IBOutlet weak var sourceLabel: UILabel!
    
    @IBOutlet weak var iconImageWidthConstraint: NSLayoutConstraint!
//    @IBOutlet weak var titleGroupBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet var descriptionLabels: [UILabel]!
    @IBOutlet var contentLabels: [UILabel]!
//    @IBOutlet weak var optionsGroupBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoGroup: UIStackView!
    @IBOutlet weak var priceAndHoursGroup: UIStackView!
    @IBOutlet weak var sourceGroup: UIStackView!
//    @IBOutlet weak var infoGroupBottomConstraint: NSLayoutConstraint!
//    @IBOutlet weak var titleGroupToIconConstraint: NSLayoutConstraint!
    @IBOutlet weak var optionsLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet var infoSubgroups: [UIStackView]!
    @IBOutlet weak var sourceTextView: UITextView!
    
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconImage.image = StyleKit.imageOfIconBig(size: iconImage.bounds.size, resizing: .AspectFill)
        menuInEventsSwitch.on = PreferencesManager.includeMenuInEventsNotes
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = NSLocalizedString("UGR Menu") + " v\(version)"
        }
        
        // Set appearance for small screens
        if UIDevice.currentDevice().isSmalliPhone {
            iconWidthConstraint.constant = min(view.frame.width, view.frame.height) * 0.44
            appNameLabel.font = appNameLabel.font.fontWithSize(28)
            infoGroup.spacing = 10
            priceAndHoursGroup.spacing = 10
//            descriptionLabels.forEach { $0.font = $0.font.fontWithSize(13) }
//            sourceTextView.font = sourceTextView.font?.fontWithSize(15)
//            contentLabels.forEach { $0.font = $0.font.fontWithSize(15) }
//            optionsLabel.font = optionsLabel.font.fontWithSize(15)
//            infoSubgroups.forEach { $0.spacing = 6 }
        }
    }
    
    
    /// Updates constraints that change accoding to device orientation.
    func updateMutableConstraints() {
        if UIDevice.currentDevice().isSmalliPhone == false {
            
        }
//        if UIDevice.currentDevice().orientation.isPortrait {
//            if UIDevice.currentDevice().isSmalliPhone {
//                iconImageWidthConstraint.constant = 160
//                titleGroupBottomConstraint.constant = 20
//                priceAndHoursGroup.axis = .Horizontal
//                priceAndHoursGroup.spacing = 20
//                sourceGroup.axis = .Horizontal
//                sourceGroup.alignment = .FirstBaseline
//                infoGroup.spacing = 14
//                infoGroupBottomConstraint.constant = 20
//                sourceGroup.spacing = 10
////                titleGroupToIconConstraint.active = false
//            } else {
//                infoGroupBottomConstraint.constant = 50
//                titleGroupBottomConstraint.constant = 64
//            }
//        } else {
//            if UIDevice.currentDevice().isSmalliPhone {
//                iconImageWidthConstraint.constant = 130
//                titleGroupBottomConstraint.constant = 20
//                priceAndHoursGroup.axis = .Vertical
//                priceAndHoursGroup.spacing = 10
//                sourceGroup.axis = .Vertical
//                sourceGroup.alignment = .Leading
//                infoGroup.spacing = 6
//                infoGroupBottomConstraint.constant = 10
//                sourceGroup.spacing = 2
//                infoSubgroups.forEach { $0.sizeToFit() }
////                titleGroupToIconConstraint.active = true
////                titleGroupToIconConstraint.constant = 10    // TODO: Not working
//            } else {
//                infoGroupBottomConstraint.constant = 30
//                titleGroupBottomConstraint.constant = 30
////                titleGroupToIconConstraint.constant = 40
//            }
//        }
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        updateMutableConstraints()
    }

    
    @IBAction func sendFeedback(sender: UIButton) {
        
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["ugrmenu.feedback@icloud.com"])
            composeVC.navigationBar.tintColor = UIColor.customRedColor()
            
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