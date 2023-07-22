%{
  title: "The Elixir Enum Module",
  author: "Mark Sadegi",
  description: "Breaking down the Enum module and it's functions by category",
  tags: ~w(elixir enum),
  date: "2023-07-16"
}
---

<a id="top"></a>

# Enum

This is not the full list but in general, **Enum** module functions can be broken down into 3 main categories. _see_ **iex> h Enum. + tab** for a full list.
* [**1. Cleansing data**](#cleansing-data)
>_[`filter()`](#filter), [`reject()`](#reject), [`uniq()`](#uniq) and [`uniq_by()`](#uniq-by)_
* [**2. Massaging data**](#massaging-data)
> _[`map()`](#map), [`group_by()`](#group-by), [`split_with()`](#split-with), [`sort_by()`](#sort-by) and  [`with_index()`](#with-index)_
* [**3. Summarizing data**](#summarizing-data)
> _[`reduce()`](#reduce), [`reduce_while()`](#reduce-with), [`frequencies()`](#frequencies) and [`frequencies_by()`](#frequencies-by)_


## Data Setup

<a id="languages"></a>

### languages list of maps
>```elixir
>languages = [
>  %{language: "Elixir", type: :concurrent},
>  %{language: "Ruby", type: :not_concurrent},
>  %{language: "Rust", type: :concurrent},
>]
>```

<a id="dogs"></a>

### dogs list of maps
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
>```

<a id="guitars"></a>

### guitars list of maps
>```elixir
>guitars = [
>   %{year: 1967, maker: "Gibson", model: "Les Paul"},
>   %{year: 2020, maker: "Fender", model: "Stratocaster"}, 
>   %{year: 1994, maker: "Martin", model: "D-18"},
>   %{year: 2000, maker: "Taylor", model: "D-28"},
>   %{year: 2014, maker: "PRS", model: "Custom 24 Floyd"}, 
>   %{year: 2023, maker: "PRS", model: "McCarty 594 Hollowbody II"}, 
>   %{year: 1997, maker: "Parker", model: "Fly Deluxe"},
>   %{maker: "Parker", model: "Fly Deluxe"},
>]
>
>```


<a id="cleansing-data"></a>

## _**1. Cleansing data**_ 

<a id="filter"></a>

* ### `Enum.filter()` [**⬆︎**](#top)
>```elixir
>Enum.filter(languages, fn 
>   %{type: :concurrent} -> true
>   _ -> false
>end)
>#[
>#  %{language: "Elixir", type: :concurrent},
>#  %{language: "Rust", type: :concurrent}
>#]
>```
> [languages list of maps](#languages)


<a id="reject"></a>

* ### `Enum.reject()` [**⬆︎**](#top)
>```elixir
>Enum.reject(languages, fn lang ->
>  match?(%{type: :not_concurrent}, lang)
>end)
>#[
>#  %{language: "Elixir", type: :concurrent},
>#  %{language: "Rust", type: :concurrent}
>#]
>
># Enum.filter using a when guard
>Enum.filter(languages, fn
>  %{language: lang} when lang in ["Rust", "Ruby"] -> true
>  _ -> false
>end)
>#[
>#  %{language: "Rust", type: :concurrent}
>#  %{language: "Ruby", type: :not_concurrent},
>#]
>```
> [languages list of maps](#languages)

<a id="uniq"></a>

* ### `Enum.uniq()` [**⬆︎**](#top)
>```elixir
>Enum.uniq(dogs)
>#[
>#  %{breed: "Pit Bull", id: 1},
>#  %{breed: "American Pit Bull Terrier", id: 1},
>#  %{breed: "Great Pyrenees", id: 2},
>#  %{breed: "Pyrenees", id: 2},
>#  %{breed: "Labrador", id: 3}
>#]
>```
> [dogs list of maps](#dogs)

<a id="uniq-by"></a>

* ### `Enum.uniq_by()` [**⬆︎**](#top)
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
> [dogs list of maps](#dogs)


<a id="massaging-data"></a>

## 2. _**Massaging data**_

<a id="map"></a>

* ### `Enum.map()` [**⬆︎**](#top)
>```elixir
>guitars
>|> Enum.map(fn
>    %{year: year, maker: make, model: model} = entry
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
> [guitars list of maps](#guitars)


<a id="group-by"></a>

* ### `Enum.group_by()` [**⬆︎**](#top)
>```elixir
>guitars
>|> Enum.group_by(fn
>     %{maker: make} -> make
>end)
>#%{
>#  "Fender" => [%{maker: "Fender", model: "Stratocaster", year: 2020}],
>#  "Gibson" => [%{maker: "Gibson", model: "Les Paul", year: 1967}],
>#  "Martin" => [%{maker: "Martin", model: "D-18", year: 1994}],
>#  "PRS" => [
>#    %{maker: "PRS", model: "Custom 24 Floyd", year: 2014},
>#    %{maker: "PRS", model: "McCarty 594 Hollowbody II", year: 2023}
>#  ],
>#  "Parker" => [
>#    %{maker: "Parker", model: "Fly Deluxe", year: 1997},
>#    %{maker: "Parker", model: "Fly Deluxe"}
>#  ],
>#  "Taylor" => [%{maker: "Taylor", model: "D-28", year: 2000}]
>#}
>```
> [guitars list of maps](#guitars)

<a id="split-with"></a>

* ### `Enum.split_with()` [**⬆︎**](#top)
>```elixir
>guitars
>|> Enum.split_with(fn guitar ->
>    Map.has_key?(guitar, :year)
>end)
>#{
>#  [
>#    %{maker: "Gibson", model: "Les Paul", year: 1967},
>#    %{maker: "Fender", model: "Stratocaster", year: 2020},
>#    %{maker: "Martin", model: "D-18", year: 1994},
>#    %{maker: "Taylor", model: "D-28", year: 2000},
>#    %{maker: "PRS", model: "Custom 24 Floyd", year: 2014},
>#    %{maker: "PRS", model: "McCarty 594 Hollowbody II", year: 2023},
>#    %{maker: "Parker", model: "Fly Deluxe", year: 1997}
>#  ], 
>#  [%{maker: "Parker", model: "Fly Deluxe"}]
>#}
>```
> [guitars list of maps](#guitars)

<a id="sort-by"></a>

* ### `Enum.sort_by()` [**⬆︎**](#top)
>```elixir
>guitars
>|> Enum.sort_by(fn
>  %{year: year} -> year
>  _ -> nil
>end)
>|> Enum.with_index(1)
>|> Enum.map(fn 
>    {%{year: year, maker: make, model: model}, index} ->
>      "#{index}, #{year} #{make} #{model}"
>    {%{maker: make, model: model}, index} ->
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
> [guitars list of maps](#guitars)

<a id="summarizing-data"></a>

## 3. _**Summarizing data**_ 

<a id="reduce"></a>

* ### `Enum.reduce()` _with MapSet.new()_
>```elixir
>guitars
>|> Enum.reduce(MapSet.new(), fn %{maker: make}, acc ->
>     MapSet.put(acc, make)
>end)
>|> MapSet.to_list()
>
>#["Fender", "Gibson", "Martin", "PRS", "Parker", "Taylor"]
>```
> [guitars list of maps](#guitars)

<a id="reduce-while"></a>

* ### `Enum.reduce_while()` [**⬆︎**](#top)
>```elixir
>guitars
>|> Enum.reduce_while(MapSet.new(), fn
>    %{year: year}, acc -> 
>      {:cont, MapSet.put(acc, year)}
>    _, _ ->
>      {:halt, {:error, "Missing year"}}
>end)
>#{:error, "Missing year"}
>```

<a id="frequencies"></a>

* ### `Enum.frequencies()` [**⬆︎**](#top)
>```elixir
>guitars
>|> Enum.map(fn %{maker: make} -> make end)
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
> [guitars list of maps](#guitars)

<a id="frequencies-by"></a>

* ### `Enum.frequencies_by()` [**⬆︎**](#top)
>```elixir
>guitars
>|> Enum.map(fn %{maker: make} -> make end)
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
> [guitars list of maps](#guitars)