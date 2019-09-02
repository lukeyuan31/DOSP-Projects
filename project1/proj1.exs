
#{_clock_time, {_cpu_time, results}} = :timer.tc(fn ->
prev_real = System.monotonic_time(:millisecond)
Project1.task
#  end)

current_real = System.monotonic_time(:millisecond)
IO.puts "Real time " <> to_string(current_real-prev_real)



#Enum.each(results, fn x -> IO.puts x end)
##IO.puts "CPU time:   #{cpu_time |> Kernel./(1000) |> round()} ms"
#IO.puts "Clock time: #{clock_time |> Kernel./(1000) |> round()} ms"
  