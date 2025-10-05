defmodule RinhaWeb.PessoaControllerTest do
  use RinhaWeb.ConnCase

  import Rinha.PessoasFixtures
  alias Rinha.Pessoas.Pessoa

  @create_attrs %{
    stack: ["option1", "option2"],
    apelido: "some apelido",
    nome: "some nome",
    nascimento: ~D[2025-10-02]
  }
  @update_attrs %{
    stack: ["option1"],
    apelido: "some updated apelido",
    nome: "some updated nome",
    nascimento: ~D[2025-10-03]
  }
  @invalid_attrs %{stack: nil, apelido: nil, nome: nil, nascimento: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all pessoas", %{conn: conn} do
      conn = get(conn, ~p"/pessoas")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create pessoa" do
    test "renders pessoa when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/pessoas", pessoa: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/pessoas/#{id}")

      assert %{
               "id" => ^id,
               "apelido" => "some apelido",
               "nascimento" => "2025-10-02",
               "nome" => "some nome",
               "stack" => ["option1", "option2"]
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/pessoas", pessoa: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update pessoa" do
    setup [:create_pessoa]

    test "renders pessoa when data is valid", %{conn: conn, pessoa: %Pessoa{id: id} = pessoa} do
      conn = put(conn, ~p"/pessoas/#{pessoa}", pessoa: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/pessoas/#{id}")

      assert %{
               "id" => ^id,
               "apelido" => "some updated apelido",
               "nascimento" => "2025-10-03",
               "nome" => "some updated nome",
               "stack" => ["option1"]
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, pessoa: pessoa} do
      conn = put(conn, ~p"/pessoas/#{pessoa}", pessoa: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete pessoa" do
    setup [:create_pessoa]

    test "deletes chosen pessoa", %{conn: conn, pessoa: pessoa} do
      conn = delete(conn, ~p"/pessoas/#{pessoa}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/pessoas/#{pessoa}")
      end
    end
  end

  defp create_pessoa(_) do
    pessoa = pessoa_fixture()

    %{pessoa: pessoa}
  end
end
