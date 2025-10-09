defmodule TogglrSdk.ProtocolDerivations do
  @moduledoc """
  Runtime protocol derivations for generated models.

  This module sets up Jason.Encoder for generated models that don't have it by default.
  """

  require Protocol

  def setup do
    # Load manual Jason.Encoder implementations
    Code.ensure_loaded(TogglrSdk.JasonEncoders)
  end

end
