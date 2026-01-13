import Config

# Configure release based on environment variables
config :elixir_app,
  node_name: System.get_env("NODE_NAME", "elixir_app"),
  pod_ip: System.get_env("POD_IP", "127.0.0.1"),
  node_name_type: System.get_env("NODE_NAME_TYPE", "sname")
