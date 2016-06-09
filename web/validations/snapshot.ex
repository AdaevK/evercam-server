defmodule EvercamMedia.Validation.Snapshot do
  def validate_params(:day, year, month, day) do
    with :ok <- validate(:year, year),
         :ok <- validate(:month, month),
         :ok <- validate(:day, day),
         :ok <- validate(:date, year, month, day),
         do: :ok
  end

  defp validate(:date, year, month, day) do
    month = String.rjust(month, 2, ?0)
    day = String.rjust(day, 2, ?0)

    case Calendar.Date.Parse.iso8601("#{year}-#{month}-#{day}") do
      {:ok, _} -> :ok
      _ -> {:invalid, "The date provided isn't valid"}
    end
  end

  defp validate(key, value) when value in [nil, ""], do: invalid(key)
  defp validate(key, value) when is_bitstring(value), do: validate(key, to_integer(value))

  defp validate(:year, value) when is_integer(value), do: :ok
  defp validate(:year = key, _value), do: invalid(key)

  defp validate(:month, value) when is_integer(value) and value >= 1 and value <= 12, do: :ok
  defp validate(:month = key, _value), do: invalid(key)

  defp validate(:day, value) when is_integer(value) and value >= 1 and value <= 31, do: :ok
  defp validate(:day = key, _value), do: invalid(key)

  defp invalid(key), do: {:invalid, "The parameter '#{key}' isn't valid."}

  defp to_integer(value) do
    case Integer.parse(value) do
      {number, ""} -> number
      _ -> :error
    end
  end
end
