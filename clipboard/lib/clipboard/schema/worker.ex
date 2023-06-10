defmodule Clipboard.Schema.Worker do
  @moduledoc """
  Schema file for Worker
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Clipboard.Repo

  @profession_list Clipboard.Constant.profession_list()
  @fields ~w(id name is_active profession)a

  @type t :: %{
          required(:name) => String.t(),
          required(:is_active) => boolean(),
          required(:profession) => String.t()
        }

  schema "Worker" do
    field :name, :string
    field :is_active, :boolean
    field :profession, Ecto.Enum, values: @profession_list
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
