defmodule ElixirBench.Runner.Config.Parser do
  @moduledoc """
  This module is responsible for processing
  """

  def parse_yaml(content) do
    content
    |> YamlElixir.read_from_string(atoms!: true)
    |> validate_and_build_struct()
  end

  defp validate_and_build_struct(raw_config) when is_map(raw_config) do
    with {:ok, elixir_version} <- fetch_elixir_version(raw_config),
         {:ok, erlang_version} <- fetch_erlang_version(raw_config),
         {:ok, environment_variables} <- fetch_environment_variables(raw_config),
         {:ok, deps} <- fetch_deps(raw_config) do
      {:ok,
       %ElixirBench.Runner.Config{
         elixir_version: elixir_version,
         erlang_version: erlang_version,
         environment_variables: environment_variables,
         deps: deps
       }}
    end
  end

  defp validate_and_build_struct(_raw_config) do
    {:error, :malformed_config}
  end

  defp fetch_elixir_version(raw_config) do
    supported_elixir_versions = Confex.fetch_env!(:runner, :supported_elixir_versions)

    case Map.fetch(raw_config, "elixir") do
      :error ->
        {:ok, Confex.fetch_env!(:runner, :default_elixir_version)}

      {:ok, version} when is_binary(version) ->
        do_fetch_elixir_version(version, supported_elixir_versions)

      {:ok, _version} ->
        {:error, :malformed_elixir_version}
    end
  end

  defp do_fetch_elixir_version(version, supported_elixir_versions) do
    if version in supported_elixir_versions do
      {:ok, version}
    else
      {:error, {:unsupported_elixir_version, supported_versions: supported_elixir_versions}}
    end
  end

  defp fetch_erlang_version(raw_config) do
    supported_erlang_versions = Confex.fetch_env!(:runner, :supported_erlang_versions)

    case Map.fetch(raw_config, "erlang") do
      :error ->
        {:ok, Confex.fetch_env!(:runner, :default_erlang_version)}

      {:ok, version} when is_binary(version) ->
        do_fetch_erlang_version(version, supported_erlang_versions)

      {:ok, _version} ->
        {:error, :malformed_erlang_version}
    end
  end

  defp do_fetch_erlang_version(version, supported_erlang_versions) do
    if version in supported_erlang_versions do
      {:ok, version}
    else
      {:error, {:unsupported_erlang_version, supported_versions: supported_erlang_versions}}
    end
  end

  defp fetch_environment_variables(%{"environment" => environment_variables})
       when is_map(environment_variables) do
    errors =
      Enum.reject(environment_variables, fn {key, value} ->
        is_binary(key) and is_binary(value)
      end)

    if errors == [] do
      {:ok, stringify_values(environment_variables)}
    else
      {:error, {:invalid_environment_variables, errors}}
    end
  end

  defp fetch_environment_variables(%{"environment" => environment_variables}) do
    {:error, {:malformed_environment_variables, environment_variables}}
  end

  defp fetch_environment_variables(_raw_config) do
    {:ok, []}
  end

  defp fetch_deps(%{"deps" => %{"docker" => docker_deps}}) when is_list(docker_deps) do
    errors = Enum.reject(docker_deps, fn dep -> Map.has_key?(dep, "image") end)

    if errors == [] do
      deps = Enum.map(docker_deps, &stringify_environment(&1))
      {:ok, deps}
    else
      {:error, {:invalid_deps, errors}}
    end
  end

  defp fetch_deps(%{"deps" => %{"docker" => docker_deps}}) do
    {:error, {:malformed_deps, docker_deps}}
  end

  defp fetch_deps(_raw_config) do
    {:ok, []}
  end

  defp stringify_environment(%{"environment" => environment} = raw_config),
    do: Map.put(raw_config, "environment", stringify_values(environment))

  defp stringify_environment(raw_config), do: raw_config

  defp stringify_values(map) do
    for {key, value} <- map, do: {key, to_string(value)}, into: %{}
  end
end
