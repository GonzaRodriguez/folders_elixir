defmodule ProdealElixir.FoldersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ProdealElixir.Folders` context.
  """

  @doc """
  Generate a folder.
  """
  def folder_fixture(attrs \\ %{}) do
    {:ok, folder} =
      attrs
      |> Enum.into(%{
        item_name: "some item_name",
        parent_id: nil,
        priority: 42
      })
      |> ProdealElixir.Folders.create_folder()

    folder
  end
end
