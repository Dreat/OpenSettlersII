defmodule ZmqEx do
    use Bitwise

    def encode(%{flags: flags, size: size, body: body}) do
        <<encode_flags(flags), size, body>>
    end

    def decode(<<flags :: size(8), rest :: binary>>) do
        decode_flags(flags)
        |> decode(rest)
    end

    defp decode(flags = %{type: _, long: :short, more: _}, <<size :: size(8), body :: binary>>) do
        %{flags: flags, size: size, body: body}
    end

    defp decode(flags = %{type: _, long: :long, more: _}, <<size :: (64), body :: binary>>) do
        %{flags: flags, size: size, body: body}
    end

    defp encode_flags(%{type: :message, long: :short, more: false}), do: 0
    defp encode_flags(%{type: :message, long: :short, more: true}), do: 1
    defp encode_flags(%{type: :message, long: :long, more: false}), do: 2
    defp encode_flags(%{type: :message, long: :long, more: true}), do: 3
    defp encode_flags(%{type: :command, long: :short, more: false}), do: 4
    defp encode_flags(%{type: :command, long: :long, more: false}), do: 5
    defp encode_flags(_), do: {:error}

    defp decode_flags(0), do: %{type: :message, long: :short, more: false}
    defp decode_flags(1), do: %{type: :message, long: :short, more: true}
    defp decode_flags(2), do: %{type: :message, long: :long, more: false}
    defp decode_flags(3), do: %{type: :message, long: :long, more: true}
    defp decode_flags(4), do: %{type: :command, long: :short, more: false}
    defp decode_flags(5), do: %{type: :command, long: :long, more: false}
    defp decode_flags(_), do: {:error}

end
