# CSVParser
A swift package for read and write CSV file

## List to do

- [ ] concurrent parse csv
- [ ] improve performance
- [ ] get column
- [ ] error
- [ ] initialization from string
## Usage

Initialization 

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

Read data

```swift
do {
	let csv = try CSVParser(filePath: "path/to/csvfile")
	// get every row in csv
	for row in csv {
        print(row) // ["first column", "sceond column", "third column"]
    }
	
}catch {
	// Error handing
}

```

Write data

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