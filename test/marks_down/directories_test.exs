defmodule MarksDown.DirectoriesTest do
  use ExUnit.Case
  alias MarksDown.Directories

  describe "list_slug_files()" do
    test "does not contain empty directories" do
      empty_dir_path = "test/support/priv/notes/empty_dir/empty_child"
      slug_paths = Directories.list_slug_files("test/support/priv/notes")

      assert empty_dir_path not in slug_paths
    end
  end
end
