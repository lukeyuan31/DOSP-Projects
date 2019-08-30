defmodule Vampire do


    # for a given number n, find the needed vampire numbers
  def factor_pairs(n) do
    
    #first = trunc(n / :math.pow(10, div(char_len(n), 2)))    #returns the integer part of the number
    #first = trunc(:math.pow(10,div(char_len(n),2))) 
    charlen_of_n=length(to_char_list(n))
    min  = :math.sqrt(n) |> round                          #get the closest integer to the float
    len_of_ten= div(charlen_of_n,2)
    max = :math.pow(10, len_of_ten) |> trunc()
    for i <- min .. max, rem(n, i) == 0, do: {i, div(n, i)}     # rem: 求余
  end
 
  def vampire_factors(n) do
    charlen_of_n=length(to_char_list(n))
    if rem(charlen_of_n, 2) == 1 do          #skip the numbers that have a odd length
      []
    else
      half = div(length(to_char_list(n)), 2)
      sorted = Enum.sort(String.codepoints("#{n}"))
      Enum.filter(factor_pairs(n), fn {a, b} ->          #  After getting all the factor pairs, compare the numbers in them with the original number
        #char_len(a) == half && char_len(b) == half &&
        #Enum.count([a, b], fn x -> rem(x, 10) == 0 end) != 2 &&
        Enum.sort(String.codepoints("#{a}#{b}")) == sorted
      end)
    end
  end
 
  #defp char_len(n), do: length(to_char_list(n))
 
  def task do
    start = String.to_integer(Enum.at(System.argv,0))               #get the input numbers from the command line
    ending = String.to_integer(Enum.at(System.argv,1))
    #the number after Stream.iterate is the starting number
    Enum.reduce_while(Stream.iterate(start, &(&1+1)), 1, fn n, acc ->
      case vampire_factors(n) do
        [] -> {:cont, acc}
        vf -> #IO.puts "#{n}:\t#{inspect vf}"
              if n<ending  do
               IO.puts "#{n}:\t#{inspect vf}"
               {:cont, acc+1}
              else
               {:halt, acc+1}
              end
      end
    end)
    IO.puts ""
  end
end
 
Vampire.task