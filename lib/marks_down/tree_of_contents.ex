defmodule MarksDown.TreeOfContents do
  @moduledoc """
  Maps the files to slugs links for the tree menu
  """
  alias MarksDown.Directories
  alias MarksDown.Directories.Slug

  @files_path "priv/notes"

  def build_menu_tree(path \\ @files_path) do
    children = get_children(path)

    Directories.map_menu_links(children).children["notes"]
  end

  defp get_children(path) do
    Enum.map(
      Directories.list_files(path),
      fn path ->
        case File.read(path) do
          {:ok, _data} ->
            file_name(path)
            build_slug(path)

          {:error, _} ->
            nil
        end
      end
    )
    |> Enum.reject(&is_nil/1)
  end

  defp file_name(path) do
    path
    |> String.split("/")
    |> Enum.take(-1)
    |> Enum.at(0)
  end

  defp build_slug(path) do
    %Slug{
      path: path,
      name: file_name(path) |> String.replace(".md", ".html"),
      file: file_name(path)
    }
  end
end
