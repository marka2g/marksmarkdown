defmodule MarksDownWeb.PreloadDatas do
  import Phoenix.{Component, LiveView}
  alias MarksDown.Contents

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> assign(
       notes: Contents.all_notes(),
       tree_of_contents:
         Contents.tree_of_contents()
         |> Map.from_struct()
     )}
  end
end
