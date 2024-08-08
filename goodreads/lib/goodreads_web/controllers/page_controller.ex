defmodule GoodreadsWeb.PageController do
  use GoodreadsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
