
#{_clock_time, {_cpu_time, results}} = :timer.tc(fn ->
        Project1.task
#  end)


#Enum.each(results, fn x -> IO.puts x end)
##IO.puts "CPU time:   #{cpu_time |> Kernel./(1000) |> round()} ms"
#IO.puts "Clock time: #{clock_time |> Kernel./(1000) |> round()} ms"
  