defmodule ProdealElixirWeb.FolderView do
  use ProdealElixirWeb, :view
  alias ProdealElixirWeb.FolderView

  def render("index.json", %{folders: folders, pagination_data: pagination_data}) do
    %{
      data: render_many(folders, FolderView, "folder.json"),
      pagination_data: pagination_data
    }
  end

  def render("folder.json", %{folder: folder}) do
    %{
      id: folder.id,
      parent_id: folder.parent_id,
      item_name: folder.item_name,
      priority: folder.priority,
      path_name: folder.path_name
    }
  end
end
