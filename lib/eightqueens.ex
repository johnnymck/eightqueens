defmodule Eightqueens do
  @moduledoc """
  Documentation for `Eightqueens`.
  """

  @search_deltas  [
    {1,1},
    {1,-1},
    {-1,1},
    {-1,-1},
    {1,0},
    {-1,0},
    {0,1},
    {0,-1}
    ]

  def generate_position() do
    for _ <- 1..8, do: :rand.uniform(8)
  end

  def generate_initial_population(size) do
    for _ <- 1..size, do: generate_position()
  end

  def rank(population) do
    population
    |> Enum.map(fn (i) -> {i, fitness(i)} end)
    |> List.keysort(1)
    |> Enum.reverse # we want the list biggest at 0 and smallest at n
  end

  def crossover(a, b) do
    pos = :rand.uniform(8)
    Enum.take(a, pos) ++ Enum.take(b, -(8-pos))
  end

  def do_n_crossover(ranked_population, n) do
    {a, b} = Enum.split(Enum.take(ranked_population, n), round(n/2))
    Enum.zip_with(a, b, fn ({i, _}, {j, _}) -> crossover(i, j) end)
  end

  def descretise(0) do
    1
  end

  def descretise(matches) do
    1/(matches+1)
  end

  def check_bounds(x, y) do
    1 <= x && x < 9 && 1 <= y && y < 9
  end

  def fitness(board) do
    board
    |> all_moves
    |> matches(board)
    |> descretise
  end

  def all_moves_for_i(x, y, all_deltas \\ @search_deltas) do
    Enum.map(all_deltas, fn (delta) -> calculate_moves(delta, x, y) end)
    |> List.flatten
  end

  def all_moves(board, all_deltas \\ @search_deltas) do
    board
    |> Enum.with_index
    |> Enum.map(fn ({x,y}) -> all_moves_for_i(x, y, all_deltas) end)
    |> List.flatten
  end

  def matches(all_moves, board) do
    board
    |> Enum.with_index
    |> Enum.map(fn ({x,y}) -> Enum.member?(all_moves, {x,y}) end)
    |> Enum.count(fn (i) -> i == true end)
  end

  def calculate_moves(delta, x, y, moves \\ []) do
    {dx, dy} = delta
    if check_bounds(x+dx, y+dy) do
      calculate_moves(delta, x+dx, y+dy, [{x+dx, y+dy} | moves])
    else
      moves
    end
  end
end
