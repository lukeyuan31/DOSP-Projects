defmodule Project1_gen do
    use GenServer

    @impl true
    def init(state) do
        {:ok,state}
    end

    @impl true
    def handle_cast({:subtask,start,ending,pid},state) do
        #IO.puts("entering handle_cast")
        calculator(start,ending,pid)
        receive do
            {:ok, _}-> nil
        end
        #send pid,{:ok,"done"}
    end

    #Input the integer n and find the vampire numbers by dividing it with integers from min to max
    #It returns a {} with a pair of integers.
    def factor_pairs(n) do
        charlen_of_n=length(to_charlist(n))
        min  = :math.sqrt(n) |> round                          #get the closest integer to the float
        len_of_ten= div(charlen_of_n,2)
        max = :math.pow(10, len_of_ten) |> trunc()
        for i <- min .. max, rem(n, i) == 0, do: {i, div(n, i)}     # rem: 求余
    end

    # First skip the numbers that have an odd length, then sort the numbers.
   # Use Enum.filter() to sort out the pairs that meet the standard of vampire numbers
    def vampire_factors(n) do
        #IO.puts("    #{n}")
        charlen_of_n=length(to_charlist(n))
        if rem(charlen_of_n, 2) == 1 do
            []
        else
            half = div(length(to_charlist(n)), 2)
            sorted = Enum.sort(String.codepoints("#{n}"))
            Enum.filter(factor_pairs(n), fn {a, b} ->          #  After getting all the factor pairs, compare the numbers in them with the original number
            Enum.sort(String.codepoints("#{a}#{b}")) == sorted
            end)
        end
    end

    def calculator(start,ending,pid) do
        #IO.puts("start calculating..start is #{start}, ending is #{ending}")
    #Enum.reduce_while(Stream.iterate(start, &(&1+1)), 1, fn n, acc ->
        Enum.each(start..ending, fn n->
         #IO.puts("#{n}")
         case vampire_factors(n) do
            [] -> nil
            vf -> #IO.puts "#{n}:\t#{inspect vf}"
                 IO.puts(String.replace("#{n}\t#{inspect(vf)}", ["{", "}", "[", "]", ","], ""))
         end
        end)
     #send pid, {:ok,"done"}            #send message back to boss

    end

    def task do
        start = String.to_integer(Enum.at(System.argv,0))               #get the input numbers from the command line
        ending = String.to_integer(Enum.at(System.argv,1))
        no_of_cores = System.schedulers_online
        work_range = (ending-start) / (no_of_cores) |> Float.ceil |> Kernel.trunc
        calculate(no_of_cores,work_range,start,ending)
        for _ <- 1..no_of_cores do
            receive do
                {:ok, _} -> nil
            after
                0_130 -> nil
            end
        end
    end


    #def create_worker(start,work_range) do
     #   {:ok,pid} =GenServer.start_link(Project1_gen,[:subtask],[])
      #  GenServer.cast(pid,{:subtask,start,start+work_range})
    #end

    #def calculate(no_of_cores,work_range,start,ending) do
    #    Enum.map(0..(no_of_cores), fn n ->Project1_gen.create_worker(start,ending) end)
    #end



    def calculate(no_of_cores,work_range,start,ending) do
        if no_of_cores > 0 do
            #IO.puts("about to create worker..,start is #{start}, ending is #{ending}")
            {:ok, pid} = GenServer.start_link(Project1_gen, [:subtask], [])
            GenServer.cast(pid,{:subtask,start,start+work_range,pid})
            start=start+work_range
            Project1_gen.calculate(no_of_cores-1,work_range,start,ending)
        end
    end



end
