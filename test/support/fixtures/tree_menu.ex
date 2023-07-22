defmodule MarksDown.TreeFixtures do
  def tree_menu() do
    %MarksDown.Directories.Tree{
      id: "notes",
      name: "notes",
      path: "notes",
      slugs: [],
      children: %{
        "concepts" => %MarksDown.Directories.Tree{
          id: "notes-concepts",
          name: "concepts",
          path: "notes/concepts",
          slugs: [],
          children: %{
            "cs" => %MarksDown.Directories.Tree{
              id: "notes-concepts-cs",
              name: "cs",
              path: "notes/concepts/cs",
              slugs: [],
              children: %{
                "languages" => %MarksDown.Directories.Tree{
                  id: "notes-concepts-cs-languages",
                  name: "languages",
                  path: "notes/concepts/cs/languages",
                  slugs: [],
                  children: %{
                    "elixir" => %MarksDown.Directories.Tree{
                      id: "notes-concepts-cs-languages-elixir",
                      name: "elixir",
                      path: "notes/concepts/cs/languages/elixir",
                      slugs: [],
                      children: %{
                        "features" => %MarksDown.Directories.Tree{
                          id: "notes-concepts-cs-languages-elixir-features",
                          name: "features",
                          path: "notes/concepts/cs/languages/elixir/features",
                          slugs: [],
                          children: %{}
                        },
                        "idioms" => %MarksDown.Directories.Tree{
                          id: "notes-concepts-cs-languages-elixir-idioms",
                          name: "idioms",
                          path: "notes/concepts/cs/languages/elixir/idioms",
                          slugs: [],
                          children: %{}
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  end
end
