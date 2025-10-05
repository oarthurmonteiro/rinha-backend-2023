defmodule RinhaWeb.PageController do
  use RinhaWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
