defmodule Pillar.MigrationsMacro do
  @moduledoc """
  Migration's mechanism

  For generation migration files use task `Mix.Tasks.Pillar.Gen.Migration`

  For launching migration define own mix task or release task with code below:

  ```
  conn = Pillar.Connection.new(connection_string)
  Pillar.Migrations.migrate(conn)
  ```
  """

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defmacro __using__(args) when is_list(args) do
    path_prefix = Keyword.get(args, :path_prefix)
    otp_app = Keyword.get(args, :otp_app)

    quote do
      alias Pillar.Connection
      alias Pillar.Migrations.Generator
      alias Pillar.Migrations.Migrate
      alias Pillar.Migrations.Rollback

      @default_path_suffix "priv/pillar_migrations"
      @path_suffix Keyword.get(unquote(args), :path_suffix, @default_path_suffix)
      @options Keyword.get(unquote(args), :options, []) |> Enum.into(%{})

      def generate(name) do
        template = Generator.migration_template(name)

        with filepath <- Generator.migration_filepath(name, migrations_path()),
             :ok <- File.mkdir_p!(Path.dirname(filepath)),
             :ok <- File.write!(filepath, template) do
          filepath
        end
      end

      def migrate(%Connection{} = conn, path \\ nil) do
        Migrate.run_all_migrations(conn, path || migrations_path(), @options)
      end

      def rollback(%Connection{} = conn, path \\ nil, count_of_migrations \\ 1) do
        Rollback.rollback_n_migrations(
          conn,
          path || migrations_path(),
          count_of_migrations,
          @options
        )
      end

      @doc """
      Directory, where contains list of migrations.

      Warning: In case of build releases directory should be copied with app
      """
      def migrations_path do
        Path.join([get_path_prefix(), @path_suffix])
      end

      defp get_path_prefix do
        cond do
          is_binary(unquote(path_prefix)) -> unquote(path_prefix)
          is_nil(unquote(otp_app)) -> ""
          is_atom(unquote(otp_app)) -> Application.app_dir(unquote(otp_app))
          :otherwise -> ""
        end
      end
    end
  end
end
