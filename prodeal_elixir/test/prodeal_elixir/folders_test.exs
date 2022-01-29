defmodule ProdealElixir.FoldersTest do
  use ProdealElixir.DataCase

  alias ProdealElixir.Folders

  alias ProdealElixir.Folders.Folder

  import ProdealElixir.FoldersFixtures

  @invalid_attrs %{item_name: nil, parent_id: nil, priority: nil}

  describe "list folders" do
    test "list_folders/0 returns all folders" do
      %Folder{id: id} = folder_fixture()
      {:ok, [folder]} = Folders.list_folders()

      assert folder.id == id
    end

    test "list_folders/0 returns all folders with path_name" do
      %Folder{id: root_id} = folder_fixture(%{item_name: "Root"})
      %Folder{id: folder_id} = folder_fixture(%{item_name: "Folder", parent_id: root_id})
      %Folder{} = folder_fixture(%{item_name: "Sub Folder", parent_id: folder_id})

      {:ok, folders} = Folders.list_folders()

      expected_path_names = ["Root", "Root/Folder", "Root/Folder/Sub Folder"]

      Enum.each(folders, fn folder ->
        assert folder.path_name in expected_path_names
      end)
    end

    test "list_folders/2 returns all folders" do
      %Folder{id: id} = folder_fixture()
      {:ok, [folder]} = Folders.list_folders(0, 20)

      assert folder.id == id
    end

    test "list_folders/2 returns all folders with path_name" do
      %Folder{id: root_id} = folder_fixture(%{item_name: "Root"})
      %Folder{id: folder_id} = folder_fixture(%{item_name: "Folder", parent_id: root_id})
      %Folder{} = folder_fixture(%{item_name: "Sub Folder", parent_id: folder_id})

      {:ok, folders} = Folders.list_folders(0, 20)

      expected_path_names = ["Root", "Root/Folder", "Root/Folder/Sub Folder"]

      Enum.each(folders, fn folder ->
        assert folder.path_name in expected_path_names
      end)
    end
  end

  describe "list folders filtering" do
    test "list_folders_filtering/4 returns only all folders with given item_name containing its path_name" do
      item_name = "filtering_test"

      folder_fixture(%{item_name: "different_item_name"})
      %Folder{id: root_id} = folder_fixture(%{item_name: "filtering_test"})
      %Folder{id: folder_id} = folder_fixture(%{item_name: "filtering_test", parent_id: root_id})
      %Folder{} = folder_fixture(%{item_name: "filtering_test", parent_id: folder_id})

      {:ok, filtered_folders} = Folders.list_folders_filtering(:item_name, item_name, 0, 20)

      expected_path_names = [
        "filtering_test",
        "filtering_test/filtering_test",
        "filtering_test/filtering_test/filtering_test"
      ]

      Enum.each(filtered_folders, fn folder ->
        assert folder.path_name in expected_path_names
      end)

      assert length(filtered_folders) == 3
    end

    test "list_folders_filtering/4 returns only all folders with given item_name" do
      item_name = "filtering_test"

      folder_fixture(%{item_name: "different_item_name"})

      Enum.each(0..5, fn _x ->
        folder_fixture(%{item_name: item_name})
      end)

      {:ok, filtered_folders} = Folders.list_folders_filtering(:item_name, item_name, 0, 20)

      assert length(filtered_folders) == 6
    end

    test "list_folders_filtering/4 when clause not matching" do
      item_name = "filtering_test"

      {:error, error} = Folders.list_folders_filtering(:other_field, item_name, 0, 20)

      assert error == "Invalid arguments received when filtering by item_name"
    end
  end

  describe "list_folders_sorting" do
    test "list_folders_sorting/4 returns ordered folders decrementally" do
      %Folder{} = folder_fixture(%{priority: 4})
      %Folder{} = folder_fixture(%{priority: 3})

      {:ok, [first | [last]]} = Folders.list_folders_sorting(:priority, :desc, 0, 20)

      assert first.priority == 4
      assert last.priority == 3
    end

    test "list_folders_sorting/4 returns ordered folders incrementally" do
      %Folder{} = folder_fixture(%{priority: 3})
      %Folder{} = folder_fixture(%{priority: 4})

      {:ok, [first | [last]]} = Folders.list_folders_sorting(:priority, :asc, 0, 20)

      assert first.priority == 3
      assert last.priority == 4
    end

    test "list_folders_sorting/4 returns ordered folders containing its path_name" do
      %Folder{id: root_id} = folder_fixture(%{priority: 1, item_name: "Root"})

      %Folder{id: folder_id} =
        folder_fixture(%{priority: 2, item_name: "Folder", parent_id: root_id})

      %Folder{} = folder_fixture(%{priority: 3, item_name: "Sub Folder", parent_id: folder_id})

      order_method = Enum.random([:desc, :asc])

      {:ok, sorted_folders} = Folders.list_folders_sorting(:priority, order_method, 0, 20)

      expected_path_names = ["Root", "Root/Folder", "Root/Folder/Sub Folder"]

      Enum.each(sorted_folders, fn folder ->
        assert folder.path_name in expected_path_names
      end)
    end

    test "list_folders_sorting/4 when clause not matching" do
      {:error, error} = Folders.list_folders_sorting(:other_field, :desc, 0, 20)

      assert error == "Invalid arguments received when sorting by priority"
    end
  end

  describe "list_folders_filtering_and_sorting" do
    test "list_folders_filtering_and_sorting/6 returns filtered and ordered folders decrementally" do
      %Folder{} = folder_fixture(%{item_name: "name", priority: 4})
      %Folder{} = folder_fixture(%{item_name: "name", priority: 3})
      %Folder{} = folder_fixture(%{priority: 1})

      {:ok, [first | [last]]} =
        Folders.list_folders_filtering_and_sorting(:item_name, "name", :priority, :desc, 0, 20)

      assert first.priority == 4
      assert last.priority == 3
    end

    test "list_folders_filtering_and_sorting/6 returns filtered and ordered folders incrementally" do
      %Folder{} = folder_fixture(%{item_name: "name", priority: 4})
      %Folder{} = folder_fixture(%{item_name: "name", priority: 3})
      %Folder{} = folder_fixture(%{priority: 1})

      {:ok, [first | [last]]} =
        Folders.list_folders_filtering_and_sorting(:item_name, "name", :priority, :asc, 0, 20)

      assert first.priority == 3
      assert last.priority == 4
    end

    test "list_folders_filtering_and_sorting/6 returns filtered and ordered folders containing its path_name" do
      %Folder{id: root_id} = folder_fixture(%{item_name: "filter", priority: 3})

      %Folder{id: folder_id} =
        folder_fixture(%{item_name: "filter", priority: 2, parent_id: root_id})

      %Folder{} = folder_fixture(%{item_name: "filter", priority: 1, parent_id: folder_id})
      %Folder{} = folder_fixture(%{item_name: "other_filter", priority: 6})

      order_method = Enum.random([:desc, :asc])

      {:ok, filter_sort_folders} =
        Folders.list_folders_filtering_and_sorting(
          :item_name,
          "filter",
          :priority,
          order_method,
          0,
          20
        )

      expected_path_names = ["filter", "filter/filter", "filter/filter/filter"]

      Enum.each(filter_sort_folders, fn folder ->
        assert folder.path_name in expected_path_names
      end)
    end

    test "list_folders_filtering_and_sorting/6 when clause not matching" do
      {:error, error} =
        Folders.list_folders_filtering_and_sorting(:item_name, "name", :other_field, :desc, 0, 20)

      assert error == "Invalid arguments received"
    end
  end

  describe "get folder" do
    test "get_folder!/1 returns the folder with given id" do
      folder = folder_fixture()
      assert Folders.get_folder!(folder.id) == folder
    end
  end

  describe "create folder" do
    test "create_folder/1 with valid data creates a folder" do
      valid_attrs = %{item_name: "some item_name", parent_id: nil, priority: 42}

      assert {:ok, %Folder{} = folder} = Folders.create_folder(valid_attrs)
      assert folder.item_name == "some item_name"
      assert folder.parent_id == nil
      assert folder.priority == 42
    end

    test "create_folder/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Folders.create_folder(@invalid_attrs)
    end

    test "create_folder/1 with child" do
      parent_folder = folder_fixture()

      valid_attrs = %{item_name: "some item_name", parent_id: parent_folder.id, priority: 42}

      assert {:ok, %Folder{} = folder} = Folders.create_folder(valid_attrs)
      assert folder.item_name == "some item_name"
      assert folder.parent_id == parent_folder.id
      assert folder.priority == 42
    end
  end

  describe "update folder" do
    test "update_folder/2 with valid data updates the folder" do
      folder = folder_fixture()
      update_attrs = %{item_name: "some updated item_name", parent_id: nil, priority: 43}

      assert {:ok, %Folder{} = folder} = Folders.update_folder(folder, update_attrs)
      assert folder.item_name == "some updated item_name"
      assert folder.parent_id == nil
      assert folder.priority == 43
    end

    test "update_folder/2 with invalid data returns error changeset" do
      folder = folder_fixture()

      assert {:error, %Ecto.Changeset{}} = Folders.update_folder(folder, @invalid_attrs)
      assert folder == Folders.get_folder!(folder.id)
    end
  end

  describe "delete folder" do
    test "delete_folder/1 deletes the folder" do
      folder = folder_fixture()

      assert {:ok, %Folder{}} = Folders.delete_folder(folder)
      assert_raise Ecto.NoResultsError, fn -> Folders.get_folder!(folder.id) end
    end
  end

  describe "change folder" do
    test "change_folder/1 returns a folder changeset" do
      folder = folder_fixture()

      assert %Ecto.Changeset{} = Folders.change_folder(folder)
    end
  end
end
