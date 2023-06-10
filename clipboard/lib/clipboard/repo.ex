defmodule Clipboard.Repo do
  use Ecto.Repo,
    otp_app: :clipboard,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query

  def paginate(query, page, size) do
    limit = size + 1

    result =
      query
      |> limit(^limit)
      |> offset(^((page - 1) * size))
      |> __MODULE__.all()

    next = if limit - length(result) == 0, do: page + 1, else: -1
    result = if next > 0, do: List.delete_at(result, -1), else: result

    %{data: result, next: next}
  end
end
