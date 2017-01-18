//
//  EventManager.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/31/16.
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
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    
    /// - returns: `true` if access was granted, `false` otherwise.
    static func requestAccessPermission(_ handler: @escaping (_ granted: Bool) -> ()) {
        EKEventStore().requestAccess(to: .event) { result, error in
            handler(result)
        }
    }
    
    
    /// Creates a new `EKEvent` object initialized with default information.
    static func createEvent(in eventStore: EKEventStore, for menu: DayMenu) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        let defaults = UserDefaults.standard
        
        // Title
        event.title = defaults.string(forKey: DefaultsEventTitleKey) ?? NSLocalizedString("Lunch")
        
        // Notes
        if PreferencesManager.includeMenuInEventsNotes {
            event.notes = NSLocalizedString("Menu") + ":\n" + menu.allDishes
        }
        
        // Date
        if let date = menu.processedDate {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.era, .year, .month, .day], from: date)
            
            components.hour = defaults.object(forKey: DefaultsEventStartHourKey) as? Int ?? 14
            components.minute = defaults.object(forKey: DefaultsEventStartMinuteKey) as? Int ?? 0
            event.startDate = calendar.date(from: components)!
            
            components.hour = defaults.object(forKey: DefaultsEventEndHourKey) as? Int ?? 15
            components.minute = defaults.object(forKey: DefaultsEventEndMinuteKey) as? Int ?? 0
            event.endDate = calendar.date(from: components)!
        }
        
        // Calendar
        if let calendarID = defaults.string(forKey: DefaultsEventCalendarIdentifierKey) {
            // (Can't use calendarWithIdentifier() here, it fails)
            for calendar in eventStore.calendars(for: .event) {
                if calendar.calendarIdentifier == calendarID {
                    event.calendar = calendar
                }
            }
        }
        
        // Location
        event.location = defaults.string(forKey: DefaultsEventLocationKey)
        
        // Alarms
        if PreferencesManager.useDefaultAlarmsForNewEvents {
            if let alarmOffset = defaults.object(forKey: DefaultsEventFirstAlarmKey) as? TimeInterval {
                event.addAlarm(EKAlarm(relativeOffset: alarmOffset))
            }
            if let alarmOffset = defaults.object(forKey: DefaultsEventSecondAlarmKey) as? TimeInterval {
                event.addAlarm(EKAlarm(relativeOffset: alarmOffset))
            }
        }
        
        return event
    }
    
    
    /// Saves the info contained in the passed event and uses it for initializing new `EKEvent` objects created with `createEvent(inEventStore:forMenu)`.
    static func saveDefaultInfo(from event: EKEvent) {
        let defaults = UserDefaults.standard
        let calendar = Calendar.current
        
        defaults.set(event.title, forKey: DefaultsEventTitleKey)
        
        if event.notes == nil || event.notes == "" {
            PreferencesManager.includeMenuInEventsNotes = false
        }
        
        let startDateComponents = calendar.dateComponents([.hour, .minute], from: event.startDate)
        defaults.set(startDateComponents.hour, forKey: DefaultsEventStartHourKey)
        defaults.set(startDateComponents.minute, forKey: DefaultsEventStartMinuteKey)
        
        let endDateComponents = calendar.dateComponents([.hour, .minute], from: event.endDate)
        defaults.set(endDateComponents.hour, forKey: DefaultsEventEndHourKey)
        defaults.set(endDateComponents.minute, forKey: DefaultsEventEndMinuteKey)
        
        defaults.set(event.calendar.calendarIdentifier, forKey: DefaultsEventCalendarIdentifierKey)
        
        defaults.set(event.location, forKey: DefaultsEventLocationKey)
        
        if PreferencesManager.useDefaultAlarmsForNewEvents {
            defaults.set(event.alarms?.first?.relativeOffset, forKey: DefaultsEventFirstAlarmKey)
            defaults.set(event.alarms?.second?.relativeOffset, forKey: DefaultsEventSecondAlarmKey)
        }
    }
}
