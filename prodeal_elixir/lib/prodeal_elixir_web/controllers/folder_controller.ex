defmodule ProdealElixirWeb.FolderController do
  use ProdealElixirWeb, :controller

  alias ProdealElixir.Folders
  alias ProdealElixir.Folders.Folder

  action_fallback ProdealElixirWeb.FallbackController

  def index(conn, _params) do
    folders = Folders.list_folders()

    render(conn, "index.json", folders: folders)
  end
end
