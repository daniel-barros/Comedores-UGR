//
//  GlobalFunctions.swift
//
//  Created by Daniel Barros López on 1/16/16.
//  Copyright © 2016 Daniel Barros López. All rights reserved.
//

import Foundation

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
