defmodule Pillar.ConnectionTest do
  alias Pillar.Connection
  use ExUnit.Case

  test "#new - with all params" do
    assert %Connection{
             database: "some_database",
             scheme: "https",
             host: "localhost",
             user: "user",
             password: "password",
             port: 8123,
             max_query_size: 1024,
             version: _
           } =
             Connection.new(
               "https://user:password@localhost:8123/some_database?max_query_size=1024"
             )
  end

  test "#new - user without password" do
    assert %Connection{
             database: "default",
             host: "localhost",
             scheme: "http",
             user: "alice",
             password: nil,
             port: 8123,
             version: _
           } = Connection.new("http://alice@localhost:8123")
  end

  test "#new - minimum required params" do
    assert %Connection{
             database: "default",
             host: "localhost",
             scheme: "http",
             user: nil,
             password: nil,
             port: 8123,
             version: _
           } = Connection.new("http://localhost:8123")
  end

  describe "#url_from_connection" do
    test "build valid url" do
      connection = %Connection{
        database: "default",
        host: "localhost",
        scheme: "https",
        user: "user",
        password: "password",
        port: 8123
      }

      assert Connection.url_from_connection(connection) ==
               "https://localhost:8123/?user=user&database=default&password=password"
    end

    test "build valid url (no credentials and database)" do
      connection = %Connection{
        host: "localhost",
        scheme: "https",
        port: 8123
      }

      assert Connection.url_from_connection(connection) == "https://localhost:8123/?"
    end

    test "build valid url with db_side_batch_insertions" do
      connection = %Connection{
        database: "default",
        host: "localhost",
        scheme: "https",
        user: "user",
        password: "password",
        port: 8123
      }

      assert Connection.url_from_connection(connection) ==
               "https://localhost:8123/?user=user&database=default&password=password"

      options = %{db_side_batch_insertions: true}

      assert Connection.url_from_connection(connection, options) ==
               "https://localhost:8123/?user=user&database=default&password=password&async_insert=1"

      options = %{db_side_batch_insertions: false}

      assert Connection.url_from_connection(connection, options) ==
               "https://localhost:8123/?user=user&database=default&password=password"
    end
  end
end
