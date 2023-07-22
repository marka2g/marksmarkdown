defmodule MarksDown.Contents do
  @moduledoc """
  The API entry point, responsible for manipulating and retrieving a %Note{}
  """
  alias MarksDown.Contents.Note
  alias MarksDown.TreeOfContents

  @doc """
  build: used for obtaining the %Note{}
  as: names the module attribute that holds the list of Notes
  """
  use NimblePublisher,
    build: Note,
    from: Application.app_dir(:marks_down, "priv/notes/**/*.md"),
    as: :notes,
    highlighters: [
      :makeup_elixir,
      :makeup_erlang,
      :makeup_heex,
      :makeup_html,
      :makeup_json,
      :makeup_diff
    ]

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  @notes Enum.sort_by(@notes, &Date.from_iso8601!(&1.date), {:desc, Date})
  @tags @notes |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()
  @tree_of_contents TreeOfContents.build_menu()

  def all_notes, do: @notes
  def all_tags, do: @tags
  def tree_of_contents, do: @tree_of_contents

  def get_note_by_slug!(slug) do
    Enum.find(all_notes(), &(&1.slug == slug)) ||
      raise NotFoundError, "Note with slug=#{slug} not found"
  end

  def get_notes_by_tag!(tag) do
    case Enum.filter(all_notes(), &(tag in &1.tags)) do
      [] -> raise NotFoundError, "notes with tag=#{tag} not found"
      notes -> notes
    end
  end

  def get_notes_by_year!(year) do
    Enum.find(all_notes(), &(&1.year == year)) ||
      raise NotFoundError, "Note with year=#{year} not found"
  end
end
