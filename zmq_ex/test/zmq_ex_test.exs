defmodule ZmqExTest do
  use ExUnit.Case
  import ZmqEx
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
end