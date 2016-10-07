# CSVParser
A swift package for read and write CSV file

## List to do

- [ ] concurrent parse csv
- [ ] improve performance by uing uft16 view to parse
- [x] get column by string subscript
- [ ] error
- [x] initialization from string

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

### subscript

```swift
// get row by int subscript 
csv[10] // the No.10 row
    
// get column by string subscript
csv["id"] // column with header key "id" 

```

### get dictionary elements

```swift
for dic in csv.enumeratedWithDic() {
	print(dic) // dic is [String: String]	
}

```
