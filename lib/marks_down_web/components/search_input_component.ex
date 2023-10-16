defmodule MarksDownWeb.SearchInputComponent do
  use MarksDownWeb, :live_component

  alias MarksDown.Contents

  def render(assigns) do
    ~H"""
    <div>
      <.form phx-submit="search_notes" phx-change="suggest" phx-target={@myself} class="mr-4">
        <div class="relative">
          <span class="absolute inset-y-0 left-0 flex items-center pl-2">
            <.icon name="hero-magnifying-glass" class="w-6 h-6 stroke-current text-neutral-500" />
          </span>
          <input
            type="text"
            autocomplete="off"
            list="notes"
            name="search_string"
            autocomplete="off"
            value={@search_string}
            placeholder="type search, select from list, then hit 'enter'"
            class="py-2 pl-10 pr-4 text-sm leading-tight border rounded-md w-96 bg-drk-bk text-neutral-600 placeholder-neutral-600 border-neutral-700 focus:ring-0 focus:ring-offset-0 focus:border-2 focus:border-purple-500"
          />
        </div>
      </.form>

      <datalist
        id="notes"
        class="absolute border border-t-0 rounded-md bg-dark bg-drk-bk text-neutral-200"
      >
        <option :for={note <- @notes} class="p-4 mb-2 cursor-pointer">
          <%= note.title %>
        </option>
      </datalist>
    </div>
    """
  end

  def handle_event("search_notes", %{"search_string" => title}, socket) do
    note = Contents.get_note_by_title!(title)
    {:noreply, push_navigate(socket, to: "/#{note.slug}")}
  end

  def handle_event("suggest", %{"search_string" => search_string}, socket) do
    notes = Contents.search_notes!(search_string)

    IO.inspect(notes, label: "notes")
    {:noreply, assign(socket, notes: notes)}
  end
end
