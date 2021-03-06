# Project1

1. **Team members:**

Name | UFID
---|---
Tongjia Guo | 1939-4097
Keyuan Lu | 2144-2855

2.**Overall Design**  
Use GenServer.start_link()/3 first to create a "boss". Then create several workers using the same method. After calculating, the workers will cast the result to the boss. After all the workers have finished their tasks, the boss will then print all the results.  
In order to avoid accidents and protect CPU, I set a timeout on the 91st line of *project1-gen.ex*

```elixir
    after
         0_100 -> nil
    end
```

When testing, please adjust the timeout based on the scale of problem.

3.**Use commands below to run the codes.**  
In the directory of the project

```command
mix compile
```

After compiling, use this command to run the project

```command
mix run proj1.exs 100000 200000
```

4.The size of the work unit is divided by the number of cores. In this project, if there are n cores then the size is 1/n of all the problems.

5.Result

```number
150300	 501 300
125248	 824 152
175329	 759 231
125433	 543 231
162976	 926 176
125460	 510 246 615 204
125500	 500 251
126000	 600 210
126027	 627 201
163944	 414 396
126846	 486 261
139500	 930 150
152608	 608 251
190260	 906 210
152685	 585 261
140350	 401 350
102510	 510 201
153000	 510 300
153436	 431 356
115672	 761 152
192150	 915 210
104260	 401 260
116725	 725 161
129640	 926 140
129775	 725 179
180225	 801 225
117067	 701 167
180297	 897 201
193257	 591 327
105210	 501 210
105264	 516 204
143500	 410 350
193945	 491 395
156240	 651 240
156289	 581 269
105750	 705 150
131242	 422 311
118440	 840 141
156915	 951 165
182250	 810 225
182650	 650 281
182700	 870 210
132430	 410 323
145314	 414 351
133245	 423 315
146137	 461 317
120600	 600 201
108135	 801 135
197725	 719 275
146952	 942 156
134725	 425 317
172822	 782 221
173250	 750 231
186624	 864 216
135828	 588 231
135837	 387 351
174370	 470 371
123354	 534 231
136525	 635 215
110758	 701 158
136948	 938 146
124483	 443 281
```

6.Use the command below to run the project:

```command
time mix run proj1.exs 100000 200000
```

the output is :

```number
real    0m1.119s
user    0m3.995s
sys     0m0.162s
```

Thus the ratio is (0.162+3.995)/1.119=4.157

7.The largest problem I solved is from 100000 to 100000000. The largest vampire number I found is 98977920  9920 9726


