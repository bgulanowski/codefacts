//
//  FileFacts.swift
//  codefacts
//
//  Created by Brent Gulanowski on 2015-03-26.
//  Copyright (c) 2015 Shopify Inc. All rights reserved.
//

import Cocoa

class FileFacts : Printable {
    
    var name = ""
    var imports = 0
    var mentions = 0
    
    init(name: String, imports: Int, mentions: Int) {
        self.name = name
        self.imports = imports
        self.mentions = mentions
    }
    convenience init(name: String, imports: Int) {
        self.init(name: name, imports: imports, mentions: 0)
    }
    convenience init(name: String) {
        self.init(name: name, imports: 0)
    }
    
    func toString () -> String {
        return "FileFacts \(name): \(mentions)"
    }
    
    var description : String {
        return self.toString()
    }
}
