//
//  EventManager.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/31/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import EventKit


private let DefaultsEventTitleKey = "DefaultsEventTitleKey"
private let DefaultsEventStartHourKey = "DefaultsEventStartHourKey"
private let DefaultsEventStartMinuteKey = "DefaultsEventStartMinuteKey"
private let DefaultsEventEndHourKey = "DefaultsEventEndHourKey"
private let DefaultsEventEndMinuteKey = "DefaultsEventEndMinuteKey"
private let DefaultsEventCalendarIdentifierKey = "DefaultsEventCalendarIdentifierKey"
private let DefaultsEventLocationKey = "DefaultsEventLocationKey"
private let DefaultsEventFirstAlarmKey = "DefaultsEventFirstAlarmKey"
private let DefaultsEventSecondAlarmKey = "DefaultsEventSecondAlarmKey"


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
    
    
    /// Creates a new `EKEvent` object initialized with default information.
    static func createEvent(inEventStore eventStore: EKEventStore, forMenu menu: DayMenu) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Title
        event.title = defaults.stringForKey(DefaultsEventTitleKey) ?? NSLocalizedString("Lunch")
        
        // Notes
        if PreferencesManager.includeMenuInEventsNotes {
            event.notes = NSLocalizedString("Menu") + ":\n" + menu.allDishes
        }
        
        // Date
        if let date = menu.processedDate {
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Era, .Year, .Month, .Day], fromDate: date)

            
            components.hour = defaults.objectForKey(DefaultsEventStartHourKey) as? Int ?? 14
            components.minute = defaults.objectForKey(DefaultsEventStartMinuteKey) as? Int ?? 0
            event.startDate = calendar.dateFromComponents(components)!
            
            components.hour = defaults.objectForKey(DefaultsEventEndHourKey) as? Int ?? 15
            components.minute = defaults.objectForKey(DefaultsEventEndMinuteKey) as? Int ?? 0
            event.endDate = calendar.dateFromComponents(components)!
        }
        
        // Calendar
        if let calendarID = defaults.stringForKey(DefaultsEventCalendarIdentifierKey) {
            // (Can't use calendarWithIdentifier() here, it fails)
            for calendar in eventStore.calendarsForEntityType(.Event) {
                if calendar.calendarIdentifier == calendarID {
                    event.calendar = calendar
                }
            }
        }
        
        // Location
        event.location = defaults.stringForKey(DefaultsEventLocationKey)
        
        // Alarms
        if PreferencesManager.useDefaultAlarmsForNewEvents {
            if let alarmOffset = defaults.objectForKey(DefaultsEventFirstAlarmKey) as? NSTimeInterval {
                event.addAlarm(EKAlarm(relativeOffset: alarmOffset))
            }
            if let alarmOffset = defaults.objectForKey(DefaultsEventSecondAlarmKey) as? NSTimeInterval {
                event.addAlarm(EKAlarm(relativeOffset: alarmOffset))
            }
        }
        
        return event
    }
    
    
    /// Saves the info contained in the passed event and uses it for initializing new `EKEvent` objects created with `createEvent(inEventStore:forMenu)`.
    static func saveDefaultInfoFromEvent(event event: EKEvent) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let calendar = NSCalendar.currentCalendar()
        
        defaults.setObject(event.title, forKey: DefaultsEventTitleKey)
        
        if event.notes == nil || event.notes == "" {
            PreferencesManager.includeMenuInEventsNotes = false
        }
        
        let startDateComponents = calendar.components([.Hour, .Minute], fromDate: event.startDate)
        defaults.setInteger(startDateComponents.hour, forKey: DefaultsEventStartHourKey)
        defaults.setInteger(startDateComponents.minute, forKey: DefaultsEventStartMinuteKey)
        
        let endDateComponents = calendar.components([.Hour, .Minute], fromDate: event.endDate)
        defaults.setInteger(endDateComponents.hour, forKey: DefaultsEventEndHourKey)
        defaults.setInteger(endDateComponents.minute, forKey: DefaultsEventEndMinuteKey)
        
        defaults.setObject(event.calendar.calendarIdentifier, forKey: DefaultsEventCalendarIdentifierKey)
        
        defaults.setObject(event.location, forKey: DefaultsEventLocationKey)
        
        if PreferencesManager.useDefaultAlarmsForNewEvents {
            defaults.setObject(event.alarms?.first?.relativeOffset, forKey: DefaultsEventFirstAlarmKey)
            defaults.setObject(event.alarms?.second?.relativeOffset, forKey: DefaultsEventSecondAlarmKey)
        }
    }
}
