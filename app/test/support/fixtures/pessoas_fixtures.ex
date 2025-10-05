defmodule Rinha.PessoasFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Rinha.Pessoas` context.
  """

  @doc """
  Generate a pessoa.
  """
  def pessoa_fixture(attrs \\ %{}) do
    {:ok, pessoa} =
      attrs
      |> Enum.into(%{
        apelido: "some apelido",
        nascimento: ~D[2025-10-02],
        nome: "some nome",
        stack: ["option1", "option2"]
      })
      |> Rinha.Pessoas.create_pessoa()

    pessoa
  end
end
