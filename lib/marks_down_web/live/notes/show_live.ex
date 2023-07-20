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
      <%!-- <div> --%>
      <div class="flex flex-col">
        <div class="mb-4 text-sm font-extrabold">
          <.icon name="hero-calendar-days" class="pr-8" /><%= @note.date %>
        </div>
        <div class="flex justify-end flex-column">
          <div class="text-4xl font-extrabold grow"><%= @note.title %></div>
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
end
