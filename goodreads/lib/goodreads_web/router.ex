defmodule GoodreadsWeb.Router do
  use GoodreadsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GoodreadsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GoodreadsWeb do
    pipe_through :browser

    get "/", PageController, :home

    resources "/authors", AuthorController
    resources "/books", BookController
    resources "/reviews", ReviewController
    resources "/sales", SaleController

    get "/authors_stats", AuthorController, :authors_stats
    get "/top_50", AuthorController, :top_50
    get "/search", BookController, :search


    get "/top_books", BookController, :top_books

    get "/top_books_with_reviews", BookController, :top_books_with_reviews

    get "/all_books", BookController, :all_books
    get "/totem", BookController, :totem
    get "/check_opensearch", BookController, :check_opensearch
    get "/query_of_all_books", BookController, :query_of_all_books

  end

  # Other scopes may use custom stacks.
  # scope "/api", GoodreadsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:goodreads, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GoodreadsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
