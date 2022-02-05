defmodule ProdealElixirWeb.FolderView do
  use ProdealElixirWeb, :view
  alias ProdealElixirWeb.FolderView

  def render("index.json", %{folders: folders}) do
    %{data: render_many(folders, FolderView, "folder.json")}
  end

  def render("folder.json", %{folder: folder}) do
    %{
      id: folder.id,
      parent_id: folder.parent_id,
      item_name: folder.item_name,
      priority: folder.priority
    }
  end
end
