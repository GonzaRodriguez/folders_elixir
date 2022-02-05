defmodule ProdealElixir.Repo.Migrations.CreateFolders do
  use Ecto.Migration

  def change do
    create table(:folders) do
      add :parent_id, references(:folders)
      add :item_name, :string
      add :priority, :integer

      timestamps()
    end
  end
end
