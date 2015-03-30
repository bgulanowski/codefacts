//
//  main.swift
//  codefacts
//
//  Created by Brent Gulanowski on 2015-03-26.
//  Copyright (c) 2015 Shopify Inc. All rights reserved.
//

import Foundation

let defaultFolder = "/Users/brent/Dev/github/ios-point-of-sale/PointOfSale/PointOfSale"

let inportExtractRegex = NSRegularExpression(pattern: "import \"([\\w/+]+\\.h)\"", options: nil, error: nil)!

func getFullPath (basePath: String, filePath: String) -> String {
    return basePath + "/" + filePath
}

func getSource ( filePath: String ) -> String? {
    var error: NSErrorPointer = nil
    let string = NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: error)?
    // there must be a nicer way to safely print an optional error
    if string == nil {
        var errorInfo : Printable
        if (error == nil) {
            errorInfo = "unknown"
        }
        else {
            errorInfo = error.memory!
        }
        println("Unable to load source for file \(filePath); error: \(errorInfo).")
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

func getInputFolder () -> String {
    let arguments = NSProcessInfo.processInfo().arguments as Array
    if arguments.count >= 2 {
        if let argument = arguments[1] as? String {
            return argument
        }
    }
    return defaultFolder
}

func enumerateFiles ( folder: String ) -> Dictionary<String, FileFacts> {
    
    let inputPath = getInputFolder()
    let fileManager = NSFileManager.defaultManager()
    let directoryEnumerator = fileManager.enumeratorAtPath(folder)
    
    var fileIndex = [String : FileFacts]()

    while let filePath = directoryEnumerator?.nextObject() as? String {
        let isHeader = filePath.pathExtension == "h"
        if isHeader || filePath.pathExtension == "m" {
            if let source = getSource(getFullPath(inputPath, filePath))? {
                let headers = parseHeaderImports(source)
                for header in headers {
                    if let facts = fileIndex[header] {
                        facts.mentions++
                    }
                    else {
                        fileIndex[header] = FileFacts(name: header, type: FileFacts.FileType.Interface, imports: 0, mentions: 1)
                    }
                }
                if let fileName = filePath.pathComponents.last {
                    let type = isHeader ? FileFacts.FileType.Interface : FileFacts.FileType.Implementation
                    if fileIndex[fileName] == nil {
                        fileIndex[fileName] = FileFacts(name: fileName, type: type, imports: headers.count, mentions: 0)
                    }
                }
            }
        }
    }
    return fileIndex
}

/// - main program

let fileIndex = enumerateFiles(getInputFolder())

let sortedByName = fileIndex.values.array.sorted { $0.name < $1.name }
let sortedByImports = fileIndex.values.array.sorted { $0.imports > $1.imports }

let noMentions = sortedByName.filter { facts in
    return facts.name.hasPrefix("PS") && facts.mentions == 0 && facts.type == FileFacts.FileType.Interface
}

println("\nThe follow files have no imports that I could find:")

for fact in noMentions {
    println("\t" + fact.name)
}

let mostImports = sortedByImports[0..<20]

println("\nThe following files have a lot of imports:")

for fact in mostImports {
    println("\t"+fact.description)
}
