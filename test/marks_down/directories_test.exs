defmodule MarksDown.DirectoriesTest do
  use ExUnit.Case

  alias MarksDown.Directories

  test "listing slug files from root path" do
    expected_files = [
      "priv/notes/concepts/cs/languages/elixir/features/tree-of-contents.md",
      "priv/notes/concepts/cs/languages/elixir/tips/enum.md",
      "priv/notes/concepts/cs/languages/elixir/tips/elixir-tips.md",
      "priv/notes/concepts/cs/languages/elixir/memory.md",
      "priv/notes/elevator-pitch.md"
    ]

    assert Directories.list_slug_files() == expected_files
  end

  test "listing slug files from a specific path" do
    expected_files = [
      "test/support/priv/notes/concepts/cs/languages/elixir/features/tree-of-contents.md"
    ]

    assert Directories.list_slug_files(
             "test/support/priv/notes/concepts/cs/languages/elixir/features"
           ) == expected_files
  end

  test "listing non-existent path should return an empty list" do
    assert Directories.list_slug_files("test/support/priv/notes/empty_dir/empty_child") == []
  end
end
