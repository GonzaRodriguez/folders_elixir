defmodule ProdealElixir.Folders do
  @moduledoc """
  The Folders context.
  """

  import Ecto.Query, warn: false
  alias ProdealElixir.Repo

  alias ProdealElixir.Folders.Folder

  @doc """
  Returns the list of folders.
  """
  def list_folders do
    Repo.all(Folder)
  end

  @doc """
  Gets folders by item_name.
  """
  @spec get_folders_by(filter_by :: atom, filter :: String.t()) ::
          {:ok, [%Folder{}]} | {:error, String.t()}
  def get_folders_by(:item_name, filter) do
    query = from f in Folder, where: f.item_name == ^filter, select: f

    {:ok, Repo.all(query)}
  end

  def get_folders_by(_filter_by, _filter), do: {:error, :invalid_filtering_arguments}

  @doc """
  Gets a single folder.
  """
  def get_folder!(id), do: Repo.get!(Folder, id)

  @doc """
  Creates a folder.
  """
  def create_folder(attrs \\ %{}) do
    %Folder{}
    |> Folder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a folder.
  """
  def update_folder(%Folder{} = folder, attrs) do
    folder
    |> Folder.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a folder.
  """
  def delete_folder(%Folder{} = folder) do
    Repo.delete(folder)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking folder changes.
  """
  def change_folder(%Folder{} = folder, attrs \\ %{}) do
    Folder.changeset(folder, attrs)
  end
end
