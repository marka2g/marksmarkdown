defmodule MarksDown.TreeOfContents do
  @moduledoc """
  This module builds a menu structure based on a
  given path and a list of leaf slugs.
  """
  alias MarksDown.Directories
  alias MarksDown.Directories.{Tree, Slug}

  @root "priv/"
  @notes_dir "notes"

  @spec build_menu(String.t()) :: %Tree{}
  @doc """
  Builds a menu structure based on a given path and list of leaf slugs.

  This function takes a path and a list of leaf slugs as input and constructs a
  hierarchical menu structure. The menu is represented as a tree with nodes
  corresponding to directories and leaves corresponding to files.

  ## Parameters
  * `path` (optional) - The root path where the menu structure starts. If not provided,
    the default root path will be used, which combines the module's `@root` and `@notes_dir`
    attributes.

  ## Returns
  Returns a menu structure represented as a tree.

  ## Example

    iex> TreeOfContents.build_menu("/root/path", ["file1", "file2"])
      %Tree{
        children: %{
          "notes" => %Tree{
            children: %{
              "file1" => %Tree{},
              "file2" => %Tree{}
            }
          }
        }
      }

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
