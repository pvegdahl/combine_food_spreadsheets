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

  def parse_table_data(table_data) do
    table_data
    |> Enum.reject(&list_starts_with_nil_or_empty?/1)
    |> Enum.chunk_by(&List.first/1)
    |> Enum.chunk_every(2)
    |> Enum.map(&parse_one_sample/1)
  end

  defp list_starts_with_nil_or_empty?([nil | _]), do: true
  defp list_starts_with_nil_or_empty?([]), do: true
  defp list_starts_with_nil_or_empty?(_), do: false

  defp parse_one_sample([[header], rows]) do
    header_indices = find_header_indices(header)
    name = sample_name(rows)

    {name, parse_rows(rows, header_indices)}
  end

  defp find_header_indices(["Sample" | _] = header) do
    day_index = Enum.find_index(header, &(&1 == "Day"))
    duplicate_index = Enum.find_index(header, &(&1 == "Duplicate"))
    log_index = Enum.find_index(header, &(&1 == "Log"))

    [day: day_index, duplicate: duplicate_index, log: log_index]
  end

  defp sample_name([[name | _] | _] = _rows), do: name

  defp parse_rows(rows, header_indices) do
    Enum.map(rows, &parse_row(&1, header_indices))
  end

  defp parse_row(row, day: day_index, duplicate: duplicate_index, log: log_index) do
    {Enum.at(row, day_index), Enum.at(row, duplicate_index), Enum.at(row, log_index)}
  end
end
