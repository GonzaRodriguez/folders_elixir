defmodule ProdealElixir.PaginationParams do
  use ProdealElixirWeb, :params
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :page, :integer, default: 1
    field :per_page, :integer, default: 2
  end

  @per_page_default 2

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:page, :per_page])
    |> validate_number(:page, greater_than_or_equal_to: 1)
    |> validate_number(:per_page, greater_than_or_equal_to: 1)
    |> validate_number(:per_page, less_than_or_equal_to: 50)
  end

  def per_page_default, do: @per_page_default
end
