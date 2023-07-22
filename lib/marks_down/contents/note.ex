defmodule MarksDown.Contents.Note do
  @moduledoc """
  The datastructure for an individual Note
  """
  @enforce_keys [
    :slug,
    :author,
    :title,
    :body,
    :description,
    :tags,
    :date,
    :filename,
    :full_path,
    :year
  ]
  defstruct [
    :slug,
    :author,
    :title,
    :body,
    :description,
    :tags,
    :date,
    :filename,
    :full_path,
    :year
  ]

  @doc """
  # takes:
    full_path: path and .md file,
    attrs: map that comes from the top of the md file
    body: of the md content and

    returns a %Note{}
  """
  def build(full_path, attrs, body) do
    {year, date} = parse_date(attrs.date)
    filename = get_filename(full_path)

    struct!(
      __MODULE__,
      [
        slug: get_slug(filename),
        date: date,
        year: year,
        body: body,
        filename: filename,
        full_path: full_path,
        tags: attrs.tags
      ] ++ Map.to_list(attrs)
    )
  end

  defp get_slug(filename), do: "#{Path.rootname(filename)}.html"

  defp parse_date(date) do
    date = Date.from_iso8601!(date)
    {year, _} = date |> Date.year_of_era()
    {year, date}
  end

  defp get_filename(full_path) do
    get_path(full_path)
    |> String.split("/")
    |> Enum.take(-1)
    |> Enum.at(0)
  end

  defp get_path(full_path) do
    full_path
    |> String.split("priv/")
    |> Enum.take(-1)
    |> Enum.at(0)
  end
end
