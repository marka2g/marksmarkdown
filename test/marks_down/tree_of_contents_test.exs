defmodule MarksDown.TreeOfContentsTest do
  use ExUnit.Case
  alias MarksDown.TreeOfContents
  # alias MarksDown.TreeFixtures

  describe "build_menu()" do
    test "has the correct shape and data" do
      import MarksDown.TreeFixtures

      path = "test/support/priv/notes"
      built_menu = TreeOfContents.build_menu(path)

      assert built_menu == tree_menu()
    end
  end
end
