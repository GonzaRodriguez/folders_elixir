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

  def index(conn, %{"sort_by" => _sort_term, "order_by" => _order_method} = params) do
    with {:ok, %{sort_term: casted_sort_term, order_term: casted_order_term} = _casted_params} <-
           cast_params(params),
         {:ok, folders} <- Folders.sort_folders_by(casted_sort_term, casted_order_term) do
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

  defp cast_params(%{"sort_by" => sort_term, "order_by" => order_term}) do
    {:ok, %{sort_term: String.to_atom(sort_term), order_term: String.to_atom(order_term)}}
  end

  defp cast_params(_params), do: {:error, :invalid_params}
end
