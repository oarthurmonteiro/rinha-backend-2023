defmodule RinhaWeb.PessoaController do
  use RinhaWeb, :controller

  alias Rinha.Pessoas
  alias Rinha.Pessoas.Pessoa

  action_fallback RinhaWeb.FallbackController

  def index(conn, %{"t" => t}) when is_binary(t) do
    pessoas = Pessoas.listar_pessoas(t)
    render(conn, :index, pessoas: pessoas)
  end

  def index(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing required query parameter: t"})
  end

  def create(conn, pessoa_params) do
    with {:ok, %Pessoa{} = pessoa} <- Pessoas.create_pessoa(pessoa_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/pessoas/#{pessoa}")
      |> render(:show, pessoa: pessoa)
    end
  end

  def show(conn, %{"id" => id}) do
    pessoa = Pessoas.get_pessoa!(id)
    render(conn, :show, pessoa: pessoa)
  end

  def update(conn, %{"id" => id, "pessoa" => pessoa_params}) do
    pessoa = Pessoas.get_pessoa!(id)

    with {:ok, %Pessoa{} = pessoa} <- Pessoas.update_pessoa(pessoa, pessoa_params) do
      render(conn, :show, pessoa: pessoa)
    end
  end

  def delete(conn, %{"id" => id}) do
    pessoa = Pessoas.get_pessoa!(id)

    with {:ok, %Pessoa{}} <- Pessoas.delete_pessoa(pessoa) do
      send_resp(conn, :no_content, "")
    end
  end

  def contagem(conn, _params) do
    total = Pessoas.contar_total()

    text(conn, Integer.to_string(total))
  end

  def health(conn, _params) do
    send_resp(conn, :ok, "OK")

  end
end
