defmodule MarksDownWeb.Notes.IndexLive do
  use MarksDownWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # {:ok, socket |> assign(note: nil)}
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 class="my-4 text-4xl font-extrabold">
        ALL NOTES
      </h2>
      <ul :for={note <- @notes} class="note-item">
        <li class="mb-4 hover:text-link-purple">
          <.link class="block p-6" navigate={~p"/#{note.slug}"}>
            <h3 class="text-xl font-bold">
              <%= note.title %>
            </h3>
            <p class="">
              <.icon name="hero-calendar-days" /> <%= note.date %>
            </p>
          </.link>
        </li>
      </ul>
    </div>
    """
  end
end
