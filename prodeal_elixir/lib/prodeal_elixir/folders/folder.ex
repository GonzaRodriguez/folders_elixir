defmodule ProdealElixir.Folders.Folder do
  use Ecto.Schema
  import Ecto.Changeset

  schema "folders" do
    field :item_name, :string
    field :priority, :integer

    belongs_to :parent, ProdealElixirTest.Folders.Folder

    timestamps()
  end

  @doc false
  def changeset(folder, attrs) do
    folder
    |> cast(attrs, [:parent_id, :item_name, :priority])
    |> validate_required([:item_name, :priority])
  end
end
