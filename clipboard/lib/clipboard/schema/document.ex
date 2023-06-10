defmodule Clipboard.Schema.Document do
  @moduledoc """
  Schema file for Document
  """
  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(name is_active)a

  @type t :: %{
          required(:name) => String.t(),
          required(:is_active) => boolean()
        }

  schema "Document" do
    field :name, :string
    field :is_active, :boolean
  end

  @spec changeset(Ecto.Schema.t() | t(), t()) :: Ecto.Changeset.t()
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
