defmodule Pillar.Util do
  @moduledoc false

  def has_input_format_json_read_numbers_as_strings?(%Version{} = version) do
    cond do
      Version.compare(version, "23.0.0") != :lt -> true
      :otherwise -> false
    end
  end
end
