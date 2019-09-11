defmodule Project2 do
  use GenServer
  @moduledoc """
  Documentation for Project2.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Project2.hello()
      :world

  """
  def main do

    # Check the format of input
    if (Enum.count(System.argv())!=3) do
      IO.puts("Incorrect input!")
      System.halt(1)

    else
      numNode = String.to_integer(Enum.at(System.argv(0)))
      topology = Enum.at(System.argv(1))
      algorithm = Enum.at(System.argv(2))

    end


  end
end
