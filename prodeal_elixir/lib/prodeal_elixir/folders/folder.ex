defmodule ProdealElixir.Folders.Folder do
  use Ecto.Schema
  import Ecto.Changeset

  schema "folders" do
    field :item_name, :string
    field :priority, :integer
    field :path_name, :string, virtual: true

    belongs_to :parent, ProdealElixir.Folders.Folder

    timestamps()
  end

  @doc false
  def changeset(folder, attrs) do
    folder
    |> cast(attrs, [:parent_id, :item_name, :priority])
    |> validate_required([:item_name, :priority])
  end
end
