defmodule MarksDown.Directories.Tree do
  @moduledoc """
  A tree data structure that encapsulates a directory in the file system
  """
  defstruct [:id, :name, :path, slugs: [], children: %{}]
end
