defmodule Project3 do
  use GenServer
  @moduledoc """
  Documentation for Project3.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Project3.hello()
      :world

  """
  def init(:ok) do
    {:ok, {%{},%{},'',0,[],[],0}}   # routing table, backpointers, nid, max_level of current routing table, storage, cache. number of requests
  end

  #Use sha-1 algorithm to generate the nid
  def getHash(key) do
    :crypto.hash(:sha, key) |> Base.encode16
  end

  def start_node() do
    {:ok, pid}=GenServer.start_link(__MODULE__,:ok,[])
    pid
  end

  """
  Generate all the nodes according to the number that the user input.
  All the nodes are stored in a map, not in the peer to peer network
  """

  def createNodes(numNodes, numRequests) do
    allHashedNodes= Enum.map((1..numNodes), fn(x)->
      pid=start_node()
      pidstr=Kernel.inspect(pid)
      fullhashpid=getHash(pidstr)
      nid = String.slice(fullhashpid, 0..3)        #get the first 4 bits as the nid
      #IO.inspect("#{nid}")
      updateNid(pid,nid)
      pid
    end)
    allHashedNodes
  end

  def updateNid(pid,nid) do
      GenServer.call(pid,{:updateNid,nid})
  end

  def handle_call({:updateNid,nid},_from,state) do
      {a,b,c,d,e,f,g}=state
      state = {a,b,nid,d,e,f,g}
      {:reply,a,state}
  end

  def updateMaxLevel(pid,newLevel) do
      GenServer.call(pid,{:updateMaxLevel,newLevel})
  end

  def handle_call({:updateMaxLevel,newLevel},_from,state) do
      {a,b,c,d,e,f,g}=state
      state = {a,b,c,newLevel,e,f,g}
      {:reply,a,state}
  end

"""
{routingTable, backpointers, nid, maxLevel, storage, cache, numRequest}=getState(pid)
"""
  def getState(pid) do
      GenServer.call(pid,{:getState})
  end

  def handle_call({:getState},_from,state) do
      {a,b,c,d,e,f,g}=state
      {:reply,state,state}
  end

  def addOneLevel(pid) do
      GenServer.call(pid,{:addOneLevel})
  end

  #Add one level to routing table and table of back pointer.
  #Access the element in the map by routingTable[key1][key2]

  def handle_call({:addOneLevel},_from,state) do
      {a,b,c,d,e,f,g}=state
      newMaxLevel=d+1
      newa=Map.put_new(a,newMaxLevel,%{1=>[],2=>[],3=>[],4=>[],5=>[],6=>[],7=>[],8=>[],9=>[],A=>[],B=>[],C=>[],D=>[],E=>[],F=>[]})
      newb=Map.put_new(b,newMaxLevel,%{1=>[],2=>[],3=>[],4=>[],5=>[],6=>[],7=>[],8=>[],9=>[],A=>[],B=>[],C=>[],D=>[],E=>[],F=>[]})
      #IO.inspect(newa)
      #IO.inspect(newa[1][A])
      #temp = newa[1][A]
      #newa=put_in(newa[1][A],temp++["test"])
      #newa[1][A]=Enum.concat(newa[1][A],"test")
      #IO.inspect(newa[1][A])
      #IO.inspect(newa)
      state={newa,newb,c,newMaxLevel,e,f,g}
      {:reply,state,state}
  end

  def addtoStorage(pid,item) do
      GenServer.call(pid,{:addtoStorage})
  end

  def handle_call({:addtoStorage},_from,state) do
      {a,b,c,d,e,f,g}=state
      state={a,b,c,d,e++[item],f,g}
      {:reply,state,state}
  end

  #update routing table at rt[key1][key2]
  def updateRT(pid,key1,key2,nid) do
      GenServer.call(pid,{:updateRT,key1,key2,nid})
  end

  def handle_call({:updateRT,key1,key2,nid},_from,state) do
      {a,b,c,d,e,f,g}=state
      temp = a[key1][key2]
      a=put_in(a[key1][key2],temp++[nid])
      IO.inspect(a[key1][key2])
      state={a,b,c,d,e,f,g}
      {:reply,state,state}

  end

  #update back pointer at bp[key1][key2]
  def updateBP(pid,key1,key2,nid) do
      GenServer.call(pid,{:updateBP,key1,key2,nid})
  end

  def handle_call({:updateBP,key1,key2,nid},_from,state) do
     {a,b,c,d,e,f,g}=state
     temp=b[key1][key2]
     b=put_in(b[key1][key2], temp++[nid])
     state={a,b,c,d,e,f,g}
     {:reply,state,state}
  end


  def next_hop(level, guid) do
    #if
  end

# Find the prefix of two strings, return the length of the prefix
  def findPrefix(string1, string2) do
      index = Enum.find_index(0..String.length(string1) , fn(i)->
          String.at(string1,i)!=String.at(string2,i)
      end)
      if index, do: String.length(String.slice(string1, 0, index)), else: String.length(string1)
  end

"""
assume when calling this function, the state of a node is get as below:
{routingTable, backpointers, nid, maxLevel, storage, cache, numRequest}=getState(pid)
"""
  def next_hop(currentLevel, guid, max_level,routingTable) do
      if currentLevel>max_level do
        guid
      else
        d=String.at(guid,currentLevel-1)
        e=routingTable[level][index_of(d)]


      end

  end

  def buildNetwork(nodeList) do
      Enum.each(nodeList, fn(m) ->

      end)
  end

  def main do
    numNodes = String.to_integer(Enum.at(System.argv,0))
    numRequests = String.to_integer(Enum.at(System.argv,1))
    nodeList=createNodes(numNodes,numRequests)
    IO.inspect(nodeList)
    randomNode=Enum.random(nodeList)
    addOneLevel(randomNode)
    addOneLevel(randomNode)
    updateRT(randomNode,1,A,"test")
    #IO.puts(board[1][1])
    #IO.puts(findPrefix("12315","t232"))
    #IO.puts("#{numresult}")
  end
end


Project3.main()
