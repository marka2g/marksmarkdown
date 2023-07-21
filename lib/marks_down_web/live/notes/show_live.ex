defmodule MarksDownWeb.Notes.ShowLive do
  use MarksDownWeb, :live_view

  alias MarksDown.Contents

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    {:ok,
     socket
     |> assign(note: Contents.get_note_by_slug!(slug))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="clipboards" phx-hook="AddCopyButtons">
      <div class="flex flex-col">
        <div class="mb-4 text-sm font-extrabold">
          <.icon name="hero-calendar-days" class="pr-8" /><%= @note.date %>
        </div>
        <div class="flex justify-end flex-column">
          <div class="text-4xl font-extrabold grow">
            <div class="flex flex-column">
              <div><%= @note.title %></div>
              <div class="mt-2 ml-2"><%= title_icon(@note, assigns) %></div>
            </div>
          </div>
        </div>
        <div class="relative grid grid-cols-2 gap-8 mt-4">
          <div class="col-span-1 text-sm text-light-teal hover:text-my-green">
            [<.link navigate={~p"/"}>all notes</.link>]
          </div>
        </div>
      </div>
      <div class="flex-1 pt-4 pb-8 overflow-y-scroll rounded-md">
        <div id="raw"><%= raw(@note.body) %></div>
      </div>
    </div>
    """
  end

  def title_icon(note, assigns) do
    slug = note.slug

    case slug do
      "tree-of-contents.html" ->
        tree_svg(assigns)

      _ ->
        note_svg(assigns)
    end
  end

  def tree_svg(assigns) do
    ~H"""
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        d="M7 8H4C2.9 8 2 7.1 2 6V4C2 2.9 2.9 2 4 2H7C8.1 2 9 2.9 9 4V6C9 7.1 8.1 8 7 8Z"
        stroke="#EDE9FE"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path
        d="M20.8 7H17.2C16.54 7 16 6.45999 16 5.79999V4.20001C16 3.54001 16.54 3 17.2 3H20.8C21.46 3 22 3.54001 22 4.20001V5.79999C22 6.45999 21.46 7 20.8 7Z"
        stroke="#EDE9FE"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path
        d="M20.8 14.5H17.2C16.54 14.5 16 13.96 16 13.3V11.7C16 11.04 16.54 10.5 17.2 10.5H20.8C21.46 10.5 22 11.04 22 11.7V13.3C22 13.96 21.46 14.5 20.8 14.5Z"
        stroke="#EDE9FE"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path
        d="M9 5H16"
        stroke="#EDE9FE"
        stroke-width="1.5"
        stroke-miterlimit="10"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path d="M12.5 5V18C12.5 19.1 13.4 20 14.5 20H16" fill="#292D32" />
      <path
        d="M12.5 5V18C12.5 19.1 13.4 20 14.5 20H16"
        stroke="#EDE9FE"
        stroke-width="1.5"
        stroke-miterlimit="10"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path
        d="M12.5 12.5H16"
        stroke="#EDE9FE"
        stroke-width="1.5"
        stroke-miterlimit="10"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path
        d="M20.8 22H17.2C16.54 22 16 21.46 16 20.8V19.2C16 18.54 16.54 18 17.2 18H20.8C21.46 18 22 18.54 22 19.2V20.8C22 21.46 21.46 22 20.8 22Z"
        stroke="#EDE9FE"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
    """
  end

  def note_svg(assigns) do
    ~H"""
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        d="M8 2V5"
        stroke="#EDE9FE"
        stroke-width="1.5"
        stroke-miterlimit="10"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path
        d="M16 2V5"
        stroke="#EDE9FE"
        stroke-width="1.5"
        stroke-miterlimit="10"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path
        d="M7 13H15"
        stroke="#EDE9FE"
        stroke-width="1.5"
        stroke-miterlimit="10"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path
        d="M7 17H12"
        stroke="#EDE9FE"
        stroke-width="1.5"
        stroke-miterlimit="10"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path
        d="M16 3.5C19.33 3.68 21 4.95 21 9.65V15.83C21 19.95 20 22.01 15 22.01H9C4 22.01 3 19.95 3 15.83V9.65C3 4.95 4.67 3.69 8 3.5H16Z"
        stroke="#EDE9FE"
        stroke-width="1.5"
        stroke-miterlimit="10"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
    """
  end
end
