%{
  title: "Tree of Contents",
  author: "Mark Sadegi",
  description: "This note describes how I build the auto-generated tree of contents menu",
  tags: ~w(elixir phoenix live_view nimble_publisher trees recursion),
  date: "2023-07-17"
}
---

[The secret's out](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made){:target="_blank" .under}, ...building a Phoenix LiveView powered static site has never been easier thanks to [**`NimblePublisher`**](https://github.com/dashbitco/nimble_publisher){:target="_blank" .under}. Also, [fly.io](https://fly.io){:target="_blank" .under} makes [publishing your markdown to the world](https://fly.io/phoenix-files/crafting-your-own-static-site-generator-using-phoenix/){:target="_blank" .under} a breeze. In this post, I'll skip on describing how to setup and implement NimblePublisher - the docs are excellent and there are loads of resources online to refer to if you get stuck.

That out of the way, this note walks through creating a linkable, file-structure-like menu that would auto-generate each time a markdown file is added or removed. The menu should represent the static pages that exist in a file structure looking like:

<image src="/images/notes/toc_file_structure.png" alt="file structure" width="425" height="500" class="my-4"/>

_Notice that only the directories with markdown files show up in the tree of contents menu._ 

To accomplish this, a basic tree data structure representing the directories and markdown file slugs within those nested directories seemed the correct path to take. The code is a work in progress; there is room for improvements and refinement. Nonetheless, this was a first pass and it's functioning as initially designed. Let's run through some of the important steps to build the Tree Of Contents menu and you can checkout the [source here](https://github.com/marka2g/marksmarkdown){:target="_blank" .under}.

<a id="steps"></a>

## Steps
* [**1. Add structs to represent the menu link nodes:**](#step-1)
> [**`%Tree{}`, **](#tree-struct){:css .sub-list-item} [** `%Slug{}`**](#slug-struct){:css .sub-list-item}
* [**2. Map directories and slugs to build a tree structure**](#step-2)
> [**`Directories(Module)`, **](#directories-module){:css .sub-list-item} [** `TreeOfContents(Module)`**](#tree-of-contents-module){:css .sub-list-item}
* [**3. Integrate with `NimblePublisher`**](#step-3)
> [**`Contents(Module)`, **](#contents-module){:css .sub-list-item} [** `Notes(Module)` _link to source_**](https://github.com/marka2g/marksmarkdown/blob/main/lib/marks_down/contents/note.ex){:target="_blank" .sub-list-item .under}
* [**4. Integrate with `PhoenixLiveView`**](#step-4)
> [**Implement `live_session` `on_mount` hook, **](#on-mount-hook){:css .sub-list-item} [ ** `TreeMenuComponent`**](#tree-menu-component){:css .sub-list-item}

<a id="step-1"></a>

### 1. Add structs to represent the menu link nodes:
<a id="tree-struct"></a>


<div class="tree-struct"></div>

- [**`%Tree{}`** - _represents a directory to toggle_](https://github.com/marka2g/marksmarkdown/blob/main/lib/marks_down/directories/tree.ex){:target="_blank" .under}
>```elixir
>defmodule MarksDown.Directories.Tree do
>  @moduledoc """
>  A tree data structure that encapsulates 
>  a directory in the file system
>  """
>  alias __MODULE__
>
>  defstruct [:id, :name, :path, slugs: [], children: %{}]
>
>  #...
>end
>```


<a id="slug-struct"></a>

- [**`%Slug{}`** - _represents an actual link to a markdown file_](https://github.com/marka2g/marksmarkdown/blob/main/lib/marks_down/directories/slug.ex){:target="_blank"}{:css #slug-code-link .under}
>```elixir
>defmodule MarksDown.Directories.Slug do
>  @moduledoc """
>  Data structure that encapsulates 
>  a slug(.md) in the file system
>  """
>  defstruct name: nil, path: nil, file: nil
>  @ignore_path "priv/"
>
>  def parent_dirs(slug) do
>    drop_down(from_docs_root(slug.path))
>  end
>
>  defp from_docs_root(slug_path) do
>    slug_path
>    |> String.split(@ignore_path)
>    |> Enum.take(-1)
>  end
>
>  defp drop_down(path) do
>    Path.split(path)
>    |> Enum.drop(-1)
>    |> Enum.reduce([], fn dir, results ->
>      case List.last(results) do
>        nil ->
>          [dir]
>
>        root ->
>         if root == "/" do
>           results ++ ["#{root}#{dir}"]
>         else
>           results ++ ["#{root}/#{dir}"]
>         end
>       end
>     end)
>   end
>end
>```
>
> [**⬆︎ to Steps**](#steps)


<a id="step-2"></a>

### 2. Map directories and files to build a tree structure

<a id="directories-module"></a>

- [**Directories Module(_abbreviated_)**](https://github.com/marka2g/marksmarkdown/blob/main/lib/marks_down/directories.ex){:target="_blank" .under}
>```elixir
>defmodule MarksDown.Directories do
>  @moduledoc """
>    Maps the directories and markdown files 
>    to construct a tree data structure
>  """
>  alias MarksDown.Directories.{Tree, Slug}
>
>  #...
>
>  @doc """
>    First, sort top level children given as
>    parameter by name and then starting with empty tree,
>    Enum.reduce to map the directories.
>  """
>  def map_menu_links(children) do
>    children = Enum.sort_by(children, & &1.path, :desc)
>
>    Enum.reduce(children, %Tree{}, fn child, root ->
>      add_child(Slug.parent_dirs(child), child, root)
>    end)
>  end
>
>  # when [], it's a file/slug
>  defp add_child([], _slug, root), do: root
>
>  # when items in list, it's a directory
>  defp add_child([parent | rest], slug, root) do
>    tree =
>      case Map.get(root.children, Path.basename(parent)) do
>        nil ->
>          %Tree{
>            id: get_id_from_path(parent),
>            name: get_name_from_path(parent),
>            path: parent,
>            slugs: get_slugs(parent, slug)
>          }
>
>        tree ->
>          tree
>      end
>
>    # recurse
>    tree = add_child(rest, slug, tree)
>
>    %{
>      root
>      | children:
>          Map.put(
>            root.children,
>            Path.basename(parent),
>            tree
>         )
>      }
>  end
>
>  #...
>end
>```
> [**⬆︎ to Steps**](#steps)

<a id="tree-of-contents-module"></a>

- [**TreeOfContents Module(_abbreviated_)**](https://github.com/marka2g/marksmarkdown/blob/main/lib/marks_down/tree_of_contents.ex){:target="_blank" .under}
>```elixir
>defmodule MarksDown.TreeOfContents do
>  @moduledoc """
>  Maps the files to slugs links for the tree menu 
>  """
>  #...
>  def build_menu_tree(path \\ @files_path) do
>    slugs = get_slugs(path)
>    Directories.map_menu_links(slugs).children["notes"]
>  end
>
>  #...
>
>  defp get_slugs(path) do
>    Enum.map(
>      Directories.list_files(path),
>      fn path ->
>        case File.read(path) do
>          {:ok, _data} ->
>            file_name(path)
>            build_slug(path)
>
>          {:error, _} ->
>            nil
>        end
>      end
>    )
>    |> Enum.reject(&is_nil/1)
>  end
>
>  defp build_slug(path) do
>    %Slug{
>      path: path,
>      name: file_name(path) |> String.replace(".md", ".html"),
>      file: file_name(path)
>    }
>  end
>end
>```
>
>```elixir
># data structure after 
># TreeOfContents.build_tree_menu()
># is called. notice that some trees have an 
># empty [] for slugs. these represent an 
># empty parent directory
>%MarksDown.Directories.Tree{
>  id: "notes",
>  name: "notes",
>  path: "notes",
>  slugs: ["elevator-pitch.html"],
>  children: %{
>    "concepts" => %MarksDown.Directories.Tree{
>      id: "notes-concepts",
>      name: "concepts",
>      path: "notes/concepts",
>      slugs: [],
>      children: %{
>        "cs" => %MarksDown.Directories.Tree{
>          id: "notes-concepts-cs",
>          name: "cs",
>          path: "notes/concepts/cs",
>          slugs: [],
>          children: %{
>            "languages" => %MarksDown.Directories.Tree{
>              id: "notes-concepts-cs-languages",
>              name: "languages",
>              path: "notes/concepts/cs/languages",
>              slugs: [],
>              children: %{
>                "elixir" => %MarksDown.Directories.Tree{
>                  id: "notes-concepts-cs-languages-elixir",
>                  name: "elixir",
>                  path: "notes/concepts/cs/languages/elixir",
>                  slugs: ["memory.html"],
>                  children: %{
>                    "features" => %MarksDown.Directories.Tree{
>                      id: "notes-concepts-cs-languages-elixir-features",
>                      name: "features",
>                      path: "notes/concepts/cs/languages/elixir/features",
>                      slugs: ["tree-of-contents.html"],
>                      children: %{}
>                    },
>                    "tips" => %MarksDown.Directories.Tree{
>                      id: "notes-concepts-cs-languages-elixir-tips",
>                      name: "tips",
>                      path: "notes/concepts/cs/languages/elixir/tips",
>                      slugs: ["enum.html", "elixir-tips.html"],
>                      children: %{}
>                     }
>                   }
>                 }
>               }
>             }
>           }
>         }
>       }
>     }
>   }
> }
>```
> [**⬆︎ to Steps**](#steps)

<a id="step-3"></a>

### 3. Integrate with `NimblePublisher`
<a id="contents-module"></a>

- [**Contents Module(_abbreviated_)**](https://github.com/marka2g/marksmarkdown/blob/main/lib/marks_down/contents.ex){:target="_blank" .under}
>```elixir
> # The Main NimblePublisher Module 
>defmodule MarksDown.Contents do
>
>  #...
>
>  @tree_of_contents TreeOfContents.build_menu_tree()
>
>  #...
>
>  def tree_of_contents, do: @tree_of_contents
>
>  #...
>end
>```
>[**⬆︎ to Steps**](#steps)

<a id="step-4"></a>

### 4. Integrate with `PhoenixLiveView`
- First, I created a `live_session` `on_mount` hook to preload the common static data needed by the two live_views
>```elixir
>defmodule MarksDownWeb.Router do
>  #...
>  scope "/", MarksDownWeb do
>    pipe_through(:browser)
>
>    live_session :preload_datas, on_mount: MarksDownWeb.PreloadDatas do
>      live("/", Notes.IndexLive, :index)
>      live("/:slug", Notes.ShowLive, :show)
>    end
>  end
>  #...
>end
>
># then, implement the live_session on_mount hook
>defmodule MarksDownWeb.PreloadDatas do
>  #...
>
>  def on_mount(:default, _params, _session, socket) do
>    {:cont,
>     socket
>     |> assign(
>       notes: Contents.all_notes(),
>       tree_of_contents:
>         Contents.tree_of_contents()
>         |> Map.from_struct()
>       )
>     }
>  end
>
>  #...
>end
>```
>[**⬆︎ to Steps**](#steps)
>

<a id="tree-menu-component"></a>

- [**TreeMenuComponent(_abbreviated_)**](https://github.com/marka2g/marksmarkdown/blob/main/lib/marks_down_web/components/tree_menu_component.ex){:target="_blank" .under}
> Finally, a live component recursively builds the html menu
> ```elixir
>defmodule MarksDownWeb.TreeMenuComponent do
>  use MarksDownWeb, :live_component
>
>  def render(assigns) do
>    ~H"""
>    <div class="overflow-x-scroll overflow-y-scroll">
>      <ul>
>        <%= tree_menu(assigns) %>
>      </ul>
>    </div>
>    """
>  end
>
>  def tree_menu(assigns) do
>    ~H"""
>    <li class={if @notes.id == "notes", do: "root-node"}>
>      <details open>
>        <summary><%= sanitize_text(@notes.name) %></summary>
>        <ul id={"#{assigns.id}-#{@notes.id}"}>
>          <li :for={slug <- @notes.slugs}>
>            <.link class="slug" navigate={~p"/#{slug}"}>
>              <%= sanitize_text(slug) %>
>            </.link>
>          </li>
>          <%= for child_key <- Map.keys assigns.notes.children do %>
>            <% child = assigns.notes.children[child_key] %>
>            <% assigns = assign(assigns, :notes, child) %>
>            <%!-- recurse --%>
>            <%= tree_menu(assigns) %>
>          <% end %>
>        </ul>
>      </details>
>    </li>
>    """
>  end
>
>  #...
> ```
>[**⬆︎ to Steps**](#steps)
>

## Conclusion
And there you have it, a tree menu that dynamically builds itself as markdown files are added and removed from the directory structure. This read was a bit long even though I attempted to only included the important bits of the feature; be sure to check out the [source](https://github.com/marka2g/marksmarkdown){:target="_blank" .under}. Lastly, iterative improvements will be made as time permits and I will try to keep this note in sync with code changes. Thanks for reading!