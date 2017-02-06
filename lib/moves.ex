defmodule Moves do
  import IEx

  @moduledoc """
  Contains functions that find lists of possible moves for a given piece
  A move is represented as {{x, y}, [{a, b}, {c, d}]}, where {x, y} are the coords being moved to and {a, b} and {c, d} and dying as a result
  """

  @board_rows 8
  @board_cols 8


  @doc """
  find the set of possible moves for the square found at coords in board
  """
  #TODO add a list of victim pieces with each move (it will only be populated in the case of a hop)
  def find_with_hops(board, {x, y}) do
    starting_square = Board.fetch_square(board, {x, y})
    possible_moves = find_without_hops(board, {x, y}, starting_square)
    
    Enum.map(possible_moves, fn({h, k}) ->
      move_square = Board.fetch_square(board, {h, k})

      unless(move_square.affiliation == starting_square.affiliation or move_square.affiliation == :empty) do
        post_hop_coords = calculate_post_hop_coords(board, starting_square, {x, y}, {h, k})
        [post_hop_coords | find(board, post_hop_coords)]
      else
        {h, k}
      end
    end)
  end

  @doc """
  finds the set of possible moves for the square found at coords in board without accounting for hops
  """
  def find_without_hops(board, coords, square)do
    adjacent_moves(coords, square)
    |> filter_out_of_bounds()
    |> filter_out_same_affiliation_squares(board, square)
  end

  @doc """
  returns the adjacent moves for the square based on coords
  """
  def adjacent_moves({x, y}, square) do
    case square.rank do
      :empty ->
        []
      :king ->
        [{x - 1, y - 1}, {x - 1, y + 1}, {x + 1, y - 1}, {x + 1, y + 1}]
      :pawn ->
        case square.affiliation do
          :friendly ->
            [{x - 1, y + 1}, {x + 1, y + 1}]
          :enemy ->
            [{x - 1, y - 1}, {x + 1, y - 1}]
        end
      end
  end

  @doc """
  unless moves is an empty list, filters out tuples in moves that would refer to squares outside of the board
  """
  def filter_out_of_bounds([]), do: []
  def filter_out_of_bounds(moves) do
    Enum.filter(moves, fn({x, y}) -> 
      x < @board_rows and y < @board_cols
    end)
  end

  @doc """
  unless moves is an empty list, filters out tuples in moves that would refer to squares containing same-affiliationd pieces
  """
  def filter_out_same_affiliation_squares([], _moving_square), do: []
  def filter_out_same_affiliation_squares(moves, board, starting_square) do
    Enum.filter(moves, fn(move) ->
      moves_square = Board.fetch_square(board, move)
      starting_square.affiliation != moves_square.affiliation
    end)
  end

  @doc """
  calculates the coords the square at {x, y} would land in if it hopped over the square at {h, k}
  """
  def calculate_post_hop_coords(board, starting_square, {x, y}, {h, k}) do
    coords_list = [{(h - x) + h, (k - y) + k}]
    |> filter_out_of_bounds()
    |> filter_out_same_affiliation_squares(board, starting_square)

    unless(coords_list == []) do
      [coords] = coords_list
      coords
    else
      nil
    end
  end
end
