# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ProdealElixir.Repo.insert!(%ProdealElixir.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ProdealElixir.Folders
alias ProdealElixir.Repo

defmodule ProdealElixir.Seeds do
  def store_it({:ok, row_data}) do
    row_data
    |> sanitize_attributes()
    |> Folders.create_folder()
  end

  def store_it({:erroe, _row_data}), do: nil

  defp sanitize_attributes(%{parent_id: parent_id} = attrs) when parent_id == "nil" do
    Map.merge(attrs, %{parent_id: nil})
  end

  defp sanitize_attributes(%{parent_id: parent_id} = attrs) do
    Map.merge(attrs, %{parent_id: String.to_integer(parent_id)})
  end
end

File.stream!("priv/repo/seed_data/seed_data.csv")
|> Stream.drop(1)
|> CSV.decode(headers: [:id, :parent_id, :item_name, :priority])
|> Enum.each(&ProdealElixir.Seeds.store_it/1)
