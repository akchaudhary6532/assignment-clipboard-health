defmodule Clipboard.Schema.DocumentWorker do
  use Ecto.Schema
  import Ecto.Changeset

  alias Clipboard.Schema.Document
  alias Clipboard.Schema.Worker

  @fields ~w(worker_id document_id)a

  @type t :: %{
          required(:worker_id) => integer(),
          required(:document_id) => integer()
        }

  schema "DocumentWorker" do
    belongs_to :worker, Worker
    belongs_to :document, Document
  end

  def new(attrs), do: changeset(%__MODULE__{}, attrs)

  @spec changeset(Ecto.Schema.t() | t(), t()) :: Ecto.Changeset.t()
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
