defmodule CombineFoodSpreadsheetsTest do
  use ExUnit.Case
  doctest CombineFoodSpreadsheets

  @table_data [
    [nil, nil, "title", nil, nil, nil],
    ["Sample", "Duplicate", "Day", "Other 1", "Log", "Other 2"],
    ["Drunken Goat", 1, 0, 123, 3.21, 456],
    ["Drunken Goat", 2, 0, 123, 3.24, 456],
    ["Drunken Goat", 1, 1, 123, 7.65, 456],
    ["Drunken Goat", 2, 1, 123, 7.61, 456],
    [nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil],
    ["Sample", "Duplicate", "Day", "Other 1", "Log", "Other 2"],
    ["Soft Gouda", 1, 0, 123, 1.21, 456],
    ["Soft Gouda", 2, 0, 123, 1.24, 456],
    ["Soft Gouda", 1, 3, 123, 2.65, 456],
    ["Soft Gouda", 2, 3, 123, 2.61, 456],
    [nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil]
  ]

  test "Parse file into groups of cheese to data" do
    assert CombineFoodSpreadsheets.parse_table_data(@table_data) == [
             {"Drunken Goat", %{{0, 1} => 3.21, {0, 2} => 3.24, {1, 1} => 7.65, {1, 2} => 7.61}},
             {"Soft Gouda", %{{0, 1} => 1.21, {0, 2} => 1.24, {3, 1} => 2.65, {3, 2} => 2.61}}
           ]
  end

  @tag skip: "Not passing yet"
  test "Output multiples into a spreadsheet structure" do
    assert CombineFoodSpreadsheets.build_output(@table_data) |> Enum.take(3) == [
             ["Day", "Duplicate", "Drunken Goat", "Soft Gouda"],
             [0, 1, 3.21, 1.21],
             [0, 2, 3.24, 1.24]
             # TODO: Finish the rest
           ]
  end
end
