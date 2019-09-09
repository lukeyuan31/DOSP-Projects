defmodule Project1_gen do
    use GenServer

    @impl true
    def init(result) do
        {:ok,result}
    end

    @impl true
    def handle_cast({:subtask,start,ending,bosspid},state) do
        calculator(start,ending,bosspid)
        receive do
            {:ok, _}-> nil
        end

    end

    def handle_cast({:add_result, new_result},result) do
        {:noreply, result ++ [new_result]}
    end

    def handle_call(:get_result, _from, result) do
        {:reply, result,result}
    end

    def add_result(pid, result) do
        GenServer.cast(pid,{:add_result,result})
    end

    def get_result(pid) do
        GenServer.call(pid, :get_result)
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


    # For n from start to ending, use vampire_factors(n) to find if n has vampire factors. If exists, cast them to boss

    def calculator(start,ending,bosspid) do
        Enum.each(start..ending, fn n->
         #IO.puts("#{n}")
         case vampire_factors(n) do
            [] -> nil
            vf -> Project1_gen.add_result(bosspid,String.replace("#{n}\t#{inspect(vf)}", ["{", "}", "[", "]", ","], ""))
                  IO.puts(String.replace("#{n}\t#{inspect(vf)}", ["{", "}", "[", "]", ","], ""))
         end
        end)
    end



    def task do
        start = String.to_integer(Enum.at(System.argv,0))               #get the input numbers from the command line
        ending = String.to_integer(Enum.at(System.argv,1))
        no_of_cores = System.schedulers_online
        work_range = (ending-start) / (no_of_cores) |> Float.ceil |> Kernel.trunc
        {:ok,pid} = GenServer.start_link(Project1_gen,[:boss],[])    # create the boss actor

        calculate(no_of_cores,work_range,start,ending,pid)            # create the workers by recursive functions
        for _ <- 1..no_of_cores do
            receive do
                {:ok, _} -> nil
            after
                0_130 -> nil
            end
        end

        Project1_gen.get_result(pid)                        #The boss print the result done by workers
    end



    # The recursive function to create workers and assign each of them tasks
    def calculate(no_of_cores,work_range,start,ending,pid) do
        bosspid = pid
        if no_of_cores > 0 do
            #IO.puts("about to create worker..,start is #{start}, ending is #{ending}")
            {:ok, pid} = GenServer.start_link(Project1_gen, [:subtask], [])
            GenServer.cast(pid,{:subtask,start,start+work_range,bosspid})
            start=start+work_range
            Project1_gen.calculate(no_of_cores-1,work_range,start,ending,pid)
        end
    end



end
