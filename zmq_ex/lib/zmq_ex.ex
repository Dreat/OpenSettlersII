defmodule ZmqEx do

    def version(%{major: major, minor: minor}) do
        {:ok, <<major, minor>>}
    end

    def version(<<major, minor>>) do
        {:ok, %{major: major, minor: minor}}
    end

    def as_server(<<as_server>>) do
        as_server_convert(as_server)
    end

    defp as_server_convert(1) do
        {:ok, true}
    end

    defp as_server_convert(0) do
        {:ok, false}
    end

    defp as_server_convert(_) do
        {:error, :wrong_as_server}
    end

    def encode(%{flags: flags = %{type: _, long: :short, more: _}, size: size, body: <<body>>}) do
        <<encode_flags(flags), size :: size(8), body>>
    end

    def encode(%{flags: flags = %{type: _, long: :long, more: _}, size: size, body: <<body>>}) do
        <<encode_flags(flags), size :: size(64), body>>
    end

    def decode(<<flags :: size(8), rest :: binary>>) do
        decode_flags(flags)
        |> decode(rest)
    end

    def encode_command(%{name: name, size: 0, data: <<_data :: binary>>}) do
        %{flags: %{type: :command, long: :short, more: false}, size: 8, body: name }
    end

    def encode_command(%{name: name, size: 56, data: <<data :: binary>>}) do
        %{flags: %{type: :command, long: :long, more: false}, size: 64, body: name <> data}  
    end

    def decode_command(%{flags: %{type: :command, long: :short, more: false}, size: _size, body: body}) do
        <<name::binary-size(8), command_body :: binary>> = body
        %{name: name, size: 0, data: command_body}
    end

    def decode_command(%{flags: %{type: :command, long: _, more: false}, size: _size, body: body}) do
        <<name::binary-size(8), command_body :: binary>> = body
        %{name: name, size: 56, data: command_body}
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
