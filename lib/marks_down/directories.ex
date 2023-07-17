defmodule MarksDown.Directories do
  @moduledoc """
  Entry point
  """
  alias MarksDown.Directories.{Tree, Slug}

  @root_path "priv/"
  @notes_path "notes/"

  def list_files(path \\ "#{@root_path}#{@notes_path}") do
    cond do
      File.regular?(path) ->
        [path]

      true ->
        list = Path.wildcard(Path.join(path, "/*")) -- [@root_path]

        Enum.map(list, fn path -> ls_regular(path) end)
        |> List.flatten()
    end
  end

  defp ls_regular(path) do
    cond do
      File.regular?(path) ->
        [path]

      File.dir?(path) ->
        File.ls!(path)
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(&ls_regular/1)
        |> Enum.concat()

      true ->
        []
    end
  end

  @doc """
   first, sort top level children given as
   parameter by name and then Enum.reduce
   to build the directories starting with empty tree.
  """
  def build(children) do
    children = Enum.sort_by(children, & &1.path, :desc)

    Enum.reduce(children, %Tree{}, fn child, root ->
      add_child(Slug.parent_dirs(child), child, root)
    end)
  end

  # slug
  defp add_child([], _slug, root), do: root

  # directory
  defp add_child([parent | rest], slug, root) do
    tree =
      case Map.get(root.children, Path.basename(parent)) do
        nil ->
          %Tree{
            id: get_id_from_path(parent),
            name: get_name_from_path(parent),
            path: parent,
            slugs: get_slugs(parent, slug)
          }

        tree ->
          tree
      end

    tree = add_child(rest, slug, tree)

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

  defp get_slugs(parent, slug) do
    dir_path = "#{@root_path}#{parent}"

    case parent == slug_parent(slug.path) do
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
