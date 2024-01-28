defmodule CombineFoodSpreadsheets do
  def combine(files, output_file) do
    files
    |> Enum.flat_map(&read_data_sheet/1)
    |> build_output()
    |> multi_dim_array_to_xlsx(output_file)
  end

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

  def build_output(table_data) do
    table_data
    |> parse_table_data()
    |> output_format()
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
    |> Map.new()
  end

  defp parse_row(row, day: day_index, duplicate: duplicate_index, log: log_index) do
    {{Enum.at(row, day_index), Enum.at(row, duplicate_index)}, Enum.at(row, log_index)}
  end

  defp output_format(sample_data) do
    header = output_header(sample_data)

    output_rows =
      sorted_day_duplicates(sample_data)
      |> Enum.map(fn day_dup_pair -> output_row(day_dup_pair, sample_data) end)

    [header | output_rows]
  end

  defp output_header(sample_data), do: ["Day", "Duplicate"] ++ Enum.map(sample_data, &elem(&1, 0))

  defp sorted_day_duplicates(sample_data) do
    sample_data
    |> Enum.flat_map(fn {_name, data} -> Map.keys(data) end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp output_row({day, duplicate} = day_dup_pair, sample_data) do
    [day, duplicate] ++ Enum.map(sample_data, fn {_name, data} -> Map.get(data, day_dup_pair) end)
  end

  defp multi_dim_array_to_xlsx(mda, output_file) do
    sheet =
      mda
      |> mda_to_index_map()
      |> Enum.reduce(Elixlsx.Sheet.with_name("Log Data"), &set_cell/2)

    Elixlsx.Workbook.append_sheet(%Elixlsx.Workbook{}, sheet)
    |> Elixlsx.write_to(output_file)
  end

  def mda_to_index_map(mda) do
    for {row, r_index} <- Enum.with_index(mda), {cell_value, c_index} <- Enum.with_index(row), into: %{} do
      {{r_index, c_index}, cell_value}
    end
  end

  defp set_cell({{r_index, c_index}, cell_value}, sheet) do
    Elixlsx.Sheet.set_at(sheet, r_index, c_index, cell_value)
  end
end
