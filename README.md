# CSVParser
A swift package for read and write CSV file

## List to do
---
- [ ] concurrent parse csv
- [ ] improve performance by uing uft16 view to parse
- [x] get column by string subscript
- [x] error
- [x] initialization from string
- [ ] Convert JSON To CSV
- [x] Convert CSV To JSON

## Requirements
---

* Swift 3.0+

## Installation
---
### Swift Package Manager
In `Package.swift` file

```swift
import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .Package(url: "https://github.com/Nero5023/CSVParser",
        majorVersion: 0, minor: 1),
    ]
)
```

Run command

```bash
$ swift build
```

### Carthage

To integrate CSVParser into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Nero5023/CSVParser" ~> 0.2
```

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

// Cuestom delimiter
do {
	let csv = try CSVParser(filePath: "path/to/csvfile", delimiter: ";")
}catch {
	// Error handing
}
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
