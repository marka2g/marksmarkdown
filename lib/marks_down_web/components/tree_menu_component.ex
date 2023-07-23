defmodule MarksDownWeb.TreeMenuComponent do
  use MarksDownWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="overflow-x-scroll overflow-y-scroll">
      <ul>
        <%= tree_menu(assigns) %>
      </ul>
    </div>
    """
  end

  def tree_menu(assigns) do
    ~H"""
    <li class={if @notes.id == "notes", do: "root-node"}>
      <details open>
        <summary><%= sanitize_text(@notes.name) %></summary>
        <ul id={"#{assigns.id}-#{@notes.id}"}>
          <li :for={slug <- @notes.slugs}>
            <.link class="slug" navigate={~p"/#{slug}"}>
              <%= sanitize_text(slug) %>
            </.link>
          </li>
          <%= for child_key <- Map.keys assigns.notes.children do %>
            <% child = assigns.notes.children[child_key] %>
            <% assigns = assign(assigns, :notes, child) %>
            <%= tree_menu(assigns) %>
          <% end %>
        </ul>
      </details>
    </li>
    """
  end

  defp sanitize_text(item) do
    item
    |> String.replace("-", " ")
    |> String.replace("_", " ")
    |> String.replace(".html", "")
  end
end
