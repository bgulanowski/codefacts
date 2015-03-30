//
//  FileFacts.swift
//  codefacts
//
//  Created by Brent Gulanowski on 2015-03-26.
//  Copyright (c) 2015 Shopify Inc. All rights reserved.
//

import Cocoa

class FileFacts : Printable {
    
    enum FileType {
        case Interface
        case Implementation
    }
    
    var name = ""
    var type : FileType
    var imports = 0
    var mentions = 0
    
    init(name: String, type: FileType, imports: Int, mentions: Int) {
        self.name = name
        self.type = type
        self.imports = imports
        self.mentions = mentions
    }
    convenience init(name: String, type: FileType, imports: Int) {
        self.init(name: name, type: type, imports: imports, mentions: 0)
    }
    convenience init(name: String, type: FileType) {
        self.init(name: name, type: type, imports: 0)
    }
    
    func toString () -> String {
        var string = "\(name): \(imports) imports"
        if type == FileType.Interface {
            string+=", \(mentions) mentions"
        }
        return string
    }
    
    var description : String {
        return self.toString()
    }
}
