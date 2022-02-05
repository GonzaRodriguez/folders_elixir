defmodule ProdealElixirWeb.FolderControllerTest do
  use ProdealElixirWeb.ConnCase

  import ProdealElixir.FoldersFixtures

  alias ProdealElixir.Folders.Folder
  alias ProdealElixir.Folders

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
                 "priority" => priority
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
                 "priority" => priority
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

      sorted_priorities = sorted_folders_priorities(:asc)

      json_response(conn, 200)["data"]
      |> Enum.map(fn %{"priority" => priority} -> priority end)
      |> assert(sorted_priorities)
    end

    test "when sorting folders by priority decrementally", %{conn: conn} do
      %Folder{} = folder_fixture(%{priority: 4})
      %Folder{} = folder_fixture(%{priority: 3})

      conn = get(conn, Routes.folder_path(conn, :index, %{sort_by: "priority", order_by: "desc"}))

      sorted_priorities = sorted_folders_priorities(:desc)

      json_response(conn, 200)["data"]
      |> Enum.map(fn %{"priority" => priority} -> priority end)
      |> assert(sorted_priorities)
    end
  end

  defp sorted_folders_priorities(order_by) when order_by in [:asc, :desc] do
    Folders.list_folders()
    |> Enum.sort_by(& &1.priority, order_by)
    |> Enum.map(fn %Folder{priority: priority} -> priority end)
  end
end
