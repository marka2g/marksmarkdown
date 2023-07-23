defmodule MarksDown.Directories do
  @moduledoc """
  Maps the directories and it's files from the file system
  """

  @root_path "priv/notes"

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
