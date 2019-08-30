defmodule Project1 do
  @moduledoc """
  Documentation for Project1.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Project1.hello()
      :world

  """
  use GenServer
  #Callback

  def handle_call(:result, _from,state) do
  # Call the server to collect result numbers
    {:reply, state,state}
  end

  def handle_cast({:result,value},state) do
  # Collect the result numbers
    {:noreply, [value | state]}
  end

  #Start the server
  def start_link() do
    GenServer.start_link(__MODULE__,[])
  end

  # Initializatin
  def init(args) do
    {:ok,args}
  end

  #------------------Client-------------#

  




  def hello do
    :world
  end
end
