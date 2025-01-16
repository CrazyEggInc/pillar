defmodule Pillar.TypeConvert.ToClickhouse do
  @moduledoc false

  # to simplify IP matching
  defguardp is_in_range(val, start, fin) when is_integer(val) and val >= start and val <= fin

  def convert(param) when is_list(param) do
    if Keyword.keyword?(param) and not Enum.empty?(param) do
      values = Enum.map_join(param, ",", fn {k, v} -> "'#{to_string(k)}':#{convert(v)}" end)
      "{#{values}}"
    else
      values = Enum.map_join(param, ",", &convert/1)

      "[#{values}]"
    end
  end

  def convert(nil), do: "NULL"
  def convert(param) when is_integer(param), do: Integer.to_string(param)
  def convert(true), do: "1"
  def convert(false), do: "0"
  def convert(param) when is_atom(param), do: Atom.to_string(param)
  def convert(param) when is_float(param), do: Float.to_string(param)

  def convert(%DateTime{} = datetime) do
    datetime
    |> DateTime.truncate(:second)
    |> DateTime.to_iso8601()
    |> String.replace("Z", "")
    |> convert()
  end

  def convert(%Date{} = date) do
    date
    |> Date.to_iso8601()
    |> convert()
  end

  def convert(param) when is_map(param) do
    json = JSON.encode!(param)
    convert(json)
  end

  def convert({a, b, c, d} = ip)
      when is_in_range(a, 0, 255) and is_in_range(b, 0, 255) and
             is_in_range(c, 0, 255) and is_in_range(d, 0, 255) do
    ip
    |> :inet.ntoa()
    |> to_string
    |> convert
  end

  def convert({a, b, c, d, e, f, g, h} = ip)
      when is_in_range(a, 0, 65_535) and is_in_range(b, 0, 65_535) and is_in_range(c, 0, 65_535) and
             is_in_range(d, 0, 65_535) and is_in_range(e, 0, 65_535) and is_in_range(f, 0, 65_535) and
             is_in_range(g, 0, 65_535) and is_in_range(h, 0, 65_535) do
    ip
    |> :inet.ntoa()
    |> to_string
    |> convert
  end

  def convert(param) do
    single_quotes_escaped = String.replace(param, "'", "''")

    ~s('#{single_quotes_escaped}')
  end
end
