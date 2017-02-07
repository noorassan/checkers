defmodule Moves do
  import IEx

  @moduledoc """
  Contains functions that find lists of possible moves for a given piece
  A move is represented as {{x, y}, [{a, b}, {c, d}]}, where {x, y} are the coords being moved to and {a, b} and {c, d} and dying as a result
  """

  @board_rows 8
  @board_cols 8

  @doc """
  finds moves with hops and removes nested lists caused by recursion
  {x, y} -> starting coords
  """
  def find(board, {x, y}) do
    starting_square = Board.fetch_square(board, {x, y})
    adjacents = adjacents({x, y}, starting_square)

    Moves.filter_adjacents(adjacents, {x, y}, starting_square, board)
    |>find_with_hops({x, y}, starting_square, board)
    |>List.flatten()
  end

  @doc """
  find the set of possible moves for the square found at coords in board
  {x, y} -> the latest post_hop
  starting_square -> the original square being moved
  """
  def find_with_hops(possible_moves, {x, y}, starting_square, board) do
    Enum.map(possible_moves, fn({h, k}) ->
      move_square = Board.fetch_square(board, {h, k})

      if(move_square.affiliation == :empty) do
      # if there isn't a hop to be made
        {h, k}
      else
        post_hop_coords = calculate_post_hop_coords({h, k}, {x, y}, board)

        post_hop_moves = adjacents(post_hop_coords, starting_square)
          |>filter_hops_only(post_hop_coords, board)
          |>find_with_hops(post_hop_coords, starting_square, board)

        if(post_hop_moves == []) do
        #if there are no further hops, stop
          [post_hop_coords]
        else
          [post_hop_moves]
        end
      end
    end)
  end

  @doc """
  filters the moves found for the square at coords not accounting for hops
  """
  def filter_adjacents(moves, coords, square, board) do
    Enum.filter(moves, fn(move) ->
      moves_square = Board.fetch_square(board, move)
      is_in_bounds?(move) and 
      is_different_affiliation?(moves_square, square) and 
      is_valid_hop?(move, coords, board)
    end)  
  end

  @doc """
  filters the moves found for the square at coords to only include hops
  """
  def filter_hops_only(moves, coords, board) do
    Enum.filter_map(moves, 
      fn(move) ->
        moves_square = Board.fetch_square(board, move)
        is_populated?(moves_square)
      end,

      fn(move) ->
        calculate_post_hop_coords(move, coords, board)
      end)
  end

  @doc """
  returns the adjacent moves for the square based on coords
  {x, y} -> starting coords
  """
  def adjacents({x, y}, square) do
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
  returns boolean for whether move is in bounds or not
  """
  def is_in_bounds?({x, y}) do
    x < @board_rows and x >= 0 and y >= 0 and y < @board_cols
  end

  @doc """
  returns boolean for whether the square move points to is of different affiliation or not
  """
  def is_different_affiliation?(moves_square, starting_square) do
    moves_square.affiliation != starting_square.affiliation
  end

  @doc """
  returns boolean for whether the square move points to is populated or not
  """
  def is_populated?(moves_square) do
    moves_square.affiliation != :empty
  end

  @doc """
  returns boolean for whether the square move points to is empty or not
  """
  def is_empty?(moves_square) do
    moves_square.affiliation == :empty
  end

  @doc """
  returns boolean for whether the hop of move would point to an empty square
  """
  def is_valid_hop?(move, coords, board) do
    post_hop_coords = calculate_post_hop_coords(move, coords, board)
    
    unless(post_hop_coords == nil) do
      true
    else
      false
    end
  end 

  @doc """
  calculates the coords the square at {x, y} would land in if it hopped over the square at {h, k}
  """
  def calculate_post_hop_coords({h, k}, {x, y}, board) do
    post_hop_coords = {(h - x) + h, (k - y) + k}
    post_hop_square = Board.fetch_square(board, post_hop_coords)
    
    if(is_empty?(post_hop_square) and is_in_bounds?(post_hop_coords)) do
      post_hop_coords
    else
      nil
    end
  end
end
