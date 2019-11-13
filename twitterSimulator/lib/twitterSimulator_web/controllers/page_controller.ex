defmodule TwitterSimulatorWeb.PageController do
  use TwitterSimulatorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
