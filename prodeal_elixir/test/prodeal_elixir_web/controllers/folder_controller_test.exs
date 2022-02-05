defmodule ProdealElixirWeb.FolderControllerTest do
  use ProdealElixirWeb.ConnCase

  import ProdealElixir.FoldersFixtures

  alias ProdealElixir.Folders.Folder

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
  end
end
