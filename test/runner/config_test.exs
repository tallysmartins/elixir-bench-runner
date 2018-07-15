defmodule ElixirBench.Runner.ConfigTest do
  use ExUnit.Case, async: true
  alias ElixirBench.Runner.Config

  describe "from_string_map/1" do
    test "return config struct given map attrs" do
      attrs = %{
        "elixir_version" => "1.6.6",
        "erlang_version" => "20.1.2",
        "environment_variables" => %{"MYSQL_URL" => "root@localhost"},
        "deps" => %{
          "docker" => [%{"container_name" => "postgres", "image" => "postgres:9.6.6-alpine"}]
        }
      }

      config = Config.from_string_map(attrs)

      assert %{
               elixir_version: "1.6.6",
               erlang_version: "20.1.2",
               environment_variables: %{"MYSQL_URL" => "root@localhost"},
               deps: [%{"container_name" => "postgres", "image" => "postgres:9.6.6-alpine"}]
             } = config
    end
  end
end
