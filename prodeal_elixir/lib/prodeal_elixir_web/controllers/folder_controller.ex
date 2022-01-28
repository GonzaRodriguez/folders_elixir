defmodule ProdealElixirWeb.FolderController do
  use ProdealElixirWeb, :controller

  alias ProdealElixir.Folders
  alias ProdealElixir.Folders.Folder

  action_fallback ProdealElixirWeb.FallbackController

  def index(conn, %{"item_name" => item_name}) do
    with {:ok, folders} <- Folders.get_folders_by(:item_name, item_name) do
      render(conn, "index.json", folders: folders)
    else
      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ProdealElixirTestWeb.FolderView)
        |> render("custom_errors.json", error: error)
    end
  end

  def index(conn, _params) do
    folders = Folders.list_folders()

    render(conn, "index.json", folders: folders)
  end
end
