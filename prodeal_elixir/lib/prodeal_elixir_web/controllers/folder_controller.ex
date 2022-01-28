defmodule ProdealElixirWeb.FolderController do
  use ProdealElixirWeb, :controller

  alias ProdealElixir.Folders
  alias ProdealElixir.Folders.Folder

  action_fallback ProdealElixirWeb.FallbackController

  def index(conn, %{"item_name" => item_name} = params) do
    limit = calculate_pagination_limit(params["per_page"])
    offset = calculate_pagination_offset(params["page"], limit)

    with {:ok, folders} <- Folders.get_folders_by(:item_name, item_name, offset, limit) do
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
    limit = calculate_pagination_limit(params["per_page"])
    offset = calculate_pagination_offset(params["page"], limit)

    with {:ok, %{sort_term: casted_sort_term, order_term: casted_order_term} = _casted_params} <-
           cast_params(params),
         {:ok, folders} <-
           Folders.sort_folders_by(casted_sort_term, casted_order_term, offset, limit) do
      render(conn, "index.json", folders: folders)
    else
      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ProdealElixirTestWeb.FolderView)
        |> render("custom_errors.json", error: error)
    end
  end

  def index(conn, params) do
    limit = calculate_pagination_limit(params["per_page"])
    offset = calculate_pagination_offset(params["page"], limit)

    folders = Folders.list_folders(offset, limit)

    render(conn, "index.json", folders: folders)
  end

  defp cast_params(%{"sort_by" => sort_term, "order_by" => order_term}) do
    {:ok, %{sort_term: String.to_atom(sort_term), order_term: String.to_atom(order_term)}}
  end

  defp cast_params(_params), do: {:error, :invalid_params}

  @default_per_page 2

  @spec calculate_pagination_limit(nil | String.t()) :: integer()
  defp calculate_pagination_limit(per_page) when is_nil(per_page) do
    @default_per_page
  end

  defp calculate_pagination_limit(per_page) when is_binary(per_page) do
    per_page |> String.to_integer()
  end

  @spec calculate_pagination_offset(nil | String.t() | integer(), integer()) :: integer()
  defp calculate_pagination_offset(page, per_page)
       when is_nil(page) do
    calculate_pagination_offset(1, per_page)
  end

  defp calculate_pagination_offset(page, per_page)
       when is_binary(page) do
    page |> String.to_integer() |> calculate_pagination_offset(per_page)
  end

  defp calculate_pagination_offset(page, per_page)
       when is_integer(page) and is_integer(per_page) do
    (page - 1) * per_page
  end
end
