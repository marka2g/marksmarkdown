defmodule MarksDown.Directories.Slug do
  @moduledoc """
  Data structure that encapsulates
  a slug(.md) in the file system
  """
  alias __MODULE__

  defstruct name: nil, path: nil, file: nil, parent_dir: nil

  @ignore_path "priv/"

  def build(path) do
    %Slug{
      name: slug_name(path),
      file: file_name(path),
      parent_dir: parent_directory(path),
      path: path
    }
  end

  defp path_list(path) do
    path
    |> String.split("/")
  end

  defp slug_name(path) do
    path
    |> file_name()
    |> String.replace(".md", ".html")
  end

  defp file_name(path) do
    path
    |> path_list()
    |> Enum.take(-1)
    |> Enum.at(0)
  end

  defp parent_directory(path) do
    path
    |> path_list()
    |> Enum.drop(-1)
    |> Enum.join("/")
  end

  def parent_dirs(slug) do
    drop_down(from_docs_root(slug.path))
  end

  defp from_docs_root(slug_path) do
    slug_path
    |> String.split(@ignore_path)
    |> Enum.take(-1)
  end

  defp drop_down(path) do
    Path.split(path)
    |> Enum.drop(-1)
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
