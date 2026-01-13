defmodule ElixirApp do
  @moduledoc """
  Minimal Elixir app for kubectl-beam testing.
  """

  def info do
    %{
      node: node(),
      version: "0.1.0"
    }
  end
end
