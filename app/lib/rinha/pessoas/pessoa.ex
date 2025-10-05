defmodule Rinha.Pessoas.Pessoa do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pessoas" do
    field :apelido, :string
    field :nome, :string
    field :nascimento, :date
    field :stack, {:array, :string}
    field :busca, :string

  end

  @doc false
  def changeset(pessoa, attrs) do
    pessoa
    |> cast(attrs, [:apelido, :nome, :nascimento, :stack])
    |> validate_required([:apelido, :nome, :nascimento, :stack])
    |> validate_length(:apelido, min: 1, max: 32)
    |> unique_constraint(:apelido, name: :pessoas_apelido_key)
    |> validate_length(:nome, min: 1, max: 100)
    |> validate_stack()
    |> gerar_busca()
  end

  # Custom function to populate `busca`
  defp gerar_busca(changeset) do
    apelido = get_field(changeset, :apelido) || ""
    nome = get_field(changeset, :nome) || ""
    stack = get_field(changeset, :stack) || []

    busca_value = Enum.join([apelido, nome | stack], " ") |> String.downcase()

    put_change(changeset, :busca, busca_value)
  end

  # custom validator for the stack array
  defp validate_stack(changeset) do
    validate_change(changeset, :stack, fn :stack, stack ->
      cond do
        not is_list(stack) ->
          [stack: "must be a list of strings"]

        Enum.any?(stack, &(!is_binary(&1))) ->
          [stack: "all items must be strings"]

        Enum.any?(stack, &(String.length(&1) > 32)) ->
          [stack: "each technology must be at most 32 characters"]

        true ->
          []
      end
    end)
  end
end
