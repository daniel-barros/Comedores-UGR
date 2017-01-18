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


// DaniKit
// Collection of functions, protocols, operators and extensions missing in common Apple frameworks.


import Foundation
#if os(iOS)
    import UIKit
#elseif os(watchOS)
    import WatchKit
#endif


infix operator =? : AssignmentPrecedence

/// Performs assignment only if the element on the right is not nil, otherwise it does nothing.
func =? <T>(left: inout T, right: T?) {
    if let right = right {
        left = right
    }
}

/// Performs assignment only if the element on the right is not nil, otherwise it does nothing.
func =? <T>(left: inout T?, right: T?) {
    if let right = right {
        left = right
    }
}

/// Performs assignment only if the element on the right is not nil, otherwise it does nothing.
func =? <T>(left: inout T!, right: T?) {
    if let right = right {
        left = right
    }
}

// **************  THREADS, DELAYS  **************

/// Executes the given closure on the main thread after the specified time (in seconds)
func delay(_ delay: Double, closure: @escaping ()->()) {
    let popTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
    DispatchQueue.main.asyncAfter(deadline: popTime, execute: closure)
}

/// Executes the given closure on the main queue
func mainQueue(_ closure: @escaping ()->()) {
    DispatchQueue.main.async(execute: closure)
}

/// Executes the given closure with mutual exclusion
func synced(_ lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}


// **************  FOUNDATION AND STANDARD LIBRARY EXTENSIONS  **************

extension Array {
    
    var second: Iterator.Element? {
        guard count >= 2 else {
            return nil
        }
        return self[1]
    }
    
    var third: Iterator.Element? {
        guard count >= 3 else {
            return nil
        }
        return self[2]
    }
    
    var fourth: Iterator.Element? {
        guard count >= 4 else {
            return nil
        }
        return self[3]
    }
    
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
    
    /// Return a copy of `self` with its elements shuffled.
    func shuffled() -> [Element] {
        var list = self
        list.shuffle()
        return list
    }
}


extension String {
    
    /// Use one or more parameters to create an attributed string with certain properties.
    ///
    /// A nil parameter will be ignored.
    func with(font: UIFont? = nil,
              color: UIColor? = nil,
              lineSpacing: CGFloat? = nil,
              paragraphSpacing: CGFloat? = nil,
              lineBreakMode: NSLineBreakMode? = nil) -> NSAttributedString {
        
        var attributes: [String: AnyObject] = [:]
        
        attributes[NSFontAttributeName] =? font
        
        attributes[NSForegroundColorAttributeName] =? color
        
        if lineSpacing != nil || paragraphSpacing != nil || lineBreakMode != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing =? paragraphSpacing
            paragraphStyle.lineBreakMode =? lineBreakMode
            paragraphStyle.lineSpacing =? lineSpacing
            attributes[NSParagraphStyleAttributeName] = paragraphStyle
        }
        
        return NSAttributedString(string: self, attributes: attributes)
    }
}


extension CGSize {
    
    static var max: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
    
    
    func with(height: CGFloat) -> CGSize {
        return CGSize(width: self.width, height: height)
    }
    
    
    func with(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: self.height)
    }
}


extension Bool {
    
    static var random: Bool {
        return arc4random_uniform(2) == 0 ? true : false
    }
}


extension Date {
    
    var isInPast: Bool {
        return timeIntervalSinceNow < 0
    }
    
    var isTodayOrFuture: Bool {
        return Calendar.current.isDateInToday(self) || self.timeIntervalSinceNow > 0
    }
}


extension Calendar {
    
    func differenceInDays(from firstDate: Date, to secondDate: Date) -> Int {
        let date1 = startOfDay(for: firstDate)
        let date2 = startOfDay(for: secondDate)
        return dateComponents([.day], from: date1, to: date2).day!
    }
}


// **************  UIKIT EXTENSIONS  **************

#if os(iOS)
    
extension UIDevice {
    /// - returns: `true` if screen is smaller than iPhone 6
    var isSmalliPhone: Bool {
        let screenSize = UIScreen.main.bounds
        return min(screenSize.width, screenSize.height) < 375
    }
    
    var isiPhone4sOrPrevious: Bool {
        let screenSize = UIScreen.main.bounds
        return max(screenSize.width, screenSize.height) < 568
    }
}
    
#endif


// **************  FUNCTIONS  **************

func NSLocalizedString(_ string: String) -> String {
    return NSLocalizedString(string, comment: "")
}


// **************  PROTOCOLS  **************

/// When you implement the `configure(_:T)` method you can specify the parameter name you want. If there's no need for a parameter at all implement it like this: `func configure(_: Void) { ... }`.
protocol Configurable {
    associatedtype T
    func configure(_: T)
}
