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
      name: file_name(path) |> String.replace(".md", ".html"),
      file: file_name(path),
      parent_dir: path |> String.split("/") |> Enum.drop(-1) |> Enum.join("/"),
      path: path
    }
  end

  defp file_name(path) do
    path
    |> String.split("/")
    |> Enum.take(-1)
    |> Enum.at(0)
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
