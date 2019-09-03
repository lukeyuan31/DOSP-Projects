defmodule Project1 do

    # for a given number n, find the needed vampire numbers
  def factor_pairs(n) do
    
    #first = trunc(n / :math.pow(10, div(char_len(n), 2)))    #returns the integer part of the number
    #first = trunc(:math.pow(10,div(char_len(n),2))) 
    charlen_of_n=length(to_charlist(n))
    min  = :math.sqrt(n) |> round                          #get the closest integer to the float
    len_of_ten= div(charlen_of_n,2)
    max = :math.pow(10, len_of_ten) |> trunc()
    for i <- min .. max, rem(n, i) == 0, do: {i, div(n, i)}     # rem: 求余
  end
 

   # First skip the numbers that have an odd length, then sort the numbers.
   # Use Enum.filter() to sort out the pairs that meet the standard of vampire numbers 
  def vampire_factors(n) do
    charlen_of_n=length(to_charlist(n))
    if rem(charlen_of_n, 2) == 1 do          
      []
    else
      half = div(length(to_charlist(n)), 2)
      sorted = Enum.sort(String.codepoints("#{n}"))
      Enum.filter(factor_pairs(n), fn {a, b} ->          #  After getting all the factor pairs, compare the numbers in them with the original number
        #char_len(a) == half && char_len(b) == half &&
        #Enum.count([a, b], fn x -> rem(x, 10) == 0 end) != 2 &&
        Enum.sort(String.codepoints("#{a}#{b}")) == sorted
      end)
    end
  end
 

   # Divide the whole task into several tasks according to the number of core of the computer.
   # Then create actors and distribute the tasks to each actor.
  def task do
    start = String.to_integer(Enum.at(System.argv,0))               #get the input numbers from the command line
    ending = String.to_integer(Enum.at(System.argv,1))
    no_of_cores = System.schedulers_online
    work_range = (ending-start) / (no_of_cores) |> Float.ceil |> Kernel.trunc  
    create_actors(no_of_cores, work_range, start, ending, self())             # Recursive function to create actors 
        for _ <- 1..no_of_cores do
            receive do
                {:ok, _} -> nil
            end
        end
  end

  def create_actors(no_of_cores, work_range, start, ending, pid) when no_of_cores <= 1 do        # Only last actor spawning function
        spawn(Project1, :caculator, [start, ending, pid])
    end

  def create_actors(no_of_cores, work_range, start, ending, pid) do                              # Actor spawning function
        #start=start+work_range+1
        spawn(Project1, :caculator, [start, start+work_range, pid])
        create_actors(no_of_cores - 1, work_range, start+work_range+1, ending, pid)
  end

  def caculator(start,ending,pid) do
    start_time =System.monotonic_time(:millisecond)
    Enum.reduce_while(Stream.iterate(start, &(&1+1)), 1, fn n, acc ->
      case vampire_factors(n) do
        [] -> {:cont, acc}
        vf -> #IO.puts "#{n}:\t#{inspect vf}"
              cond do
                n<ending && length(vf)==1 ->
                  IO.puts "#{n}\t #{elem(hd(vf),0)} #{elem(hd(vf),1)}"
                  {:cont, acc+1}
                n<ending && length(vf)==2 ->
                  IO.puts "#{n}\t #{elem(hd(vf),0)} #{elem(hd(vf),1)} #{elem(Enum.at(vf,1),0)} #{elem(Enum.at(vf,1),1)}" 
                  {:cont, acc+1}
                true ->
                  {:halt, acc+1}

              end
              #if n<ending  && length(vf)==1 do
             # # IO.puts "#{n}\t #{elem(hd(vf),0)} #{elem(hd(vf),1)}"
             #  {:cont, acc+1}
             # if n<ending  && length(vf)==2 do
               #for i <- 0..length(vf) do
               
              # IO.puts "#{n}\t #{elem(hd(vf),0)} #{elem(hd(vf),1)} #{elem(tl(vf),0)} #{elem(tl(vf),1)}"   #The output is a tuple in a list, so use elem() to get the element
               #Enum.each(vf ,fn(s) ->IO.puts "#{elem(s,0)} #{elem(s,1)}" end)
               #IO.puts "the length is #{length(vf)}"
               #IO.puts (hd(vf))
               #\t#{inspect vf}
               #IO.puts elem(hd(vf),0)
            #   {:cont, acc+1}
             # else
             #  {:halt, acc+1}
             # end
      end
    end)
    send pid, {:ok,"done"} 
    end_time= System.monotonic_time(:millisecond)             #send pid back to boss
    #IO.puts to_string(end_time-start_time)
  end
end
 
#Project1.task

