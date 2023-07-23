defmodule MarksDown.TreeOfContents do
  @moduledoc """
  Builds the tree menu structure
  """
  alias MarksDown.Directories
  alias MarksDown.Directories.{Tree, Slug}

  @root "priv/"
  @notes_dir "notes"

  @doc """
    The entry point build function
    Given a path as a parameter, sort top level
    leaf_slugs by name and then,
    starting with empty tree,
    Enum.reduce to map the directories.
  """
  def build_menu(path \\ "#{@root}#{@notes_dir}") do
    leaves = leaf_slugs(path)

    Enum.reduce(leaves, %Tree{}, fn leaf, root ->
      add_leaf(Slug.parent_dirs(leaf), leaf, root)
    end).children[@notes_dir]
  end

  defp leaf_slugs(path) do
    Enum.map(
      Directories.list_slug_files(path),
      fn path ->
        case File.read(path) do
          {:ok, _data} ->
            file_name(path)
            Slug.build(path)

          {:error, _} ->
            nil
        end
      end
    )
    |> Enum.reject(&is_nil/1)
    |> Enum.sort_by(& &1.path, :desc)
  end

  defp file_name(path) do
    path
    |> String.split("/")
    |> Enum.take(-1)
    |> Enum.at(0)
  end

  # slug
  defp add_leaf([], _slug, root), do: root

  # directory
  defp add_leaf([parent | rest], leaf, root) do
    tree =
      case Map.get(root.children, Path.basename(parent)) do
        nil ->
          %Tree{
            id: get_id_from_path(parent),
            name: get_name_from_path(parent),
            path: parent,
            slugs: get_slugs_in_dir(parent, leaf)
          }

        tree ->
          tree
      end

    tree = add_leaf(rest, leaf, tree)

    %{
      root
      | children:
          Map.put(
            root.children,
            Path.basename(parent),
            tree
          )
    }
  end

  defp get_slugs_in_dir(parent, leaf) do
    dir_path = "#{@root}#{parent}/"

    case parent == slug_parent(leaf.path) do
      true ->
        File.ls!(dir_path)
        |> Enum.filter(&String.contains?(&1, ".md"))
        |> Enum.reduce_while([], fn entry, acc ->
          if entry |> String.contains?(".md") do
            {:cont, acc ++ [entry |> String.replace(".md", ".html")]}
          else
            {:halt, acc}
          end
        end)

      false ->
        []
    end
  end

  defp get_id_from_path(path), do: path_list(path) |> Enum.join("-")
  defp get_name_from_path(path), do: path_list(path) |> Enum.at(-1)
  defp path_list(path), do: path |> String.split("/")
  defp slug_parent(path), do: path_list(path) |> Enum.drop(1) |> Enum.drop(-1) |> Enum.join("/")
end
