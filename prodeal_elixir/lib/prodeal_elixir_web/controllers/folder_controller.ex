defmodule ProdealElixirWeb.FolderController do
  use ProdealElixirWeb, :controller

  alias ProdealElixir.Folders
  alias ProdealElixir.Folders.Folder

  action_fallback ProdealElixirWeb.FallbackController

  plug ProdealElixir.PaginationParams, :pagination when action in [:index]

  @default_order_by :desc

  def index(conn, %{"item_name" => item_name, "sort_by" => _sort_term} = params) do
    limit = conn.assigns[:pagination].per_page
    offset = calculate_pagination_offset(conn.assigns[:pagination].page, limit)

    with {:ok,
          %{
            sort_term: casted_sort_term,
            order_term: casted_order_term,
            filter_by: casted_filter_by
          }} <-
           cast_params(params),
         {:ok, folders} <-
           Folders.list_folders_filtering_and_sorting(
             casted_filter_by,
             item_name,
             casted_sort_term,
             casted_order_term,
             offset,
             limit
           ) do
      pagintation_data =
        get_pagination_data(
          length(folders),
          conn.assigns[:pagination].page,
          conn.assigns[:pagination].per_page
        )

      render(conn, "index.json", %{folders: folders, pagination_data: pagintation_data})
    else
      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ProdealElixirTestWeb.FolderView)
        |> render("custom_errors.json", error: error)
    end
  end

  def index(conn, %{"item_name" => item_name} = params) do
    limit = conn.assigns[:pagination].per_page
    offset = calculate_pagination_offset(conn.assigns[:pagination].page, limit)

    with {:ok, %{filter_by: casted_filter_by}} <-
           cast_params(params),
         {:ok, folders} <-
           Folders.list_folders_filtering(casted_filter_by, item_name, offset, limit) do
      pagintation_data =
        get_pagination_data(
          length(folders),
          conn.assigns[:pagination].page,
          conn.assigns[:pagination].per_page
        )

      render(conn, "index.json", %{folders: folders, pagination_data: pagintation_data})
    else
      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ProdealElixirTestWeb.FolderView)
        |> render("custom_errors.json", error: error)
    end
  end

  def index(conn, %{"sort_by" => _sort_term} = params) do
    limit = conn.assigns[:pagination].per_page
    offset = calculate_pagination_offset(conn.assigns[:pagination].page, limit)

    with {:ok, %{sort_term: casted_sort_term, order_term: casted_order_term}} <-
           cast_params(params),
         {:ok, folders} <-
           Folders.list_folders_sorting(casted_sort_term, casted_order_term, offset, limit) do
      pagintation_data =
        get_pagination_data(
          length(folders),
          conn.assigns[:pagination].page,
          conn.assigns[:pagination].per_page
        )

      render(conn, "index.json", %{folders: folders, pagination_data: pagintation_data})
    else
      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ProdealElixirTestWeb.FolderView)
        |> render("custom_errors.json", error: error)
    end
  end

  def index(conn, _params) do
    limit = conn.assigns[:pagination].per_page
    offset = calculate_pagination_offset(conn.assigns[:pagination].page, limit)

    {:ok, folders} = Folders.list_folders(offset, limit)

    pagintation_data =
      get_pagination_data(
        length(folders),
        conn.assigns[:pagination].page,
        conn.assigns[:pagination].per_page
      )

    render(conn, "index.json", %{folders: folders, pagination_data: pagintation_data})
  end

  defp cast_params(%{"item_name" => _filter, "sort_by" => sort_term} = params) do
    order_by =
      unless is_nil(params["order_by"]),
        do: String.to_atom(params["order_by"]),
        else: @default_order_by

    {:ok,
     %{
       sort_term: String.to_atom(sort_term),
       order_term: order_by,
       filter_by: String.to_atom("item_name")
     }}
  end

  defp cast_params(%{"item_name" => _filter}),
    do: {:ok, %{filter_by: String.to_atom("item_name")}}

  defp cast_params(%{"sort_by" => sort_term} = params) do
    order_by =
      unless is_nil(params["order_by"]),
        do: String.to_atom(params["order_by"]),
        else: @default_order_by

    {:ok, %{sort_term: String.to_atom(sort_term), order_term: order_by}}
  end

  defp cast_params(_params), do: {:error, :invalid_params}

  @spec calculate_pagination_offset(integer(), integer()) :: integer()
  defp calculate_pagination_offset(page, per_page)
       when is_integer(page) and is_integer(per_page) do
    (page - 1) * per_page
  end

  @spec get_prev_page(integer()) :: nil | String.t()
  defp get_prev_page(page) when is_integer(page) and page > 1 do
    page
    |> Kernel.-(1)
    |> Integer.to_string()
  end

  defp get_prev_page(_page), do: nil

  @spec get_next_page(integer(), integer(), integer()) :: nil | String.t()
  defp get_next_page(folders_count, per_page, _page) when folders_count < per_page do
    nil
  end

  defp get_next_page(_folders_count, _per_page, page) do
    page
    |> Kernel.+(1)
    |> Integer.to_string()
  end

  @spec get_total_pages(integer(), integer()) :: String.t()
  defp get_total_pages(folders_count, per_page) when is_integer(per_page) do
    folders_count
    |> Kernel./(per_page)
    |> ceil()
    |> Integer.to_string()
  end

  @spec get_pagination_data(integer(), integer(), integer()) :: map
  defp get_pagination_data(folders_count, page, per_page) do
    %{
      prev_page: get_prev_page(page),
      next_page: get_next_page(folders_count, per_page, page),
      per_page: Integer.to_string(per_page),
      total_pages: get_total_pages(folders_count, per_page)
    }
  end
end
