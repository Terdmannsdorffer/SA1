defmodule Goodreads.ReleaseTasks do
  @app :goodreads

  def create do
    load_app()
    for repo <- repos() do
      {:ok, _} = Ecto.Adapters.SQL.query(repo, "CREATE DATABASE goodreads_dev", [])
    end
  end

  def migrate do
    load_app()
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def seed do
    load_app()
    for repo <- repos() do
      case Ecto.Migrator.with_repo(repo, &run_seeds_for/1) do
        {:ok, _, _} -> IO.puts("Seeding complete!")
        {:error, reason} -> IO.puts("Seeding failed: #{inspect(reason)}")
      end
    end
  end

  defp run_seeds_for(repo) do
    seed_script = Path.join([priv_dir(repo), "seeds.exs"])

    if File.exists?(seed_script) do
      IO.puts("Running seed script: #{seed_script}")
      Code.eval_file(seed_script)
    else
      IO.puts("Seed script not found: #{seed_script}")
    end
  end

  defp priv_dir(repo) do
    app = Keyword.get(repo.config, :otp_app)
    "#{:code.priv_dir(app)}/repo"
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
