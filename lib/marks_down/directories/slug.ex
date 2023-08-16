defmodule MarksDown.Directories.Slug do
  @moduledoc """
  This module contains the data structure for
  a slug(.md) in the file system.
  """
  defstruct name: nil, path: nil, file: nil, parent_dir: nil

  alias __MODULE__
  @ignore_path "priv/"

  @type t :: %__MODULE__{
          name: String.t(),
          file: String.t(),
          parent_dir: String.t(),
          path: String.t()
        }

  @spec build(String.t()) :: Slug.t()
  @doc """
    Builds a Slug struct based on the provided path.

    This function takes a path and constructs a Slug struct with various attributes extracted from the path. The Slug struct contains information about the name, file, parent directory, and the full path.

    ## Parameters
    * `path` - The path from which to construct the Slug struct.

    ## Returns
    A Slug struct containing the extracted attributes.

    ## Example
        iex> Slug.build("/root/path/to/file.txt")
        %Slug{
          name: "file",
          file: "file.txt",
          parent_dir: "to",
          path: "/root/path/to/file.txt"
        }
  """
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
