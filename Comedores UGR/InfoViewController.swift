//
//  InfoViewController.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 4/1/16.
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
import MessageUI


// TODO: Fix constraints issues on iOS 10

class InfoViewController: UIViewController {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var menuInEventsSwitch: UISwitch!
    @IBOutlet weak var iconImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var infoGroup: UIStackView!
    @IBOutlet weak var priceAndHoursGroup: UIStackView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconImage.image = StyleKit.imageOfIconBig(size: iconImage.bounds.size, resizing: .AspectFill)
        menuInEventsSwitch.on = PreferencesManager.includeMenuInEventsNotes
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = NSLocalizedString("UGR Menu") + " v\(version)"
        }
        
        let fetcher = WeekMenuFetcher()
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        priceLabel.text = numberFormatter.stringFromNumber(fetcher.menuPrice)! + "€"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        hoursLabel.text = dateFormatter.stringFromDate(fetcher.diningOpeningTime) + " – " +
            dateFormatter.stringFromDate(fetcher.diningClosingTime)
        
        // Set appearance for small screens
        if UIDevice.currentDevice().isSmalliPhone {
            iconWidthConstraint.constant = min(view.frame.width, view.frame.height) * 0.44
            appNameLabel.font = appNameLabel.font.fontWithSize(28)
            infoGroup.spacing = 10
            priceAndHoursGroup.spacing = 10
            
            if UIDevice.currentDevice().isiPhone4sOrPrevious {
                iconWidthConstraint.constant = 0
                iconImage.hidden = true
            }
        }
    }
    
    
    // TODO: This is a quick fix until you solve the constraints issues.
    override func shouldAutorotate() -> Bool {
        if #available(iOS 10, *) {
            return false
        }
        return true
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
