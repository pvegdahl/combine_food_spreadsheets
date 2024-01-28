# CombineFoodSpreadsheets

A quick little command line app that I made to help my wife crunch a bunch of work spreadsheets into a single summary.
It isn't particularly robust.  If an spreadsheet isn't formatted in the expected way, then this will crash.

## Installation

```
mix deps.get
mix compile
```

## Usage

You must use it from the root directory of the project.  i.e. combine_food_spreadsheets/.

```
mix combine file1.xlsx file2.xlsx ...
```
