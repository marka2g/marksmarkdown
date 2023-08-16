defmodule MarksDown.Directories do
  @moduledoc """
  Maps the directories and it's files from the file system given a path
  """

  @root_path "priv/notes"

  @type root_path :: String.t()
  @type path :: String.t()

  @spec list_slug_files(path()) :: [String.t()]
  @doc """
  Lists slug files based on the provided path.
  This function takes a path and recursively lists files with slug names under the given path. Slug files are markdown files with a .md extension.

  ## Parameters
  * `path` (optional) - The path from which to start listing slug files. If not provided,the default root path will be used as defined by `@root_path`.

  ## Returns
  Returns a list of paths to slug files found under the given path.

  ## Example
      iex> Directories.list_slug_files("/root/path")
      ["/root/path/file1.txt", "/root/path/dir/file2.txt"]

  """
  def list_slug_files(path \\ @root_path) do
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
end
