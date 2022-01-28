defmodule ProdealElixirWeb.FolderController do
  use ProdealElixirWeb, :controller

  alias ProdealElixir.Folders
  alias ProdealElixir.Folders.Folder

  action_fallback ProdealElixirWeb.FallbackController

  def index(conn, %{"item_name" => item_name} = params) do
    limit = calculate_pagination_limit(params["per_page"])
    offset = calculate_pagination_offset(params["page"], limit)

    with {:ok, folders} <- Folders.get_folders_by(:item_name, item_name, offset, limit) do
      pagintation_data = get_pagination_data(params["page"], params["per_page"])

      render(conn, "index.json", %{folders: folders, pagination_data: pagintation_data})
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
      pagintation_data = get_pagination_data(params["page"], params["per_page"])

      render(conn, "index.json", %{folders: folders, pagination_data: pagintation_data})
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

    pagintation_data = get_pagination_data(params["page"], params["per_page"])
    render(conn, "index.json", %{folders: folders, pagination_data: pagintation_data})
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

  @spec get_prev_page(nil | integer()) :: nil | String.t()
  defp get_prev_page(page) do
    page_int = unless is_nil(page), do: String.to_integer(page), else: 1

    if page_int > 1 && !is_nil(page_int), do: "#{page_int - 1}", else: nil
  end

  @spec get_next_page(integer(), nil | String.t(), nil | String.t()) :: nil | String.t()
  defp get_next_page(folders_count, per_page, page) do
    page_int = unless is_nil(page), do: String.to_integer(page), else: 1

    per_page_int =
      unless is_nil(per_page), do: String.to_integer(per_page), else: @default_per_page

    last_page = folders_count < per_page_int

    if last_page, do: nil, else: "#{page_int + 1}"
  end

  @spec get_total_pages(integer(), nil | integer()) :: String.t()
  defp get_total_pages(folders_count, per_page) when is_nil(per_page) do
    get_total_pages(folders_count, @default_per_page)
  end

  defp get_total_pages(folders_count, per_page) when is_binary(per_page) do
    get_total_pages(folders_count, String.to_integer(per_page))
  end

  defp get_total_pages(folders_count, per_page) when is_integer(per_page) do
    total_pages = ceil(folders_count / per_page)

    "#{total_pages}"
  end

  @spec get_pagination_data(nil | integer(), nil | integer()) :: map
  defp get_pagination_data(page, per_page) do
    folders_count = length(Folders.list_folders())

    %{
      prev_page: get_prev_page(page),
      next_page: get_next_page(folders_count, per_page, page),
      per_page: per_page || @default_per_page,
      total_pages: get_total_pages(folders_count, per_page)
    }
  end
end
