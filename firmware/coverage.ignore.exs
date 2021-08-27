defmodule QcxControl.Coverage do
  @moduledoc """
  Code coverage helpers
  """

  @doc """
  A list of modules to ignore when code coverage runs.
  """
  def ignore_modules do
    [
      # QcxControl,
      QcxControl.Application
    ]
  end
end
