%{
  title: "Elixir Data Structures and Memory",
  author: "Mark Sadegi",
  description: "Notes on how elixir manages memory of it's various data structures",
  tags: ~w(elixir lists tuples maps structs map_set),
  date: "2022-11-07"
}
---

## Lists v. Tuples

### _**Tuples**_ 
are placed in contiguous memory slots and behave like **static** data structures. they are not meant to change.
- meant for single data points that have a **fixed** number of elements
- memory usage is **static** and allocated **upfront**
- does **NOT** support insertion or deletion. any change requires a complete copy

```elixir
iex(1)> tuple = {false, 1, 2, 3, false}

# use cases - key/value pair mappings
iex(3)> a = {:name, "Mark"}
iex(4)> b = {:rank, :general}

# which lends itself to Keyword lists
# in Elixir, Keyword Lists are syntactic sugar for a List
# with Tuples. so this:
iex(5)> kw_list = [name: "Mark", rank: :general]

# equals this:
iex(6)> list = [{:name, "Mark"}, {:rank, :general}]

# verify it with:
iex(7)> Enum.at(list, 0)
# => {:name, "Mark"}
```

how would this look in memory?
<image src="/images/notes/keyword_list_in_mem.png" alt="keyword_list_in_mem" />


###  _**Lists**_ 
specifically in Elixir, are implemented as **linked lists** and are used to hold variable-length data. distributed arbitrarily, in no particular order, with each element holding a reference to the next one:
- supports **insertion**/**deletion**
- **O(n)** linear time
- fetching can be **slow**


```elixir
iex(2)> list = [false, 1, 2, 3, false]
```



---

honeybadger article - MAKE A TABLE of Data containers

Understanding the underlying memory representation grants us the ability to adequately choose which data structures to use in a particular use-case.

`C` - `malloc` & `free`

```c
int *some_array;
some_array = (int *) malloc(sizeof(int) * 5);
free(some_array);
```

what happens if we don't call `free()`? -> **memory leak**



"Memory is like a jar of nails, when program first starts, the jar is full and may be used at will. However, not putting the nails back into the jar when we no longer need them can eventually lead to not having enough nails to do our job. The memory in our system is our jar, and we ought to keep track of our nails or risk running out of them. This is the premise for a low-level language with manual memory management, such as C."


### `garbage collection`
Elixir -> higher-level lang - takes care of memory management
>```elixir
>list = [1, 2, 3, 4]
>#=> [1, 2, 3, 4]
>dubbled_list = list |> Enum.map(&(&1 * 2))
>#=> [2, 4, 6, 8]
>```


## Data Containers in Erlang/Elixir
### `word`
the fundamental data unit

>```elixir
>:erlang.system_info(:wordsize)
># => 8
>```

```elixir
:erts_debug.size/1 
:erts_debug.flat_size/1 
```


### `literals` & `immediates`
types that fit into a single machine word such as `small integers`, local process identifiers (`PIDs`), `ports`, `atoms`, or a `NIL` value(_stands for the empty list_), n.t.b.c.w. the atom `nil`

### `Atoms`
the most distinct of the `immediates`; never garbage-collected. once created, it will live in memory until the system exits. when a given atom is created more than once, its memory footprint does not double. Instead of copying atoms, refs are used to access the respective slot in the table. This can be seen when using the `:erts_debug.size/1` function with an atom argument:
>```elixir
>:erts_debug.size(:some_atom)
># => 0
>
># The word size is zero because the atom itself 
># lives in the atom table, and we are just passing 
># references to that particular slot.
>```


## Boxed Values
`lists`, `tuples`, `maps`, `binaries`, `remote PID`s and `ports`, `floats`, `large integers`, `functions`, and `exports`

this article focuses on the firs four: `lists`, `tuples`, `maps`, `binaries`


### Lists



---
# Links and Resources


[How Elixir Lays Out Your Data in Memory - _honeybadger_](https://www.honeybadger.io/blog/elixir-memory-structure/)

[fantasic appsignal blog post here](https://blog.appsignal.com/2018/08/21/elixir-alchemy-list-vs-tuples.html)

[...love this blog - openmymind](https://www.openmymind.net)