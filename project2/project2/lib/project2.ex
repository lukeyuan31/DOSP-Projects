defmodule GossipSimulator do
  use GenServer


  def create_node() do
    {:ok,pid}=GenServer.start_link(__MODULE__, :ok,[])
    pid
  end

  def init(:ok) do
    {:ok, {0,0,[],1,0,0}} #{s,pscount,adjList,w,x-coordinate,y-coordinate} , {nodeId,count,adjList,w}
  end

  def updatePID(pid,nodeID) do
    GenServer.call(pid, {:UpdatePID,nodeID})
  end

  def getCountState(pid) do
    GenServer.call(pid,{:GetCountState})
  end

  def handle_call({:GetCountState}, _from ,state) do
    {a,b,c,d,x,y}=state
    {:reply,b, state}

  end

  def getAdjacentList(pid) do
    GenServer.call(pid,{:GetAdjacentList})
  end

  def handle_call({:GetAdjacentList}, _from ,state) do
    {a,b,c,d,x,y}=state
    {:reply,c, state}
  end



  def handle_call({:UpdatePID,nodeID}, _from ,state) do
    {a,b,c,d,x,y} = state
    state={nodeID,b,c,d,x,y}
    {:reply,a, state}
  end

  def getState(pid) do
    GenServer.call(pid,{:GetState})
  end

  def handle_call({:GetState}, _from ,state) do
    {a,b,c,d,x,y}=state
    # IO.inspect("b #{b}")
    {:reply,state, state}

  end

  def getXcoordinate(pid) do
    GenServer.call(pid,{:GetX})
  end

  def updateXcoordinate(pid,newx) do
    GenServer.call(pid,{:updateX,newx})
  end

  def handle_call({:GetX},_from, state) do
    {a,b,c,d,x,y}=state
    {:reply,x,state}
  end

  def handle_call({:updateX,newx},_from,state) do
    {a,b,c,d,x,y}=state
    state={a,b,c,d,newx,y}
    {:reply,x,state}
  end

  def getYcoordinate(pid) do
    GenServer.call(pid,{:GetY})
  end

  def updateYcoordinate(pid,newy) do
    GenServer.call(pid,{:updateY,newy})
  end

  def handle_call({:GetY}, _from,state) do
    {a,b,c,d,x,y}=state
    {:reply,y,state}
  end

  def handle_call({:updateY,newy},_from,state) do
    {a,b,c,d,x,y} = state
    state={a,b,c,d,x,newy}
    {:reply,y,state}
  end

  def handle_call({:UpdateAdjacentState,map}, _from, state) do
    {a,b,c,d,x,y}=state
    state={a,b,c ++ [map],d,x,y}
    {:reply,a, state}
  end

  def main() do

    # Check the format of input
    if (Enum.count(System.argv())!=3) do
        IO.puts("Incorrect input!")
         System.halt(1)

    else
    numNodes = String.to_integer(Enum.at(System.argv,0))
    topology = Enum.at(System.argv,1)
    algorithm = Enum.at(System.argv,2)


        # globalCount holds count of number of nodes who have received the message at least once
    table = :ets.new(:table, [:named_table,:public])
    :ets.insert(table, {"globalCount",0})


    allNodes = Enum.map((1..numNodes), fn(x) ->
        pid=create_node()
        updatePID(pid, x)
            # IO.inspect(pid)
        pid
        end)

    startTime = System.monotonic_time(:millisecond)
    selectTopology(topology,allNodes)
    selectAlgorithm(algorithm, allNodes, startTime)
    end
    end


  def createFull(allNodes) do
    Enum.each(allNodes, fn(k) ->
      #adjList=List.delete(allNodes,k)
      Enum.each(allNodes, fn(x) ->
      if x != k do
        GenServer.call(k, {:UpdateAdjacentState,x})
      end
     end)
   end)
  end

  def createLine(allNodes)do
    Enum.each(allNodes, fn(i) ->
      index_of_i=Enum.find_index(allNodes, fn(m) -> m==i end)
      Enum.each(allNodes, fn(j) ->
        index_of_j=Enum.find_index(allNodes, fn(n) ->n==j end)
        cond do
          index_of_j==index_of_i-1 ->
            left_neighbor=Enum.fetch!(allNodes,index_of_j)
            GenServer.call(i,{:UpdateAdjacentState,left_neighbor})
          index_of_j==index_of_i+1 ->
            right_neighbor= Enum.fetch!(allNodes, index_of_j)
            GenServer.call(i,{:UpdateAdjacentState,right_neighbor})
          true ->
            nil
        end

      end)

    end)
  end

  def createRand2D(allNodes) do
    Enum.each(allNodes, fn(n) ->
        randx=randomFloat()
        randy=randomFloat()
        #IO.puts("#{randx}")
        #IO.puts("#{randy}")
        updateXcoordinate(n,randx)
        updateYcoordinate(n,randy)
    end)

    Enum.each(allNodes, fn(m) ->
        x_of_m=getXcoordinate(m)
        #IO.puts("#{x_of_m}")
        y_of_m=getYcoordinate(m)
        others=List.delete(allNodes,m)
        Enum.each(others, fn(n) ->
            x_of_n=getXcoordinate(n)
            y_of_n=getYcoordinate(n)
            distance=(x_of_m-x_of_n)*(x_of_m-x_of_n)+(y_of_m-y_of_n)*(y_of_m-y_of_n)
            #IO.puts("#{distance}")
            cond do
              distance <= 0_1 ->
                GenServer.call(m, {:UpdateAdjacentState,n})
              true ->nil
            end
        end)
    end)
  end

  def selectAlgorithm(algorithm,allNodes, startTime) do
    case algorithm do
      "gossip" -> startGossip(allNodes, startTime)
      #"push-sum" ->startPushSum(allNodes, startTime)
    end
  end

  def startGossip(allNodes, startTime) do
    randomFirstNode = Enum.random(allNodes)
    updateStateCount(randomFirstNode, startTime, allNodes)
    loopGossip(randomFirstNode, startTime, allNodes)
  end


  def periodicGossipTransmission(adjacentList, startTime, allNodes) do
   # spawn(Parse_Csv,:parseCsvFiles,[self])
    # IO.inspect adjacentList
    chosenRandomAdjacent=Enum.random(adjacentList)
    Task.start(GossipSimulator,:transmitGossip,[chosenRandomAdjacent, startTime, allNodes])
    :timer.sleep 2

    periodicGossipTransmission(chosenRandomAdjacent, startTime, allNodes)
  end

  def loopGossip(chosenRandomNode, startTime, allNodes) do

    currentNodeCount = getCountState(chosenRandomNode)

    cond do
      currentNodeCount <= 10 ->

        adjacentList = getAdjacentList(chosenRandomNode)
        periodicGossipTransmission(adjacentList, startTime, allNodes)

      true ->

        Process.exit(chosenRandomNode, :normal)
        adjacentList = getAdjacentList(chosenRandomNode)
        chosenRandomAdjacent=Enum.random(adjacentList)
        loopGossip(chosenRandomAdjacent, startTime, allNodes)

    end

  end



  def transmitGossip(pid, startTime, allNodes) do
    #Data store count update
    updateStateCount(pid, startTime, allNodes)
    loopGossip(pid, startTime, allNodes)
  end


  def updateStateCount(pid, startTime, allNodes) do

    GenServer.call(pid, {:UpdateCountState,startTime, allNodes})

  end

  def handle_call({:UpdateCountState,startTime, allNodes}, _from,state) do
  {a,b,c,d,x,y}=state
    if(b==0) do
        totalCount = :ets.update_counter(:table, "globalCount", {2,1})
        if(totalCount == length(allNodes)) do
        endTime = System.monotonic_time(:millisecond) - startTime
        IO.puts "Convergence for gossip for #{totalCount} nodes was achieved in #{endTime} Milliseconds"
         :timer.sleep(1)
         System.halt(1)
        end
    end
  state={a,b+1,c,d,x,y}
  {:reply, b+1, state}
  end


  def selectTopology(topology,allNodes) do
    case topology do
      "full" ->createFull(allNodes)
      "rand2D" ->createRand2D(allNodes)
      "line" ->createLine(allNodes)
    #  "impLine" ->buildImpLine(allNodes)
    #  "torus" -> buildTorus(allNodes)
    #  "3D" -> build3D(allNodes)
    end
  end


  def waitIndefinitely() do
    waitIndefinitely()
  end

  def randomFloat() do
    :rand.uniform()
 #|> Float.round(5)
  end

end


#testnum=GossipSimulator.randomtest()
#IO.puts("#{testnum}")
GossipSimulator.main()
GossipSimulator.waitIndefinitely()
