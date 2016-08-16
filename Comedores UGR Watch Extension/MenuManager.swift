//
//  MenuManager.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 4/3/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import Foundation
import WatchConnectivity


private let DefaultsWeekMenuKey = "DefaultsWeekMenuKey"
private let DefaultsLastDataUpdateKey = "DefaultsLastDataUpdateKey"


class MenuManager: NSObject, WCSessionDelegate {
    static let defaultManager = MenuManager()
    
    var savedMenu: [DayMenu]? {
//        return [DayMenu(date: "Marzo 28 Lunes", dishes: ["Arroz a la Cubana", "Filete de Cerdo a la Parrilla con Berenjenas Fritas", "Pan, Vino Tinto y Manzana"]),
//            DayMenu(date: "Marzo 29 Martes", dishes: ["Patatas a la Riojana", "Pez Espada a la Serrana con Judí­as y Zanahorias", "Pan, Vino Tinto y Flan de Huevo"]),
//            DayMenu(date: "Marzo 30 Miércoles", dishes: ["Sopa Fidelina / Salpicón de Gambas con Salsa de Coctel", "Plato Alpujarreño", "Pan, Vino Tinto y Naranja"]),
//            DayMenu(date: "Marzo 31 Jueves", dishes: ["Estofado de Lentejas", "Pechuga de Pollo Villeroy con Ensalada Mixta", "Pan, Refresco y Pera"]),
//            DayMenu(date: "Abril 1 Viernes", dishes: ["Crema de Calabacino", "Fricandó de Cerdo con Patatas a la Española", "Pan, Vino Tinto y Fresas"]),
//            DayMenu(date: "Abril 2 Sábado", dishes: ["Macarrones a la Crema con Bacalao", "Escalope de Ternera con Ensalada Loreto", "Pan, Vino Tinto y Surtido del Chef"]),
//            DayMenu(date: "Abril 3 Domingo", dishes: ["Guacamole y ensalada de totopos", "Echiladas y burritos de pollo", "Refresco, Vino y Postre Especial"])]
        return NSUserDefaults.standardUserDefaults().menuForKey(DefaultsWeekMenuKey)
    }
    
    private var session = WCSession.defaultSession()
    
    private override init() {
        super.init()
//        NSKeyedUnarchiver.setClass(DayMenu.self, forClassName: "Comedores_UGR.DayMenu")
//        NSKeyedArchiver.setClassName("Comedores_UGR.DayMenu", forClass: DayMenu.self)
    }

    
    var handler: ([DayMenu] -> ())?
    
    /// Calling this method will prevent handler closures from previous ongoing requests from being executed.
    /// - warning: The `handler` is not guaranteed to be called it there happens to be any issue.
    func requestMenu(responseHandler handler: [DayMenu] -> ()) {
        session.delegate = self
        session.activateSession()
        self.handler = handler
        session.sendMessage([:], replyHandler: nil, errorHandler: nil)
    }
    
    
    var hasUpdatedDataToday: Bool {
        if let date = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsLastDataUpdateKey) as? NSDate where NSCalendar.currentCalendar().isDateInToday(date) {
            return true
        }
        return false
    }
    
    
    // MARK: WCSessionDelegate

    func session(session: WCSession, didReceiveMessageData messageData: NSData) {
        if let menu = NSKeyedUnarchiver.unarchiveMenuWithData(messageData) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(NSDate(), forKey: DefaultsLastDataUpdateKey)
            defaults.setMenu(menu, forKey: DefaultsWeekMenuKey)
            handler?(menu)
        } else {
            print("Error: Bad data.")
        }
    }
}
