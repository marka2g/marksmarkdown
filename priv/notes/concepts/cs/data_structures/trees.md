%{
  title: "Looks' Like A Tree to Me",
  author: "Mark Sadegi",
  description: "Implementing Trees in Elixir",
  tags: ~w(elixir data_structures trees),
  date: "2023-05-19"
}
---

## Directories - Entry Point
```elixir
defmodule MarksDown.Directories do
  @moduledoc """
  Entry point
  """
  alias MarksDown.Directories.{Tree, Slug}

  @root_path "priv/"

  def list_files(path \\ "#{@root_path}/notes/") do
    cond do
      File.regular?(path) ->
        [path]

        true ->
          list = 
            Path.wildcard(
              Path.join(path, "/*")
            ) -- [@root_path]

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
  def add_child([], _slug, root), do: root

  # directory
  def add_child([parent | rest], slug, root) do
    tree =
      case Map.get(root.children, Path.basename(parent)) do
        nil ->
          %Tree{
            id: get_id_from_path(parent),
            name: get_name_from_path(parent),
            path: parent,
            slugs: get_slugs(parent, slug)
          }
        tree -> tree
      end
    tree = add_child(rest, slug, tree)
    %{
      root
      | children:
        Map.put(
          root.children,
          Path.basename(parent), tree)
    }
  end

  defp get_slugs(parent, slug) do
    dir_path = "#{@root_path}#{parent}"
    case parent == slug_parent(slug.path) do
      true ->
        File.ls!(dir_path)
        |> Enum.reduce_while([], fn entry, acc ->
          if entry |> String.contains?(".md") do
            {:cont, 
              acc ++ 
              [entry |> String.replace(".md", ".html")]
            }
          else
            {:halt, acc}
          end
        end)
      false -> []
    end

  end
  defp get_id_from_path(path), 
    do: path_list(path) |> Enum.join("-")
  
  defp get_name_from_path(path), 
  do: path_list(path) |> Enum.at(-1)

  defp path_list(path), do: path |> String.split("/")

  defp slug_parent(path) do
    path_list(path) 
    |> Enum.drop(1) 
    |> Enum.drop(-1) 
    |> Enum.join("/")
  end
end
```

### Slug
```elixir
defmodule MarksDown.Directories.Slug do
  defstruct name: nil, path: nil, file: nil
  @ignore_path "priv/"

  def parent_dirs(slug) do
    descend(from_docs_root(slug.path))
  end

  defp from_docs_root(slug_path) do
    slug_path
    |> String.split(@ignore_path)
    |> Enum.take(-1)
  end

  defp descend(path) do
    Path.split(path) |> Enum.drop(-1)
    |> Enum.reduce([], fn dir, results ->
      case List.last(results) do
        nil ->
          [dir]

        root ->
          if root == "/" do
            results ++ ["#{root}#{dir}"]
          else
            results ++ ["#{root}/#{dir}"]
          end
      end
    end)
  end
end
```

### Tree
```elixir
defmodule MarksDown.Directories.Tree do
  @moduledoc """
  A tree data structure that encapsulates 
  a directory in the file system
  """
  alias __MODULE__

  defstruct [:id, :name, :path, slugs: [], children: %{}]

  def traverse(root), do: traverse(root, 1)
  def traverse(
    %Tree{
      id: parent_id, 
      slugs: _slugs, 
      name: name, 
      children: children
      } = _tree, 
    depth) do
    collect_children(children, parent_id, depth)
  end

  def collect_children(children, _parent_id, parent_depth) do
    keys = Map.keys(children)
    for child_key <- keys do
      child = children[child_key]
      traverse(child, parent_depth + 1)
    end
  end
end
```