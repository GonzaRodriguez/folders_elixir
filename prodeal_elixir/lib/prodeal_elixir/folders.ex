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
  @spec list_folders() :: {:ok, [%Folder{}]}
  def list_folders() do
    query = from(f in Folder, select: f)

    {:ok, Repo.all(query)}
  end

  @doc """
  Lists folders supporting pagination.
  """
  @spec list_folders(integer(), integer()) :: {:ok, [%Folder{}]}
  def list_folders(offset, limit) do
    query = from(f in Folder, limit: ^limit, offset: ^offset, select: f)

    {:ok, Repo.all(query)}
  end

  @doc """
  Lists folders filtering by item_name.
  """
  @spec list_folders_filtering(filter_by :: atom, filter :: String.t(), integer(), integer()) ::
          {:ok, [%Folder{}]} | {:error, String.t()}
  def list_folders_filtering(:item_name, filter, offset, limit) do
    query =
      from f in Folder, where: f.item_name == ^filter, limit: ^limit, offset: ^offset, select: f

    {:ok, Repo.all(query)}
  end

  def list_folders_filtering(_filter_by, _filter, _offset, _limit),
    do: {:error, "Invalid arguments received when filtering by item_name"}

  @doc """
  Lists folders sorting by priority.
  """
  @spec list_folders_sorting(sort_by :: atom, order_by :: String.t(), integer(), integer()) ::
          {:ok, [%Folder{}]} | {:error, String.t()}
  def list_folders_sorting(:priority, :desc, offset, limit) do
    query =
      from f in Folder, order_by: [desc: f.priority], limit: ^limit, offset: ^offset, select: f

    {:ok, Repo.all(query)}
  end

  def list_folders_sorting(:priority, :asc, offset, limit) do
    query =
      from f in Folder, order_by: [asc: f.priority], limit: ^limit, offset: ^offset, select: f

    {:ok, Repo.all(query)}
  end

  def list_folders_sorting(_sort_by, _order_by, _offset, _limit),
    do: {:error, "Invalid arguments received when sorting by priority"}

  @doc """
  Lists folders sorting and filtering by priority and item_name respectively.
  """
  @spec list_folders_filtering_and_sorting(
          filter_by :: atom,
          filter :: String.t(),
          sort_by :: atom,
          order_by :: String.t(),
          integer(),
          integer()
        ) :: {:ok, [%Folder{}]} | {:error, String.t()}
  def list_folders_filtering_and_sorting(:item_name, filter, :priority, :asc, offset, limit) do
    query =
      from f in Folder,
        where: f.item_name == ^filter,
        order_by: [asc: f.priority],
        limit: ^limit,
        offset: ^offset,
        select: f

    {:ok, Repo.all(query)}
  end

  def list_folders_filtering_and_sorting(:item_name, filter, :priority, :desc, offset, limit) do
    query =
      from f in Folder,
        where: f.item_name == ^filter,
        order_by: [desc: f.priority],
        limit: ^limit,
        offset: ^offset,
        select: f

    {:ok, Repo.all(query)}
  end

  def list_folders_filtering_and_sorting(
        _filter_by,
        _filter,
        _sort_by,
        _order_by,
        _offset,
        _limit
      ),
      do: {:error, "Invalid arguments received"}

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
