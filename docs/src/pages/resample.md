# [Resample](@id resample)

Let's assume that you have some time series with arbitrary timestamps and you need to bring the values to a new aligned grid with a fixed period in time.
For example, like this:

```@raw html
<pre>

 value:         1.0   2.0         3.0               4.0   5.0   6.0   7.0
 grid:      - - X - - X - - - - - X - - - - - - - - X - - X - - X - - X - -
 time:          1     2           4                 7     8     9     10

</pre>
```

To do this you will need a resampling method, which we will now look at in more detail.
The resampling method can be broken down into four steps:
- selecting the origin of the time grid.
- dividing the new grid into sub-intervals.
- defining the parameters of these sub-intervals, such as the closed side and the label side.
- Aggregation of values ​​falling into a new subinterval.

## Origin of the new time grid

First you need to select the `origin` of the new grid:
- `ORIGIN_OF_WINDOW (default)`: Origin of coordinates for the corresponding time type (Beginning of the year for dates, zero for numbers).
- `START_OF_WINDOW`: The first timestamp in the current time series.
- `END_OF_WINDOW`: The last timestamp in the current time series.

```@raw html
<pre>

 value:        1.0   2.0         3.0               4.0   5.0   6.0   7.0
 grid:    X - - X - - X - - - - - X - - - - - - - - X - - X - - X - - X - -
 time:    0     1     2           4                 7     8     9     10
          ^     ^                                                     ^
          |     |                                                     |
          |     START_OF_WINDOW                           END_OF_WINDOW
          ORIGIN_OF_WINDOW (default)

</pre>
```

## Period of the new time grid

Then, relative to the selected origin, a grid with a step of the specified `period` will be created

```@raw html
<pre>

 value:            1.0   2.0         3.0               4.0   5.0   6.0   7.0
 grid:        X - - X - - X - - - - - X - - - - - - - - X - - X - - X - - X - -
 time:        0     1     2           4                 7     8     9     10

</pre>

<pre>

 period = 2:  | - - - - - | - - - - - | - - - - - | - - - - - | - - - - - | - -
              0           2           4           6           8           10

 period = 3:  | - - - - - - - - | - - - - - - - - | - - - - - - - - | - - - - -
              0                 3                 6                 9
              ^
              |
              ORIGIN_OF_WINDOW (default)

</pre>

<pre>

 period = 2:  - - - | - - - - - | - - - - - | - - - - - | - - - - - | - - - - - 
                    1           3           5           7           9           

 period = 3:  - - - | - - - - - - - - | - - - - - - - - | - - - - - - - - | - - 
                    1                 4                 7                 10
                    ^
                    |
                    START_OF_WINDOW

</pre>

<pre>

 period = 2:  | - - - - - | - - - - - | - - - - - | - - - - - | - - - - - | - -
              0           2           4           6           8           10

 period = 3:  - - - | - - - - - - - - | - - - - - - - - | - - - - - - - - | - - 
                    1                 4                 7                 10
                                                                          ^
                                                                          |
                                                              END_OF_WINDOW

</pre>
```

## Parameters of sub-intervals

Finally, it only remains to determine which side of the subintervals will be closed, as well as on which side the aggregation of the values ​​falling within the interval will occur.
The following example shows how parameters `CLOSED_LEFT` and `CLOSED_RIGHT`, as well as `LABEL_LEFT` and `LABEL_RIGHT`, determine the behavior of the subintervals.

An example of the obtained sub-intervals with parameters `origin = ORIGIN_OF_WINDOW` and `period = 2`:

```@raw html
<pre>

 value:      1.0       2.0       3.0                       1.0       2.0       3.0
 grid:    - - X - - - - X - - - - X - -   ➤   - - | - - - - X - - - - | - - - - X - - - - | - -
 time:        1         2         3               0                   2                   4

</pre>
```

Possible options for decomposing values ​​into new sub-intervals for subsequent aggregation:

```@raw html
<table>
  <tr>
    <th></th>
    <th align=center>CLOSED_LEFT (default)</th>
    <th align=center>CLOSED_RIGHT</th>
  </tr>
  <tr>
    <th>LABEL_LEFT<br>(default)</th>
    <td>
<pre>

 value:       1.0       2.0   3.0
 grid:   [ - - - - - )[ - - - - - )  
 time:    ⤷ 0          ⤷ 2 

</pre>
    </td>
    <td>
<pre>

 value:    1.0   2.0       3.0
 grid:   ( - - - - - ]( - - - - - ]  
 time:    ⤷ 0          ⤷ 2 

</pre>
    </td>
  </tr>
  <tr>
    <th>LABEL_RIGHT</th>
    <td>
<pre>

 value:       1.0       2.0   3.0
 grid:   [ - - - - - )[ - - - - - )  
 time:            2 ⤶          4 ⤶ 

</pre>
    </td>
    <td>
<pre>

 value:    1.0   2.0       3.0
 grid:   ( - - - - - ]( - - - - - ]  
 time:            2 ⤶          4 ⤶

</pre>
    </td>
  </tr>
</table>
```

## Values aggregation

Finally, the old values ​​that fall into the new subinterval can be aggregated by applying some function, such as `sum`, `maximum`, `minimum`, `mean`, `median`, etc.

## API

```@docs
ta_resample
```
