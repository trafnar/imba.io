# break

The break statement terminates the current loop or switch statement and transfers program control to the statement following the terminated statement.

### Break in loop [preview=console]
```imba
for item in [1,2,3,4,5]
    console.log item
    break if item == 3
```

Loops are expressions and return an array consisting of the values of each loop iteration. When you break in a loop, it will not add any more items to the resulting array.
```imba main.imba
let ary = for item in [1,2,3,4,5]
    break if item == 3
    item
console.log ary
```
You can include an argument to break, which will them be included in the results.
```imba main.imba
let ary = for item in [1,2,3,4,5]
    break 'last' if item == 3
    item * 2
console.log ary
```

### Break in switch

