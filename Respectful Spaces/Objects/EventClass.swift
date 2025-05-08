//
//  EventClass.swift
//  Respectful Spaces
//
//  Created by Babin,Emily on 2025-05-02.
//

class Event {
    // Attributes
    var desc : String
    var name : String
    var priority : Bool
    var tag : String
    var day : Int
    var month : Int
    var year : Int
    
    // All Attributes
    init(desc: String, name: String, priority: Bool, tag: String, day : Int, month : Int, year : Int) {
        self.desc = desc
        self.name = name
        self.priority = priority
        self.tag = tag
        self.day = day
        self.month = month
        self.year = year
    }
    
    // No Attributes
    init() {
        self.desc = ""
        self.name = ""
        self.priority = false
        self.tag = ""
        self.day = 0
        self.month = 0
        self.year = 0
    }
    
    // Just Description
    init (desc : String) {
        self.desc = desc
        self.name = ""
        self.priority = false
        self.tag = ""
        self.day = 0
        self.month = 0
        self.year = 0
    }
    
    // Day Month Name
    init (day : Int, month : Int, name: String) {
        self.desc = ""
        self.name = name
        self.priority = false
        self.tag = ""
        self.day = day
        self.month = month
        self.year = 0
    }
    
    // Day Month Year Name
    init (day : Int, month : Int, year : Int, name: String) {
        self.desc = ""
        self.name = name
        self.priority = false
        self.tag = ""
        self.day = day
        self.month = month
        self.year = year
    }
    
    
    
}

