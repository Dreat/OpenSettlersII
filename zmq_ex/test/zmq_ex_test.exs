defmodule ZmqExTest do
  use ExUnit.Case
  doctest ZmqEx

  test "decode basic message frame" do
    result = ZmqEx.decode(<<0, 1, 1>>)
    assert result == %{flags: %{type: :message, long: :short, more: false}, size: 1, body: <<1>>}
  end

  test "decode basic command frame" do
    result = ZmqEx.decode(<<4, 1, 3>>)
    assert result == %{flags: %{type: :command, long: :short, more: false}, size: 1, body: <<3>>}
  end

  test "decode long message frame" do
    result = ZmqEx.decode(<<2, 256 :: size(64), 256>>)
    assert result == %{flags: %{type: :message, long: :long, more: false}, size: 256, body: <<256>>}
  end

  test "decode long command frame" do
    result = ZmqEx.decode(<<5, 256 :: size(64), 256>>)
    assert result == %{flags: %{type: :command, long: :long, more: false}, size: 256, body: <<256>>}
  end

  test "encode basic message frame" do
    result = ZmqEx.encode(%{flags: %{type: :message, long: :short, more: false}, size: 1, body: <<1>>})
    assert result == (<<0, 1, 1>>)
  end

  test "encode basic command frame" do
    result = ZmqEx.encode(%{flags: %{type: :command, long: :short, more: false}, size: 1, body: <<3>>})
    assert result == (<<4, 1, 3>>)
  end

  test "encode long message frame" do
    result = ZmqEx.encode(%{flags: %{type: :message, long: :short, more: false}, size: 1, body: <<1>>})
    assert result == (<<0, 1, 1>>)
  end

  test "encode long command frame" do
    result = ZmqEx.encode(%{flags: %{type: :command, long: :short, more: false}, size: 1, body: <<3>>})
    assert result == (<<4, 1, 3>>)
  end

  test "encode short command" do
    result = ZmqEx.encode_command(%{name: "command1", size: 0, data: << 0 >>})
    assert result == %{flags: %{type: :command, long: :short, more: false}, size: 8, body: <<"command1">>}
  end

  test "encode long command" do
    result = ZmqEx.encode_command(%{name: "command2", size: 56, data: "A command body"})
    assert result == %{flags: %{type: :command, long: :long, more: false}, size: 64, body: <<"command2A command body">>}
  end

  test "decode short command" do
    result = ZmqEx.decode_command(%{flags: %{type: :command, long: :short, more: false}, size: 8, body: "command1"})
    assert result == %{name: "command1", size: 0, data: ""}
  end

  test "decode long command" do
    result = ZmqEx.decode_command(%{flags: %{type: :command, long: :long, more: false}, size: 64, body: "command2A command body"})
    assert result == %{name: "command2", size: 56, data: "A command body"}
  end

  test "test acting as a server" do
    result = ZmqEx.as_server(<<1>>)
    assert result == {:ok, true}
  end

  test "test acting not as a server" do
    result = ZmqEx.as_server(<<0>>)
    assert result == {:ok, false}
  end

  test "test wrong as a server value" do
    result = ZmqEx.as_server(<<2>>)
    assert result == {:error, :wrong_as_server}
  end

  test "decode version" do
    result = ZmqEx.version(<<3,0>>)
    assert result == {:ok, %{major: 3, minor: 0}}
  end

  test "encode version" do
    result = ZmqEx.version(%{major: 3, minor: 1})
    assert result == {:ok, <<3, 1>>}
  end

end