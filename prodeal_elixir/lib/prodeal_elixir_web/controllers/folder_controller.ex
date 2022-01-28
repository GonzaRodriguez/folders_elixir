defmodule ProdealElixirWeb.FolderController do
  use ProdealElixirWeb, :controller

  alias ProdealElixir.Folders
  alias ProdealElixir.Folders.Folder

  action_fallback ProdealElixirWeb.FallbackController

  def index(conn, %{"item_name" => item_name}) do
    folders = Folders.get_folders_by(item_name)

    render(conn, "index.json", folders: folders)
  end

  def index(conn, _params) do
    folders = Folders.list_folders()

    render(conn, "index.json", folders: folders)
  end
end
