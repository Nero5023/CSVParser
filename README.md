# CSVParser
A swift library for fast read and write CSV file. This library supports all Apple platform and **Linux**.

[![Build Status](https://travis-ci.org/Nero5023/CSVParser.svg?branch=master)](https://travis-ci.org/Nero5023/CSVParser)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Plafrom](https://img.shields.io/badge/platform-linux%20%7C%20ios%20%7C%20osx%20%7C%20tvos%20%7C%20watchos%20-lightgray.svg)](https://github.com/Nero5023/CSVParser)

## List to do
---
- [x] get column by string subscript
- [x] error
- [x] initialization from string
- [x] Convert JSON To CSV
- [x] Convert CSV To JSON
- [ ] Concurrent parse
## Requirements
---

* Swift 4.0+

## Installation
---
### Swift Package Manager(Support Ubuntu)
**If you want to use this package on Ubuntu, you shounld install with Swift Package Manager**

In `Package.swift` file

```swift
import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .Package(url: "https://github.com/Nero5023/CSVParser",
        majorVersion: 1),
    ]
)
```

Run command

```bash
$ swift build
```

### Carthage

To integrate CSVParser into your Xcode project using Carthage, specify it in your `Cartfile`:


	github "Nero5023/CSVParser" ~> 2.0.0

Run `carthage update` to build the framework and drag the built `CSVParser.framework` into your Xcode project.



## Usage

###  Initialization 

```swift
let csv = try CSVParser(filePath: "path/to/csvfile")

//catch error
do {
	let csv = try CSVParser(filePath: "path/to/csvfile")
}catch {
	// Error handing
}

// Custom delimiter
do {
	let csv = try CSVParser(filePath: "path/to/csvfile", delimiter: ";")
}catch {
	// Error handing
}

// init from elements
let csv = try CSVParser(elements: [["a", "b", "c"], ["1", "2", "3"]])
```

### Read data

```swift
do {
	let csv = try CSVParser(filePath: "path/to/csvfile")
	// get every row in csv
	for row in csv {
        print(row) // ["first column", "sceond column", "third column"]
    }
    
    // get row by int subscript 
    csv[10] // the No.10 row
    
    // get column by string subscript
    csv["id"] // column with header key "id" 
	
}catch {
	// Error handing
}

```

### Write data

```swift
do {
	let csv = try CSVParser(filePath: "path/to/csvfile")
	// get every row in csv
	csv[0] = ["test0", "test1", "test2"]
	csv.wirite(toFilePath: "path/to/destination/file")
	
}catch {
	// Error handing
}

```

### Subscript

```swift
// get row by int subscript 
csv[10] // the No.10 row
    
// get column by string subscript
csv["id"] // column with header key "id" 

```

### Get dictionary elements

```swift
for dic in csv.enumeratedWithDic() {
	print(dic) // dic is [String: String]	
}

```

### CSV to JSON
The result json type is `[{"header0": "a","header1": "b"},{"header0": "a", "header1": "b"}]`

```swift
do {
	let jsonStr = try csv.toJSON()
}catch {
	// Error handing
} 

```

### JSON to CSV string
Now only support this json type `[{"header0": "a","header1": "b"},{"header0": "a", "header1": "b"}]`


```swift
do {
	let csvString = try CSVParser.jsonToCSVString(jsonData: jsonData) // jsonData is the Data type ot json
}catch {
	// Error handing
} 

```