//
//  main.swift
//  codefacts
//
//  Created by Brent Gulanowski on 2015-03-26.
//  Copyright (c) 2015 Shopify Inc. All rights reserved.
//

import Foundation

let defaultFolder = "/Users/brent/Dev/github/ios-point-of-sale/PointOfSale/PointOfSale/Controllers"

let inportExtractRegex = NSRegularExpression(pattern: "import \"([\\w/+]+\\.h)\"", options: nil, error: nil)!

func getSource ( filePath: String ) -> String? {
    let fullPath = defaultFolder+"/"+filePath
    var string: String!
    if let handle = NSFileHandle(forReadingAtPath: fullPath)? {
        let data = handle.readDataToEndOfFile()
        handle.closeFile()
        string = NSString(data: data, encoding: NSUTF8StringEncoding)
    }
    if string == nil || countElements(string!) == 0 {
        println("Could not read file at path '\(filePath)'")
    }
    
    return string
}

func StringRangeWithNSRange (string: String, range: NSRange) -> Range<String.Index> {
    let start = advance(string.startIndex, range.location)
    let end = advance(start, range.length)
    return Range(start: start, end: end)
}

func headerFileName (string: String ) -> String {
    let stringRange = NSMakeRange(0, countElements(string))
    if let result = inportExtractRegex.firstMatchInString(string, options: nil, range: stringRange) {
        return string.substringWithRange(StringRangeWithNSRange(string, result.rangeAtIndex(1)))
    }
    else {
        return ""
    }
}

func parseHeaderImports ( source: String ) -> Array<String> {
    let lines = source.componentsSeparatedByString("\n")
    let imports = lines.map {
        (string: String) -> String in
        return countElements(string) > 0 ? headerFileName(string) : ""
    }
    return imports.filter {
        return countElements($0) > 0
    }
}

func getFolder () -> String {
    let arguments = NSProcessInfo.processInfo().arguments as Array
    if arguments.count >= 2 {
        if let argument = arguments[1] as? String {
            return argument
        }
    }
    return defaultFolder
}

func enumerateFiles ( folder: String ) -> Dictionary<String, FileFacts> {
    
    let fileManager = NSFileManager.defaultManager()
    let directoryEnumerator = fileManager.enumeratorAtPath(folder)
    
    var fileIndex = [String : FileFacts]()

    while let filePath = directoryEnumerator?.nextObject() as? String {
        let isHeader = filePath.hasSuffix("h")
        if isHeader || filePath.hasSuffix("m") {
            if let source = getSource(filePath) {
                let headers = parseHeaderImports(source)
                for header in headers {
                    if let facts = fileIndex[header] {
                        facts.mentions++;
                    }
                    else {
                        fileIndex[header] = FileFacts(name: header, imports:headers.count, mentions: isHeader ? 0 : 1)
                    }
                }
            }
        }
    }
    return fileIndex
}

/// - main program

let fileIndex = enumerateFiles(getFolder())

let sorted = fileIndex.values.array.sorted { (first, second) -> Bool in
    return first.name < second.name
}

let candidates = sorted.filter { (facts) -> Bool in
    return facts.name.hasPrefix("PS") && facts.mentions == 0
}

for fact in candidates {
    println(fact)
}
