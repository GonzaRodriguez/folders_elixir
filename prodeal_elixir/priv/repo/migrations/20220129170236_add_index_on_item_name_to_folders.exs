defmodule ProdealElixir.Repo.Migrations.AddIndexOnItemNameToFolders do
  use Ecto.Migration

  def change do
    create index(:folders, [:item_name])
  end
end
