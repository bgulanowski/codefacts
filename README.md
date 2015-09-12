# codefacts
Simple tool for tabulating details on Objective-C import dependencies.

This tool is an exercise in Swift for examining Objective-C files. It traverses the file system looking for Objective-C header files. For each file, it counts the "#import" directives. Finally, it prints info about those that seem to have too many dependencies.
