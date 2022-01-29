defmodule ProdealElixirWeb.FolderControllerTest do
  use ProdealElixirWeb.ConnCase

  import ProdealElixir.FoldersFixtures

  alias ProdealElixir.Folders.Folder
  alias ProdealElixir.Folders
  alias ProdealElixir.PaginationParams

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index lists folders" do
    test "when there is no folder", %{conn: conn} do
      conn = get(conn, Routes.folder_path(conn, :index))

      assert json_response(conn, 200)["data"] == []
    end

    test "when there is a folder", %{conn: conn} do
      %Folder{id: id, item_name: item_name, parent_id: parent_id, priority: priority} =
        folder_fixture()

      conn = get(conn, Routes.folder_path(conn, :index))

      assert [
               %{
                 "id" => id,
                 "item_name" => item_name,
                 "parent_id" => parent_id,
                 "priority" => priority,
                 "path_name" => "some item_name"
               }
             ] == json_response(conn, 200)["data"]
    end

    test "when filtering folders", %{conn: conn} do
      folder_fixture()

      %Folder{
        id: id,
        item_name: item_name,
        parent_id: parent_id,
        priority: priority
      } = folder_fixture(%{item_name: "filtering test"})

      conn = get(conn, Routes.folder_path(conn, :index, %{item_name: "filtering test"}))

      assert [
               %{
                 "id" => id,
                 "item_name" => item_name,
                 "parent_id" => parent_id,
                 "priority" => priority,
                 "path_name" => "filtering test"
               }
             ] == json_response(conn, 200)["data"]
    end

    test "when filtering folders should return no folder", %{conn: conn} do
      folder_fixture()

      conn = get(conn, Routes.folder_path(conn, :index, %{item_name: "filtering test"}))

      assert json_response(conn, 200)["data"] == []
    end

    test "when sorting folders by priority incrementally", %{conn: conn} do
      %Folder{} = folder_fixture(%{priority: 4})
      %Folder{} = folder_fixture(%{priority: 3})

      conn = get(conn, Routes.folder_path(conn, :index, %{sort_by: "priority", order_by: "asc"}))

      {:ok, folders} = Folders.list_folders()

      sorted_priorities =
        folders
        |> sorted_folders_priorities(:asc)

      json_response(conn, 200)["data"]
      |> Enum.map(fn %{"priority" => priority} -> priority end)
      |> assert(sorted_priorities)
    end

    test "when sorting folders by priority decrementally", %{conn: conn} do
      %Folder{} = folder_fixture(%{priority: 4})
      %Folder{} = folder_fixture(%{priority: 3})

      conn = get(conn, Routes.folder_path(conn, :index, %{sort_by: "priority", order_by: "desc"}))

      {:ok, folders} = Folders.list_folders()

      sorted_priorities =
        folders
        |> sorted_folders_priorities(:desc)

      json_response(conn, 200)["data"]
      |> Enum.map(fn %{"priority" => priority} -> priority end)
      |> assert(sorted_priorities)
    end

    test "when sorting folders by priority ordered by default", %{conn: conn} do
      %Folder{} = folder_fixture(%{priority: 4})
      %Folder{} = folder_fixture(%{priority: 3})

      conn = get(conn, Routes.folder_path(conn, :index, %{sort_by: "priority"}))

      {:ok, folders} = Folders.list_folders()

      sorted_priorities =
        folders
        |> sorted_folders_priorities(:desc)

      json_response(conn, 200)["data"]
      |> Enum.map(fn %{"priority" => priority} -> priority end)
      |> assert(sorted_priorities)
    end

    test "when sorting and filtering folders", %{conn: conn} do
      %Folder{} = folder_fixture(%{item_name: "name", priority: 4})
      %Folder{} = folder_fixture(%{item_name: "name", priority: 3})
      %Folder{} = folder_fixture(%{priority: 1})

      conn =
        get(conn, Routes.folder_path(conn, :index, %{sort_by: "priority", item_name: "name"}))

      {:ok, folders} = Folders.list_folders()

      sorted_priorities =
        folders
        |> Enum.filter(fn %Folder{item_name: item_name} -> item_name != "name" end)
        |> sorted_folders_priorities(:desc)

      json_response(conn, 200)["data"]
      |> Enum.map(fn %{"priority" => priority} -> priority end)
      |> assert(sorted_priorities)
    end
  end

  describe "pagination" do
    setup do
      Enum.each(0..5, fn _ -> folder_fixture() end)
    end

    test "when no pagination data is provided", %{conn: conn} do
      conn = get(conn, Routes.folder_path(conn, :index))

      assert PaginationParams.per_page_default() == length(json_response(conn, 200)["data"])

      assert %{"next_page" => "2", "per_page" => "2", "prev_page" => nil, "total_pages" => "1"} ==
               json_response(conn, 200)["pagination_data"]
    end

    test "with custom data", %{conn: conn} do
      conn = get(conn, Routes.folder_path(conn, :index, %{page: 2, per_page: 3}))

      assert 3 == length(json_response(conn, 200)["data"])

      assert %{"next_page" => "3", "per_page" => "3", "prev_page" => "1", "total_pages" => "1"} ==
               json_response(conn, 200)["pagination_data"]
    end
  end

  defp sorted_folders_priorities(folders, order_by) when order_by in [:asc, :desc] do
    folders
    |> Enum.sort_by(& &1.priority, order_by)
    |> Enum.map(fn %Folder{priority: priority} -> priority end)
  end
end
