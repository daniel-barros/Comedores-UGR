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
        
        iconImage.image = StyleKit.imageOfIconBig(size: iconImage.bounds.size, resizing: .aspectFill)
        menuInEventsSwitch.isOn = PreferencesManager.includeMenuInEventsNotes
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = NSLocalizedString("UGR Menu") + " v\(version)"
        }
        
        let fetcher = WeekMenuFetcher()
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        priceLabel.text = numberFormatter.string(from: NSNumber(value: fetcher.menuPrice))! + "€"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        hoursLabel.text = dateFormatter.string(from: fetcher.diningOpeningTime) + " – " +
            dateFormatter.string(from: fetcher.diningClosingTime)
        
        // Set appearance for small screens
        if UIDevice.current.isSmalliPhone {
            iconWidthConstraint.constant = min(view.frame.width, view.frame.height) * 0.44
            appNameLabel.font = appNameLabel.font.withSize(28)
            infoGroup.spacing = 10
            priceAndHoursGroup.spacing = 10
            
            if UIDevice.current.isiPhone4sOrPrevious {
                iconWidthConstraint.constant = 0
                iconImage.isHidden = true
            }
        }
    }
    
    
    // TODO: This is a quick fix until you solve the constraints issues.
    override var shouldAutorotate : Bool {
        if #available(iOS 10, *) {
            return false
        }
        return true
    }
    
    
    @IBAction func sendFeedback(_ sender: UIButton) {
        
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["ugrmenu.feedback@icloud.com"])
            composeVC.navigationBar.tintColor = .customRedColor
            
            self.present(composeVC, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("Email Not Available"), message: NSLocalizedString("You need to set up an email account first on your device."), preferredStyle: .alert)
            let action = UIAlertAction(title: NSLocalizedString("OK"), style: .cancel, handler: { action in
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func switchToggleState(_ sender: UISwitch) {
        PreferencesManager.includeMenuInEventsNotes = sender.isOn
    }
}


extension InfoViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
