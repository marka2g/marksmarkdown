%{
  title: "Elixir Datastructures and Memory",
  author: "Mark Sadegi",
  description: "Notes on how elixir manages memory of it's various data structures",
  tags: ~w(elixir lists tuples maps structs map_set),
  date: "2023-07-16"
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
# Links and Resources


[How Elixir Lays Out Your Data in Memory - _honeybadger_](https://www.honeybadger.io/blog/elixir-memory-structure/)

[fantasic appsignal blog post here](https://blog.appsignal.com/2018/08/21/elixir-alchemy-list-vs-tuples.html)

[...love this blog - openmymind](https://www.openmymind.net)