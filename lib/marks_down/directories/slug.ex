defmodule MarksDown.Directories.Slug do
  defstruct name: nil, path: nil, file: nil
  @ignore_path "priv/"

  def parent_dirs(slug) do
    descend(from_docs_root(slug.path))
  end

  defp from_docs_root(slug_path) do
    slug_path
    |> String.split(@ignore_path)
    |> Enum.take(-1)
  end

  defp descend(path) do
    Path.split(path)
    |> Enum.drop(-1)
    |> Enum.reduce([], fn dir, results ->
      case List.last(results) do
        nil ->
          [dir]

        root ->
          if root == "/" do
            results ++ [root <> dir]
          else
            results ++ [root <> "/" <> dir]
          end
      end
    end)
  end
end
