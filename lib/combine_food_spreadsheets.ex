defmodule CombineFoodSpreadsheets do
  defp read_data_sheet(path) do
    tables =
      Xlsxir.multi_extract(path)
      |> Enum.map(fn {:ok, table_id} -> table_id end)

    index = data_table_index(tables)

    tables
    |> Enum.at(index)
    |> Xlsxir.get_list()
  end

  defp data_table_index(tables) do
    tables
    |> Enum.map(&Xlsxir.get_info/1)
    |> Enum.map(&Keyword.get(&1, :name))
    |> Enum.find_index(&(&1 == "Data"))
  end
end
