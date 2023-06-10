defmodule Clipboard.Schema.FacilityRequirement do
  @moduledoc """
  Schema file for FacilityRequirement
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Clipboard.Schema.Document
  alias Clipboard.Schema.Facility

  @fields ~w(document_id facility_id)a

  @type t :: %{
          required(:document_id) => integer(),
          required(:facility_id) => integer()
        }

  schema "FacilityRequirement" do
    belongs_to :document, Document
    belongs_to :facility, Facility
  end

  def new(attrs), do: changeset(%__MODULE__{}, attrs)

  @spec changeset(Ecto.Schema.t() | t(), t()) :: Ecto.Changeset.t()
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
