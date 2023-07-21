%{
  title: "My Idiomatic Elixir",
  author: "Mark Sadegi",
  description: "A grouping of various elixir idioms and tips",
  tags: ~w(elixir lists tuples maps structs map_set iex enum),
  date: "2023-07-11"
}
---

## Elixir Tips and Idioms

### _Maps_

to get a value from a **nested map**, use the `h Kernel.get_in()` function

```elixir
iex(1)> h Kernel.get_in

iex(2)> maps_in_map = 
iex(...)> %{uno: %{dos: %{tres: "loco"}}}

iex(3)> get_in(
iex(...)> maps_in_map, 
iex(...)> [:uno, :dos, :tres]
iex(...)>)
# => "loco"
```

### _Structs_
to get a value from a **struct**, use the **.** syntax. note, **Access** protocol ~~**%SomeStruct{mood: "happy"}[:mood]**~~ does not work on **structs**

```elixir
# define a struct
defmodule SomeStruct do
  defstruct mood: nil
end

"happy" = %SomeStruct{mood: "happy"}.mood
# => "happy"

# under the hood, a struct is just a Map 
# with the special __struct__ attribute
%SomeStruct{}.__struct__
# => SomeStruct

# so, except for the Access protocol, 
# we could also use the Map functions
"happy" = Map.get(%SomeStruct{mood: "happy"}, :mood)
# => "happy"

# but the best way to extract a value from a 
# struct, ...pattern match
%{mood: mood} = %SomeStruct{mood: "happy"}
# mood => "happy"
%SomeStruct{mood: mood} = %SomeStruct{mood: "happy"}
# mood => "happy

```


### _IEx_

default config in **iex.exs**
```elixir
IEx.configure(
  colors: [
    enabled: true,
    eval_result: [:light_green],
    eval_error: [:light_magenta],
    stack_info: [:light_blue]
  ],
  default_prompt:
    [
      # a neon purple
      "\r\e[38;5;129m",
      # IEx context
      "%prefix",
      # forest green expression count
      "\e[38;5;112m(%counter)",
      # neon purple ">"
      "\e[38;5;129m>",
      # and reset to default color
      "\e[0m"
    ]
    # (1)
    |> IO.chardata_to_string()
)
```

note: **default_prompt** uses [**IO.ANSI** color codes](https://talyian.github.io/ansicolors/){:target="_blank"}