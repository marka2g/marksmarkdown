%{
  title: "The Elixir Enum Module",
  author: "Mark Sadegi",
  description: "Breaking down the Enum module and it's functions by category",
  tags: ~w(elixir enum),
  date: "2023-07-16"
}
---

## Enum

This is not the full list but in general,  **Enum** module functions can be broken down into 3 main categories. _see_ **iex> h Enum. + tab** for a full list.
* **Cleansing data**
>_`filter()`, `reject()`, `uniq()` and `uniq_by()`_
* **Massaging data**
> _`map()`, `group_by()`, `split_with()`, `sort_by()` and  `with_index()`_
* **Summarizing data**
> _`reduce()`, `reduce_while()`, `frequencies()` and `frequencies_by()`_

### 1. _**Cleansing data**_ 
* `Enum.filter()`
>```elixir
>langs = [
>  %{language: "Elixir", type: :concurrent},
>  %{language: "Ruby", type: :not_concurrent},
>  %{language: "Rust", type: :concurrent},
>]
>Enum.filter(langs, fn 
>   %{type: :concurrent} -> true
>   _ -> false
>end)
>#[
>#  %{language: "Elixir", type: :concurrent},
>#  %{language: "Rust", type: :concurrent}
>#]
>```
* `Enum.reject()`
>```elixir
>Enum.reject(langs, fn lang ->
>  match?(%{type: :not_concurrent}, lang)
>end)
>#[
>#  %{language: "Elixir", type: :concurrent},
>#  %{language: "Rust", type: :concurrent}
>#]
>
># Enum.filter using a guard `when`
>Enum.filter(langs, fn
>  %{language: lang} when lang in ["Rust", "Ruby"] -> true
>  _ -> false
>end)
>#[
>#  %{language: "Rust", type: :concurrent}
>#  %{language: "Ruby", type: :not_concurrent},
>#]
>```
* `Enum.uniq()`
>```elixir
>dogs =
>  [
>    %{id: 1, breed: "Pit Bull"}, 
>    %{id: 1, breed: "Pit Bull"}, 
>    %{id: 1, breed: "American Pit Bull Terrier"}, 
>    %{id: 2, breed: "Great Pyrenees"}, 
>    %{id: 2, breed: "Pyrenees"}, 
>    %{id: 2, breed: "Pyrenees"}, 
>    %{id: 3, breed: "Labrador"}
>  ]
>Enum.uniq(dogs)
>#[
>#  %{breed: "Pit Bull", id: 1},
>#  %{breed: "American Pit Bull Terrier", id: 1},
>#  %{breed: "Great Pyrenees", id: 2},
>#  %{breed: "Pyrenees", id: 2},
>#  %{breed: "Labrador", id: 3}
>#]
>```
* `Enum.uniq_by()`
>```elixir
>Enum.uniq_by(dogs, fn dog -> 
>  dog.id
>end)
>#[
>#  %{breed: "Pit Bull", id: 1},
>#  %{breed: "Great Pyrenees", id: 2},
>#  %{breed: "Labrador", id: 3}
>#]
>
># another way to write the above
>dogs |> Enum.uniq_by(&(&1.id))
>#[
>#  %{breed: "Pit Bull", id: 1},
>#  %{breed: "Great Pyrenees", id: 2},
>#  %{breed: "Labrador", id: 3}
>#]
>```

### 2. _**Massaging data**_
* `Enum.map()`
>```elixir
>guitars_inventory = [
>   %{year: 1967, make: "Gibson", model: "Les Paul"},
>   %{year: 2020, make: "Fender", model: "Stratocaster"}, 
>   %{year: 1994, make: "Martin", model: "D-18"},
>   %{year: 2000, make: "Taylor", model: "D-28"},
>   %{year: 2014, make: "PRS", model: "Custom 24 Floyd"}, 
>   %{year: 2023, make: "PRS", model: "McCarty 594 Hollowbody II"}, 
>   %{year: 1997, make: "Parker", model: "Fly Deluxe"},
>   %{make: "Parker", model: "Fly Deluxe"},
>]
>
>guitars_inventory
>|> Enum.map(fn
>    %{year: year, make: make, model: model} = entry
>    when not is_nil(year) and not is_nil(make) and not is_nil(model) ->
>      "#{year} #{make} #{model}" 
>      _ -> 
>        :invalid_data
>end)
>|> Enum.reject(fn 
>    :invalid_data -> true
>    _ -> false
>end)
>#[ 
>#  "1967 Gibson Les Paul", 
>#  "2020 Fender Stratocaster", 
>#  "1994 Martin D-18",
>#  "2000 Taylor D-28", 
>#  "2014 PRS Custom 24 Floyd",
>#  "2023 PRS McCarty 594 Hollowbody II", 
>#  "1997 Parker Fly Deluxe"
>#]
>```
* `Enum.group_by()`
>```elixir
>guitars_inventory
>|> Enum.group_by(fn
>     %{make: make} -> make
>end)
>#%{
>#  "Fender" => [%{make: "Fender", model: "Stratocaster", year: 2020}],
>#  "Gibson" => [%{make: "Gibson", model: "Les Paul", year: 1967}],
>#  "Martin" => [%{make: "Martin", model: "D-18", year: 1994}],
>#  "PRS" => [
>#    %{make: "PRS", model: "Custom 24 Floyd", year: 2014},
>#    %{make: "PRS", model: "McCarty 594 Hollowbody II", year: 2023}
>#  ],
>#  "Parker" => [
>#    %{make: "Parker", model: "Fly Deluxe", year: 1997},
>#    %{make: "Parker", model: "Fly Deluxe"}
>#  ],
>#  "Taylor" => [%{make: "Taylor", model: "D-28", year: 2000}]
>#}
>```
* `Enum.split_with()`
>```elixir
>guitars_inventory
>|> Enum.split_with(fn guitar ->
>    Map.has_key?(guitar, :year)
>end)
>#{
>#  [
>#    %{make: "Gibson", model: "Les Paul", year: 1967},
>#    %{make: "Fender", model: "Stratocaster", year: 2020},
>#    %{make: "Martin", model: "D-18", year: 1994},
>#    %{make: "Taylor", model: "D-28", year: 2000},
>#    %{make: "PRS", model: "Custom 24 Floyd", year: 2014},
>#    %{make: "PRS", model: "McCarty 594 Hollowbody II", year: 2023},
>#    %{make: "Parker", model: "Fly Deluxe", year: 1997}
>#  ], 
>#  [%{make: "Parker", model: "Fly Deluxe"}]
>#}
>```

* `Enum.sort_by()`
>```elixir
>guitars_inventory
>|> Enum.sort_by(fn
>  %{year: year} -> year
>  _ -> nil
>end)
>|> Enum.with_index(1)
>|> Enum.map(fn 
>    {%{year: year, make: make, model: model}, index} ->
>      "#{index}, #{year} #{make} #{model}"
>    {%{make: make, model: model}, index} ->
>      "#{index}, #{make} #{model}"
>end)
>
>#[
>#  "1, 1967 Gibson Les Paul", 
>#  "2, 1994 Martin D-18", 
>#  "3, 1997 Parker Fly Deluxe",
>#  "4, 2000 Taylor D-28", 
>#  "5, 2014 PRS Custom 24 Floyd",
>#  "6, 2020 Fender Stratocaster", 
>#  "7, 2023 PRS McCarty 594 Hollowbody II",
>#  "8, Parker Fly Deluxe"
>#]
>```

### 3. _**Summarizing data**_
* `Enum.reduce()` _with MapSet.new()_
>```elixir
>guitars_inventory
>|> Enum.reduce(MapSet.new(), fn %{make: make}, acc ->
>     MapSet.put(acc, make)
>end)
>|> MapSet.to_list()
>
>#["Fender", "Gibson", "Martin", "PRS", "Parker", "Taylor"]
>```
* `Enum.reduce_while()`
>```elixir
>guitars_inventory
>|> Enum.reduce_while(MapSet.new(), fn
>    %{year: year}, acc -> 
>      {:cont, MapSet.put(acc, year)}
>    _, _ ->
>      {:halt, {:error, "Missing year"}}
>end)
>#{:error, "Missing year"}
>```
* `Enum.frequencies()`
>```elixir
>guitars_inventory
>|> Enum.map(fn %{make: make} -> make end)
>|> Enum.frequencies()
>#%{
>#  "Fender" => 1,
>#  "Gibson" => 1,
>#  "Martin" => 1,
>#  "PRS" => 2,
>#  "Parker" => 2,
>#  "Taylor" => 1
>#}
>```
* `Enum.frequencies_by()`
>```elixir
>guitars_inventory
>|> Enum.map(fn %{make: make} -> make end)
>|> Enum.frequencies_by(fn guitar -> 
>    String.downcase(guitar)
>end)
>#%{
>#  "fender" => 1,
>#  "gibson" => 1,
>#  "martin" => 1,
>#  "parker" => 2,
>#  "prs" => 2,
>#  "taylor" => 1
>#}
>```