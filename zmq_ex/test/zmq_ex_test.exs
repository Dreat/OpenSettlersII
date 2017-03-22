defmodule ZmqExTest do
  use ExUnit.Case
  import ZmqEx
  doctest ZmqEx

  test "decode basic message frame" do
    result = ZmqEx.decode(<<0, 1, 1>>)
    assert result == %{flags: %{reserved: 0, command: :message, long: :short, more: false}, size: 1, body: 1}
  end

  test "decode basic command frame" do
    result = ZmqEx.decode(<<4, 1, 3>>)
    assert result == %{flags: %{reserved: 0, command: :command, long: :short, more: false}, size: 1, body: 3}
  end

  test "encode basic message frame" do
    result = ZmqEx.encode(%{flags: %{reserved: 0, command: :message, long: :short, more: false}, size: 1, body: 1})
    assert result == (<<0, 1, 1>>)
  end

  test "encode basic command frame" do
    result = ZmqEx.encode(%{flags: %{reserved: 0, command: :command, long: :short, more: false}, size: 1, body: 3})
    assert result == (<<4, 1, 3>>)
  end
end