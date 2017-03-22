defmodule ZmqEx do
    use Bitwise

    def encode(%{flags: flags, size: size, body: body}) do
        <<encode_flags(flags), size, body>>
    end

    def decode(<<flags, size, body>>) do
        case flags &&& 7 do
              0 -> %{flags: %{reserved: 0, command: :message, long: :short, more: false}, size: size, body: body}
              1 -> %{flags: %{reserved: 0, command: :message, long: :short, more: true}, size: size, body: body}
              2 -> %{flags: %{reserved: 0, command: :message, long: :long, more: false}, size: size, body: body}
              3 -> %{flags: %{reserved: 0, command: :message, long: :long, more: true}, size: size, body: body}
              4 -> %{flags: %{reserved: 0, command: :command, long: :short, more: false}, size: size, body: body}
              5 -> %{flags: %{reserved: 0, command: :command, long: :long, more: false}, size: size, body: body}    
              _ -> {:error}
        end
    end

    defp encode_flags(%{reserved: 0, command: :message, long: :short, more: false}), do: 0
    defp encode_flags(%{reserved: 0, command: :message, long: :short, more: true}), do: 1
    defp encode_flags(%{reserved: 0, command: :message, long: :long, more: false}), do: 2
    defp encode_flags(%{reserved: 0, command: :message, long: :long, more: true}), do: 3
    defp encode_flags(%{reserved: 0, command: :command, long: :short, more: false}), do: 4
    defp encode_flags(%{reserved: 0, command: :command, long: :long, more: false}), do: 5
    defp encode_flags(_), do: {:error}
end
