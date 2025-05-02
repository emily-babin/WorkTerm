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
    
    // All Attributes
    init(desc: String, name: String, priority: Bool, tag: String) {
        self.desc = desc
        self.name = name
        self.priority = priority
        self.tag = tag
    }
    
    // No Attributes
    init() {
        self.desc = ""
        self.name = ""
        self.priority = false
        self.tag = ""
    }
    
    // Just Description
    init (desc : String) {
        self.desc = desc
        self.name = ""
        self.priority = false
        self.tag = ""
    }
}

