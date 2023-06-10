defmodule Clipboard.Support.Factory do
  use ExMachina.Ecto, repo: Clipboard.Repo

  alias Clipboard.Schema.Facility
  alias Clipboard.Schema.Shift
  alias Clipboard.Schema.Worker
  alias Clipboard.Schema.Document

  @profession_list Clipboard.Constant.profession_list()

  def worker_factory() do
    %Worker{
      name: Faker.Person.En.first_name(),
      is_active: true,
      profession: Enum.random(@profession_list)
    }
  end

  def document_factory() do
    %Document{
      name: Faker.File.file_name(),
      is_active: true
    }
  end

  def facility_factory() do
    %Facility{
      name: Faker.Person.En.first_name(),
      is_active: true
    }
  end

  def shift_factory() do
    start = NaiveDateTime.add(NaiveDateTime.local_now(), Enum.random(10..120), :minute)

    %Shift{
      start: start,
      end: NaiveDateTime.add(start, Enum.random(30..120), :minute),
      profession: Enum.random(@profession_list),
      is_deleted: false,
      facility: build(:facility)
    }
  end
end
