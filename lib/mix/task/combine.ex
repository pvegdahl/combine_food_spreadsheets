defmodule Mix.Tasks.Combine do
  @moduledoc """
  Combine food sample spreadsheets into a single summary sheet.  There are some major assumptions about the specific
  format of the input data.  If those assumptions are not met, this command will almost certainly crash.
  """
  use Mix.Task

  @requirements ["app.start"]

  @shortdoc "Combine the given list of spreadsheets"
  def run(files) do
    output_filename = output_file()
    CombineFoodSpreadsheets.combine(files, output_filename)

    IO.puts(output_filename)
  end

  defp output_file() do
    datetime_string =
      DateTime.utc_now()
      |> DateTime.to_string()
      |> String.replace(" ", "_")

    "log_data_#{datetime_string}.xlsx"
  end
end
