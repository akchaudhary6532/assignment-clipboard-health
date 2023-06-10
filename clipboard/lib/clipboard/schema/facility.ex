defmodule Clipboard.Schema.Facility do
  @moduledoc """
  Schema file for Facility
  """
  alias Clipboard.Repo
  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(name is_active)a

  @type t :: %{
          required(:name) => String.t(),
          required(:is_active) => integer()
        }

  schema "Facility" do
    field :name, :string
    field :is_active, :boolean
  end

  @spec changeset(Ecto.Schema.t() | t(), t()) :: Ecto.Changeset.t()
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  def get_by_id(nil), do: nil
  def get_by_id(id), do: Repo.get(__MODULE__, id)
end
