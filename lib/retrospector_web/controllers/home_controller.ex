defmodule RetrospectorWeb.HomeController do
  use RetrospectorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
