defmodule Clipboard.Schema.Shift do
  use Ecto.Schema
  import Ecto.Changeset

  alias Clipboard.Schema.Facility
  alias Clipboard.Schema.Worker

  @required ~w(start end profession is_deleted facility_id)a
  @fields @required ++ ~w(worker_id)a
  @profession_list Clipboard.Constant.profession_list()

  @type t :: %{
          required(:start) => NaiveDateTime.t(),
          required(:end) => NaiveDateTime.t(),
          required(:profession) => String.t(),
          required(:is_deleted) => boolean(),
          required(:facility_id) => integer(),
          optional(:worker_id) => integer()
        }

  schema "Shift" do
    field :start, :naive_datetime
    field :end, :naive_datetime
    field :profession, Ecto.Enum, values: @profession_list
    field :is_deleted, :boolean
    belongs_to :facility, Facility
    belongs_to :worker, Worker
  end

  def new(attrs), do: changeset(%__MODULE__{}, attrs)

  @spec changeset(Ecto.Schema.t() | t(), t()) :: Ecto.Changeset.t()
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end
end
