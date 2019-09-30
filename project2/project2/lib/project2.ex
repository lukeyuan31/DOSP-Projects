defmodule GossipSimulator do
  use GenServer

  def waitInfinitly() do
    waitInfinitly()
  end

  def create_node() do
    {:ok,pid}=GenServer.start_link(__MODULE__, :ok,[])
    pid
  end

  def init(:ok) do
    {:ok, {0,0,[],1,0,0}} #{s,pscount,adjList,w,x-coordinate,y-coordinate} 
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

  

  def main(args) do
      args |> parse_args
  end
    # Check the format of input
    

  defp parse_args (args)do
    {_,k,_} = OptionParser.parse(args)
  
    #numNodes = String.to_integer(Enum.at(System.argv,0))
    #topology = Enum.at(System.argv,1)
    #algorithm = Enum.at(System.argv,2)
    numNodes = String.to_integer(Enum.at(k,0))
    topology = Enum.at(k,1)
    algorithm = Enum.at(k,2)

        # globalCount holds count of number of nodes who have received the message at least once
    table = :ets.new(:table, [:named_table,:public])
    :ets.insert(table, {"globalCount",0})

    if (topology=="3Dtorus") do
      # round up to the nearest cube
      numNodes=round(:math.pow(:math.ceil(:math.pow(numNodes,1/3)),3))
      allNodes = Enum.map((1..numNodes), fn(x) ->
        pid=create_node()
        updatePID(pid, x)
        pid
        end)
        
        selectTopology(topology,allNodes)
        startTime = System.monotonic_time(:millisecond)
        selectAlgorithm(algorithm, allNodes, startTime)
    else
      if (topology=="honeycomb" || topology=="randhoneycomb") do
      numNodes=round(:math.pow(:math.ceil(:math.sqrt(numNodes)),2))
      allNodes = Enum.map((1..numNodes), fn(x) ->
        pid=create_node()
        updatePID(pid, x)     
        pid
        end)
        
        selectTopology(topology,allNodes)
        startTime = System.monotonic_time(:millisecond)
        selectAlgorithm(algorithm, allNodes, startTime)
    else
      allNodes = Enum.map((1..numNodes), fn(x) ->
        pid=create_node()
        updatePID(pid, x)
        pid
        end)
        
        selectTopology(topology,allNodes)
        startTime = System.monotonic_time(:millisecond)
        selectAlgorithm(algorithm, allNodes, startTime)
    end
    end
    waitInfinitly()
  end
    


  def createFull(allNodes) do
    Enum.each(allNodes, fn(k) ->
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
        y_of_m=getYcoordinate(m)
        others=List.delete(allNodes,m)
        Enum.each(others, fn(n) ->
            x_of_n=getXcoordinate(n)
            y_of_n=getYcoordinate(n)
            distance=(x_of_m-x_of_n)*(x_of_m-x_of_n)+(y_of_m-y_of_n)*(y_of_m-y_of_n)
            #IO.puts("#{distance}")
            cond do
              distance <= 0_01 ->
                GenServer.call(m, {:UpdateAdjacentState,n})
              true ->nil
            end
        end)
    end)
  end

  def create3DTorus(allNodes) do
    totalNum=Enum.count(allNodes)
    length=:math.pow(totalNum,1/3)
    length_of_cube=round(length)
    area_of_square=length_of_cube*length_of_cube
    height=round(totalNum/area_of_square)
    #For each actor, add the neighbor one by one in the order of down, up, left, right, front and back
    Enum.each(allNodes, fn(n) ->
      index_of_n=Enum.find_index(allNodes, fn(m) -> m==n end)
      #IO.puts("#{index_of_n}")
      #check if the actor is at the bottom of the torus
      if((index_of_n+1)>area_of_square) do
        index_of_neighbor1=index_of_n-area_of_square
        neighbor1=Enum.fetch!(allNodes,index_of_neighbor1)
        GenServer.call(n,{:UpdateAdjacentState,neighbor1})
      else
        index_of_neighbor1=index_of_n+(area_of_square*(height-1))
        neighbor1=Enum.fetch!(allNodes,index_of_neighbor1)
        GenServer.call(n,{:UpdateAdjacentState,neighbor1})
      end

      #check if the actor is on the top of the torus
      if((totalNum-index_of_n-1)>area_of_square) do
        index_of_neighbor2=index_of_n+area_of_square
        neighbor2=Enum.fetch!(allNodes,index_of_neighbor2)
        GenServer.call(n,{:UpdateAdjacentState,neighbor2})
      else
        index_of_neighbor2=index_of_n-(area_of_square*(height-1))
        neighbor2=Enum.fetch!(allNodes,index_of_neighbor2)
        GenServer.call(n,{:UpdateAdjacentState,neighbor2})
      end

      #check if the actor is on the left side of the torus
      if(rem(index_of_n,length_of_cube)!=0) do
        index_of_neighbor3=index_of_n-1
        neighbor3=Enum.fetch!(allNodes,index_of_neighbor3)
        GenServer.call(n,{:UpdateAdjacentState,neighbor3})
      else
        index_of_neighbor3=index_of_n+length_of_cube-1
        neighbor3=Enum.fetch!(allNodes,index_of_neighbor3)
        GenServer.call(n,{:UpdateAdjacentState,neighbor3})
      end

      #check if the actor is on the right side of the torus
      if(rem(index_of_n+1,length_of_cube)!=0) do
        index_of_neighbor4=index_of_n+1
        neighbor4=Enum.fetch!(allNodes,index_of_neighbor4)
        GenServer.call(n,{:UpdateAdjacentState,neighbor4})
      else
        #IO.puts("catching neighbor 4")
        index_of_neighbor4=index_of_n-length_of_cube+1
        neighbor4=Enum.fetch!(allNodes,index_of_neighbor4)
        GenServer.call(n,{:UpdateAdjacentState,neighbor4})
      end

      #check if the actor is on the front side of the torus
      if(rem(index_of_n,area_of_square)>=length_of_cube) do
        index_of_neighbor5=index_of_n-length_of_cube
        neighbor5=Enum.fetch!(allNodes,index_of_neighbor5)
        GenServer.call(n,{:UpdateAdjacentState,neighbor5})
      else
        #IO.puts("catching n5")
        index_of_neighbor5=index_of_n+length_of_cube*(length_of_cube-1)
        neighbor5=Enum.fetch!(allNodes,index_of_neighbor5)
        GenServer.call(n,{:UpdateAdjacentState,neighbor5})
      end

      #check if the actor is on the back side of the torus
      if(rem(index_of_n+length_of_cube,area_of_square)>=length_of_cube) do
        index_of_neighbor6=index_of_n+length_of_cube
        neighbor6=Enum.fetch!(allNodes,index_of_neighbor6)
        GenServer.call(n,{:UpdateAdjacentState,neighbor6})
      else
        #IO.puts("catching n6")
        index_of_neighbor6=index_of_n-length_of_cube*(length_of_cube-1)
        neighbor6=Enum.fetch!(allNodes,index_of_neighbor6)
        GenServer.call(n,{:UpdateAdjacentState,neighbor6})
      end

    end)
  end

  def createHoneycomb(allNodes) do
    totalNum=Enum.count(allNodes)
    length=:math.sqrt(totalNum)
    length_of_square=round(length)
  
    Enum.each(allNodes, fn(n)->
    index_of_n=Enum.find_index(allNodes, fn(m) -> m==n end)
    rowNum=trunc((index_of_n)/length_of_square)
    colNum=rem(index_of_n,length_of_square)
    
    #in the condition of odd row and odd coloum, the neighbor should be up, right and down

    if(rem(rowNum,2)==0 && rem(colNum,2)==0 ) do
      #check if the node is on the upper edge
      if((totalNum-index_of_n-1)>length_of_square) do
        index_of_neighbor1=index_of_n+length_of_square
        neighbor1=Enum.fetch!(allNodes,index_of_neighbor1)
        GenServer.call(n,{:UpdateAdjacentState,neighbor1})
      #IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor1}")
      end

      #check if the node is on the lower edge
      if(index_of_n>length_of_square) do
        index_of_neighbor2=index_of_n-length_of_square
        neighbor2=Enum.fetch!(allNodes,index_of_neighbor2)
        GenServer.call(n,{:UpdateAdjacentState,neighbor2})
       # IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor2}")
      end
      #check if the node is on the rightmost edge
      if(rem((index_of_n+1),length_of_square)!=0) do
        index_of_neighbor3=index_of_n+1
        neighbor3=Enum.fetch!(allNodes,index_of_neighbor3)
        GenServer.call(n,{:UpdateAdjacentState,neighbor3})
        #IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor3}")

      end

    end

     #in the condition of even row and even coloum, the neighbor should be up, right and down

    if(rem(rowNum,2)==1 && rem(colNum,2)==1 ) do
      #check if the node is on the upper edge
      if((totalNum-index_of_n)>length_of_square) do
        index_of_neighbor1=index_of_n+length_of_square
        neighbor1=Enum.fetch!(allNodes,index_of_neighbor1)
        GenServer.call(n,{:UpdateAdjacentState,neighbor1})
        #IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor1}")
      end
      #check if the node is on the rightmost edge
      if(rem((index_of_n+1),length_of_square)!=0) do
        index_of_neighbor3=index_of_n+1
        neighbor3=Enum.fetch!(allNodes,index_of_neighbor3)
        GenServer.call(n,{:UpdateAdjacentState,neighbor3})
       # IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor3}")
      end

      #because it is in even row, it must have a neighor under
      index_of_neighbor2=index_of_n-length_of_square
      neighbor2=Enum.fetch!(allNodes,index_of_neighbor2)
      GenServer.call(n,{:UpdateAdjacentState,neighbor2})
      #IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor2}")
    end

    if(rem(rowNum,2)==0 && rem(colNum,2)==1) do
     # IO.puts("#{rowNum},#{colNum}")
      #IO.puts("jishuhang oushuwei")
      if((totalNum-index_of_n)>length_of_square) do
        index_of_neighbor1=index_of_n+length_of_square
        neighbor1=Enum.fetch!(allNodes,index_of_neighbor1)
        GenServer.call(n,{:UpdateAdjacentState,neighbor1})
       # IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor1}")
      end

      if(index_of_n>length_of_square) do
        index_of_neighbor2=index_of_n-length_of_square
        neighbor2=Enum.fetch!(allNodes,index_of_neighbor2)
        GenServer.call(n,{:UpdateAdjacentState,neighbor2})
        #IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor2}")
      end

      index_of_neighbor3=index_of_n-1
      neighbor3=Enum.fetch!(allNodes,index_of_neighbor3)
      GenServer.call(n,{:UpdateAdjacentState,neighbor3})
      #IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor3}")
    end

    if(rem(rowNum,2)==1 && rem(colNum,2)==0) do
      #IO.puts("#{rowNum},#{colNum}")
      #IO.puts("ousuhang jishuwei")
      #check if the node is on the upper edge
      if((totalNum-index_of_n)>length_of_square) do
        index_of_neighbor1=index_of_n+length_of_square
        neighbor1=Enum.fetch!(allNodes,index_of_neighbor1)
        GenServer.call(n,{:UpdateAdjacentState,neighbor1})
       # IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor1}")
      end

      #check if the node is on the lower edge
      if(index_of_n>length_of_square) do
        index_of_neighbor2=index_of_n-length_of_square
        neighbor2=Enum.fetch!(allNodes,index_of_neighbor2)
        GenServer.call(n,{:UpdateAdjacentState,neighbor2})
       # IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor2}")
      end

      #check if the node is on the leftmost edge
      if(rem((index_of_n+1),length_of_square)!=1) do
        index_of_neighbor3=index_of_n-1
        neighbor3=Enum.fetch!(allNodes,index_of_neighbor3)
        GenServer.call(n,{:UpdateAdjacentState,neighbor3})
       # IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor3}")
      end

    end

    end)
    
    
  end

  def createRandHoneyComb(allNodes) do
    totalNum=Enum.count(allNodes)
    length=:math.sqrt(totalNum)
    length_of_square=round(length)
  
    Enum.each(allNodes, fn(n)->
    index_of_n=Enum.find_index(allNodes, fn(m) -> m==n end)
    rowNum=trunc((index_of_n)/length_of_square)
    colNum=rem(index_of_n,length_of_square)
    
    #in the condition of odd row and odd coloum, the neighbor should be up, right and down

    if(rem(rowNum,2)==0 && rem(colNum,2)==0 ) do
      #check if the node is on the upper edge
      if((totalNum-index_of_n-1)>length_of_square) do
        index_of_neighbor1=index_of_n+length_of_square
        neighbor1=Enum.fetch!(allNodes,index_of_neighbor1)
        GenServer.call(n,{:UpdateAdjacentState,neighbor1})
      #IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor1}")
      end

      #check if the node is on the lower edge
      if(index_of_n>length_of_square) do
        index_of_neighbor2=index_of_n-length_of_square
        neighbor2=Enum.fetch!(allNodes,index_of_neighbor2)
        GenServer.call(n,{:UpdateAdjacentState,neighbor2})
       # IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor2}")
      end
      #check if the node is on the rightmost edge
      if(rem((index_of_n+1),length_of_square)!=0) do
        index_of_neighbor3=index_of_n+1
        neighbor3=Enum.fetch!(allNodes,index_of_neighbor3)
        GenServer.call(n,{:UpdateAdjacentState,neighbor3})
        #IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor3}")

      end

    end

     #in the condition of even row and even coloum, the neighbor should be up, right and down

    if(rem(rowNum,2)==1 && rem(colNum,2)==1 ) do
      #check if the node is on the upper edge
      if((totalNum-index_of_n)>length_of_square) do
        index_of_neighbor1=index_of_n+length_of_square
        neighbor1=Enum.fetch!(allNodes,index_of_neighbor1)
        GenServer.call(n,{:UpdateAdjacentState,neighbor1})
        #IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor1}")
      end
      #check if the node is on the rightmost edge
      if(rem((index_of_n+1),length_of_square)!=0) do
        index_of_neighbor3=index_of_n+1
        neighbor3=Enum.fetch!(allNodes,index_of_neighbor3)
        GenServer.call(n,{:UpdateAdjacentState,neighbor3})
       # IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor3}")
      end

      #because it is in even row, it must have a neighor under
      index_of_neighbor2=index_of_n-length_of_square
      neighbor2=Enum.fetch!(allNodes,index_of_neighbor2)
      GenServer.call(n,{:UpdateAdjacentState,neighbor2})
      #IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor2}")
    end

    if(rem(rowNum,2)==0 && rem(colNum,2)==1) do
     # IO.puts("#{rowNum},#{colNum}")
      #IO.puts("jishuhang oushuwei")
      if((totalNum-index_of_n)>length_of_square) do
        index_of_neighbor1=index_of_n+length_of_square
        neighbor1=Enum.fetch!(allNodes,index_of_neighbor1)
        GenServer.call(n,{:UpdateAdjacentState,neighbor1})
       # IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor1}")
      end

      if(index_of_n>length_of_square) do
        index_of_neighbor2=index_of_n-length_of_square
        neighbor2=Enum.fetch!(allNodes,index_of_neighbor2)
        GenServer.call(n,{:UpdateAdjacentState,neighbor2})
        #IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor2}")
      end

      index_of_neighbor3=index_of_n-1
      neighbor3=Enum.fetch!(allNodes,index_of_neighbor3)
      GenServer.call(n,{:UpdateAdjacentState,neighbor3})
      #IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor3}")
    end

    if(rem(rowNum,2)==1 && rem(colNum,2)==0) do
      #IO.puts("#{rowNum},#{colNum}")
      #IO.puts("ousuhang jishuwei")
      #check if the node is on the upper edge
      if((totalNum-index_of_n)>length_of_square) do
        index_of_neighbor1=index_of_n+length_of_square
        neighbor1=Enum.fetch!(allNodes,index_of_neighbor1)
        GenServer.call(n,{:UpdateAdjacentState,neighbor1})
       # IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor1}")
      end

      #check if the node is on the lower edge
      if(index_of_n>length_of_square) do
        index_of_neighbor2=index_of_n-length_of_square
        neighbor2=Enum.fetch!(allNodes,index_of_neighbor2)
        GenServer.call(n,{:UpdateAdjacentState,neighbor2})
       # IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor2}")
      end

      #check if the node is on the leftmost edge
      if(rem((index_of_n+1),length_of_square)!=1) do
        index_of_neighbor3=index_of_n-1
        neighbor3=Enum.fetch!(allNodes,index_of_neighbor3)
        GenServer.call(n,{:UpdateAdjacentState,neighbor3})
       # IO.puts("#{index_of_n} has a neighbor of #{index_of_neighbor3}")
      end

    end

    #add a random neighbor from the node list
    randomNeighbor=Enum.random(allNodes)
    GenServer.call(n,{:UpdateAdjacentState,randomNeighbor})

    

    end)
    
    
  end


  def selectAlgorithm(algorithm,allNodes, startTime) do
    case algorithm do
      "gossip" -> startGossip(allNodes, startTime)
      "push-sum" ->startPushSum(allNodes, startTime)
    end
  end

  def startGossip(allNodes, startTime) do
    randomFirstNode = Enum.random(allNodes)
    updateStateCount(randomFirstNode, startTime, allNodes)
    loopGossip(randomFirstNode, startTime, allNodes)
  end

  def startPushSum(allNodes, startTime) do
    randomFirstNode = Enum.random(allNodes)
    GenServer.cast(randomFirstNode, {:transmitPushSum,0,0,startTime, length(allNodes)})
  end

  def loopPushSum(randomNode, currentS, currentW,startTime, total_nodes) do
    GenServer.cast(randomNode, {:transmitPushSum,currentS,currentW,startTime, total_nodes})
  end


  def handle_cast({:transmitPushSum,receivedS,receivedW,startTime, total_nodes},state) do

    {s,pscount,adjList,w,x,y} = state  
    currentS = s + receivedS
    currentW = w + receivedW
    diff = abs((currentS/currentW) - (s/w))
    if(diff<1.0e-10) do
      if pscount<2 do
        pscount = pscount + 1
        randomNode = Enum.random(adjList)
        newS=currentS/2
        newW=currentW/2
        loopPushSum(randomNode, newS, newW,startTime, total_nodes)
        state = {currentS/2,pscount,adjList,currentW/2,x,y}
        {:noreply,state}
      else
        count = :ets.update_counter(:table, "globalCount", {2,1})
        if count == total_nodes do
          endTime = System.monotonic_time(:millisecond) - startTime
          IO.puts "Algorithm: Push-Sum   Node Number: #{count}   Covergence Time: " <> Integer.to_string(endTime) <>"ms"
          System.halt(1)
          {:noreply,state}
        else
          randomNode = Enum.random(adjList)
          newS=currentS/2
          newW=currentW/2
          loopPushSum(randomNode, newS, newW,startTime, total_nodes)
          state = {currentS/2,pscount,adjList,currentW/2,x,y}
          {:noreply,state}
        end
      end
    else
      pscount = 0
      randomNode = Enum.random(adjList)
      newS=currentS/2
      newW=currentW/2
      loopPushSum(randomNode, newS, newW,startTime, total_nodes)
      state = {newS,pscount,adjList,newW,x,y}
      {:noreply,state}
    end


  end

  def periodicGossipTransmission(adjacentList, startTime, allNodes) do
    chosenRandomAdjacent=Enum.random(adjacentList)
    Task.start(GossipSimulator,:transmitGossip,[chosenRandomAdjacent, startTime, allNodes])
    #:timer.sleep 2
    newAdjacentList=getAdjacentList(chosenRandomAdjacent)
    periodicGossipTransmission(newAdjacentList, startTime, allNodes)
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
        IO.puts "Algorithm: Gossip   Node Number: #{totalCount}  Covergence Time #{endTime}ms"
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
      "3Dtorus" ->create3DTorus(allNodes)
      "honeycomb" ->createHoneycomb(allNodes)
      "randhoneycomb" ->createRandHoneyComb(allNodes)
    end
  end

  

  def randomFloat() do
    :rand.uniform()
 #|> Float.round(5)
  end

end
#testnum=GossipSimulator.randomtest()
#IO.puts("#{testnum}")
#GossipSimulator.main()
#GossipSimulator.waitInfinitly()
