defmodule RiotApiWeb.Router do
  use RiotApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RiotApiWeb do
    pipe_through :api
  end
end
