//
//  EventManager.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/31/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import EventKit


let DefaultsEventTitleKey = "DefaultsEventTitleKey"


struct EventManager {
    
    static var authorizationStatus: EKAuthorizationStatus {
        return EKEventStore.authorizationStatusForEntityType(.Event)
    }
    
    
    /// - returns: `true` if access was granted, `false` otherwise.
    static func requestAccessPermission(handler: (granted: Bool) -> ()) {
        EKEventStore().requestAccessToEntityType(.Event) { result, error in
            handler(granted: result)
        }
    }
    
    
    static func createEvent(inEventStore eventStore: EKEventStore, forMenu menu: DayMenu) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        
//        event.title = NSUserDefaults.standardUserDefaults().stringForKey(DefaultsEventTitleKey) ?? NSLocalizedString("Lunch")
//        
//        if let date = menu.processedDate {
//            event.startDate =
//            event.endDate =
//            event.calendar =
//            event.title =
//            event.location =
//            event.notes =
//        }
        return event
    }
}