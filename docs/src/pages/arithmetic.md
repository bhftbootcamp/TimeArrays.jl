# Arithmetic

Time series support basic arithmetic operations, allowing you to perform the necessary calculations.
However, it is worth noting that such operations are performed in a slightly different way than on ordinary arrays, in which elements identical by index or value are compared.
In our implementation, time series values ​​are matched by the last known time value.

To better understand the idea of ​​time series matching, let's look at the following simple example of adding two time series:

```julia-repl
julia> t_array1 = TimeArray([
           TimeTick(1, 2.0),
           TimeTick(3, 4.0),
           TimeTick(7, 6.0),
       ]);

julia> t_array2 = TimeArray([
           TimeTick(3, 3.0),
           TimeTick(5, 5.0),
       ]);
```

Visually, these time series can be represented as follows:

```@raw html
<pre>

 time:   - - - 1 - - - - 2 - - - - 3 - - - - 4 - - - - 5 - - - - 6 - - - - 7 - - - >
 
              2.0                 4.0                                     6.0
 t_array1:     ● - - - - - - - - - ● - - - - - - - - - - - - - - - - - - - ● - - - > 
 
 t_array2:                         ● - - - - - - - - - ● - - - - - - - - - - - - - >
                                  3.0                 5.0

</pre>
```

Let's apply the addition operation to them.

```julia-repl
julia> t_array1 + t_array2
4-element TimeArray{Int64, Float64}:
 TimeTick(1, NaN)
 TimeTick(3, 7.0)
 TimeTick(5, 9.0)
 TimeTick(7, 11.0)
```

The expected behavior will be as follows:
- For the first timestamp `1` from the `t_array1` there is no time value from the `t_array2` one, so the resulting value of this timestamp will be `2.0 + NaN = NaN`.
- Then for timestamp `3` in both arrays there are values ​​(`4.0` and `3.0`), so as a result of addition we get `7.0`.
- At timestamp `5` in the `t_array2` a new value appears `5.0` for which in the `t_array1` the current value will be `4.0`. As a result we get `9.0`.
- Finally, at timestamp `7` happens the opposite of the previous case.

```@raw html
<pre>

 time:     - - - 1 - - - - 2 - - - - 3 - - - - 4 - - - - 5 - - - - 6 - - - - 7 - - - >
 
                2.0                 4.0﹉﹉﹉﹉﹉﹉﹉﹉﹉﹉﹉﹉﹉﹉﹉﹉﹉⤵                   6.0
 t_array1:       ● - - - - - - - - - ● - - - - - - - - - - - - - - - - - - - ● - - - >
                 ┊                   ┊                   ┊                   ┊
    +       [2.0 + NaN]         [4.0 + 3.0]         [4.0 + 5.0]         [6.0 + 5.0]
                 ┊                   ┊                   ┊                   ┊
 t_array2:       X                   ● - - - - - - - - - ● - - - - - - - - - - - - - >
                NaN                 3.0                 5.0 ﹍﹍﹍﹍﹍﹍﹍﹍﹍﹍﹍﹍﹍﹍﹍﹍﹍⤴
 
 result:         ● - - - - - - - - - ● - - - - - - - - - ● - - - - - - - - - ● - - - > 
                NaN                 7.0                 9.0                11.0

</pre>
```

Supported mathematical operations on time series:
- between two TimeArrays:
    - `+`: addition
    - `-`: subtraction
    - `*`: multiplication
    - `/`: division
- between TimeArray and other values
    - `+`: addition
    - `-`: subtraction
    - `*`: multiplication
    - `/`: division
    - `^`: exponentiation

For more flexible arithmetic work on TimeArrays, you can use functions [`ta_mergewith`](@ref) and [`ta_merge`](@ref).

## API

```@docs
ta_mergewith
ta_merge
```
