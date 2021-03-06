<img src="../web/public/images/logo.png" height="68" />

# ElixirBench Runner

[![Travis build](https://secure.travis-ci.org/tallysmartins/elixir-bench-runner.svg?branch=master
"Build Status")](https://travis-ci.org/tallysmartins/elixir-bench-runner)

[![Travis build](https://secure.travis-ci.org/elixir-bench/elixir-bench-runner.svg?branch=master
"Build Status")](https://travis-ci.org/elixir-bench/elixir-bench-runner)

This is an Elixir daemon that pulls for job our API and executes tests in `runner-container`.

## Dependencies

Benchmarks are running inside a docker container, so you need to have
[`docker`](https://docs.docker.com/engine/installation/) and
[`docker-compose`](https://docs.docker.com/compose/install/) installed.

## Deployment

To build the release you can use `mix release`. The relese requires a `RUNNER_API_URL`, `RUNNER_API_KEY` and `RUNNER_API_USER`
environment variables for communication with the API server.

The server needs to have proper credentials for the runner configured as well. This can be done from
the release console using:
```elixir
ElixirBench.Benchmarks.create_runner(%{api_key: some_key, name: some_name})
```

## License

ElixirBench Runner is released under the Apache 2.0 License - see the [LICENSE](LICENSE.md) file.
