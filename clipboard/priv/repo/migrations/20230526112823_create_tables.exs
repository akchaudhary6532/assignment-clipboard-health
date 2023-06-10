defmodule MyApp.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:Document, table_name: "Document", if_not_exists: true) do
      add :name, :text, null: false
      add :is_active, :boolean, null: false, default: false
    end

    create table(:Worker, table_name: "Worker", if_not_exists: true) do
      add :name, :text, null: false
      add :is_active, :boolean, null: false, default: false
      add :profession, :string, null: false
    end

    create table(:Facility, table_name: "Facility", if_not_exists: true) do
      add :name, :text, null: false
      add :is_active, :boolean, null: false, default: false
    end

    create table(:Shift, table_name: "Shift", if_not_exists: true) do
      add :start, :utc_datetime_usec, null: false
      add :end, :utc_datetime_usec, null: false
      add :profession, :string, null: false
      add :is_deleted, :boolean, null: false, default: false
      add :facility_id, references(:Facility, column: :id, on_delete: :restrict), null: false
      add :worker_id, references(:Worker, column: :id, on_delete: {:nilify, [:worker_id]})
    end

    create table(:DocumentWorker, table_name: "DocumentWorker", if_not_exists: true) do
      add :worker_id, references(:Worker, column: :id, on_delete: :restrict), null: false
      add :document_id, references(:Document, column: :id, on_delete: :restrict), null: false
    end

    create table(:FacilityRequirement, table_name: "FacilityRequirement", if_not_exists: true) do
      add :facility_id, references(:Facility, column: :id, on_delete: :restrict), null: false
      add :document_id, references(:Document, column: :id, on_delete: :restrict), null: false
    end
  end
end
