//
//  Common.swift
//
//  Created by Daniel Barros López on 1/16/16.
//  Copyright © 2016 Daniel Barros López. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

// **************  THREADS, DELAYS  **************

/// Executes the given closure on the main thread after the specified time (in seconds)
func delay(delay: Double, closure: dispatch_block_t) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)));
    dispatch_after(popTime, dispatch_get_main_queue(), closure)
}

/// Executes the given closure on the main queue
func mainQueue(closure: dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue(), closure)
}

enum QueueQualityOfService {
    case UserInteractive, UserInitiated, Utility, Background
    
    var GCDValue: qos_class_t {
        switch self {
        case .UserInteractive: return QOS_CLASS_USER_INTERACTIVE
        case .UserInitiated: return QOS_CLASS_USER_INITIATED
        case .Utility: return QOS_CLASS_UTILITY
        case .Background: return QOS_CLASS_BACKGROUND
        }
    }
}

/// Executes the given closure concurrently on a queue of the specified QOS (Quality of Service)
func concurrentQueue(qos: QueueQualityOfService, closure: dispatch_block_t) {
    dispatch_async(dispatch_get_global_queue(qos.GCDValue, 0), closure)
}

/// Executes the given closure with mutual exclusion
func synced(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

// **************  STRUCT EXTENSIONS  **************

extension Array {
    var second: Generator.Element? {
        guard count >= 2 else {
            return nil
        }
        return self[1]
    }
    
    var third: Generator.Element? {
        guard count >= 3 else {
            return nil
        }
        return self[2]
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


extension CGSize {
    static var max: CGSize {
        return CGSize(width: CGFloat.max, height: CGFloat.max)
    }
}


extension Bool {
    static var random: Bool {
        return arc4random_uniform(2) == 0 ? true : false
    }
}


extension NSDate {
    var isInPast: Bool {
        return timeIntervalSinceNow < 0
    }
}

// **************  PLATFORM-DEPENDENT EXTENSIONS  **************

#if os(iOS)
    extension UIDevice {
        /// - returns: `true` if screen is smaller than iPhone 6
        var isSmalliPhone: Bool {
            let screenSize = UIScreen.mainScreen().bounds
            return min(screenSize.width, screenSize.height) < 375
        }
    }
    
#elseif os(OSX)
    extension NSTableView {
        
        var allRowIndexes: NSIndexSet {
            return NSIndexSet(indexesInRange: NSRange(0..<numberOfRows))
        }
    }
    
#endif

// **************  LOCALIZATION  **************

func NSLocalizedString(string: String) -> String {
    return NSLocalizedString(string, comment: "")
}

// **************  PROTOCOLS  **************

/// Useful for table view cells.
///
/// When you implement the `configure(_:T)` method you can specify the parameter name you want. If there's no need for a parameter at all implement it like this: `func configure(_: Void) { ... }`.
protocol Configurable {
    associatedtype T
    func configure(_: T)
}
