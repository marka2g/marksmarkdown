defmodule MarksDown.DirectoriesTest do
  use ExUnit.Case
  alias MarksDown.Directories

  describe "without slug files" do
    test "do not appear in the tree menu" do
      directories_list = [
        "notes",
        "empty_dir",
        "concepts",
        "cs",
        "languages",
        "elixir",
        "features",
        "idioms"
      ]

      refute directories_list == parent_dirs_list("test/support/priv/notes")
    end
  end

  def parent_dirs_list(path) do
    Enum.map(
      Directories.list_files(path),
      fn path ->
        case File.read(path) do
          {:ok, _data} ->
            path
            |> String.split("priv/", parts: 2)
            |> Enum.at(1)
            |> String.split("/")
            |> Enum.drop(-1)

          {:error, _} ->
            nil
        end
      end
    )
    |> Enum.uniq()
    |> Enum.flat_map(& &1)
    |> Enum.uniq()
  end
end
