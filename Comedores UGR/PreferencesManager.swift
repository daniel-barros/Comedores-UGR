//
//  PreferencesManager.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 4/1/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import Foundation


private let DefaultsEventIncludesNotesKey = "DefaultsEventIncludesNotesKey"

enum PreferencesManager {
    
    static var includeMenuInEventsNotes: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(DefaultsEventIncludesNotesKey) as? Bool ?? true
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: DefaultsEventIncludesNotesKey)
        }
    }
}