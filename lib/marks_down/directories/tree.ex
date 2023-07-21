defmodule MarksDown.Directories.Tree do
  @moduledoc """
  A tree data structure that encapsulates a directory in the file system
  """
  alias __MODULE__

  defstruct [:id, :name, :path, slugs: [], children: %{}]

  def traverse(root), do: traverse(root, 1)

  def traverse(
        %Tree{id: parent_id, slugs: _slugs, name: _name, children: children} = _tree,
        depth
      ) do
    collect_children(children, parent_id, depth)
  end

  def collect_children(children, _parent_id, parent_depth) do
    keys = Map.keys(children)

    for child_key <- keys do
      child = children[child_key]
      traverse(child, parent_depth + 1)
    end
  end
end
