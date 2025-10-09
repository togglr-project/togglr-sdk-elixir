defmodule TogglrSdk.JasonEncoders do
  @moduledoc """
  Manual Jason.Encoder implementations for generated models.
  """

  defimpl Jason.Encoder, for: SDKAPI.Model.FeatureErrorReport do
    def encode(struct, opts) do
      Jason.Encode.map(%{
        error_type: struct.error_type,
        error_message: struct.error_message,
        context: struct.context
      }, opts)
    end
  end
end
