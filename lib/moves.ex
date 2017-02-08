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
    adjacents = adjacents_by_rank({x, y}, starting_square)

    Moves.filter_hops(adjacents, {x, y}, starting_square, board)
    |>find_with_hops({x, y}, starting_square, board)
    |>List.flatten()
  end

  @doc """
  find the set of possible moves for the square found at coords in board
  {x, y} -> the latest post_hop
  starting_square -> the original square being moved
  """
  def find_with_hops(possible_moves, {x, y}, starting_square, board) do
    Enum.map(possible_moves, fn({{h, k}, killed}) ->
      move_square = Board.fetch_square(board, {h, k})

      if(move_square.rank == :empty) do
      # if there isn't a hop to be made
        {{h, k}, killed}
      else
        {post_hop_coords, post_hop_killed} = calculate_post_hop_move({h, k}, {x, y}, board, killed)

        post_hop_moves = adjacents(post_hop_coords, post_hop_killed)
          |>filter_out_non_hops(post_hop_coords, board)
          |>find_with_hops(post_hop_coords, starting_square, board)

        if(post_hop_moves == []) do
        #if there are no further hops, stop
          [{post_hop_coords, post_hop_killed}]
        else
          [post_hop_moves]
        end
      end
    end)
  end

  @doc """
  filters the moves found for the square at coords not calculating post_hop_coords for hops
  """
  def filter_hops(moves, coords, square, board) do
    Enum.filter(moves, fn({move_coords, killed}) ->
      moves_square = Board.fetch_square(board, move_coords)

      is_in_bounds(move_coords) and 
      (is_different_affiliation(moves_square, square) or is_empty(moves_square)) and 
      is_valid_hop({move_coords, killed}, coords, board)
    end)  
  end

  @doc """
  filters the moves found for the square at coords to only include hops
  """
  def filter_out_non_hops(moves, coords, board) do
    Enum.filter_map(moves, 
      fn({move_coords, _killed}) ->
        moves_square = Board.fetch_square(board, move_coords)
        is_populated(moves_square)
      end,

      fn({move_coords, killed}) ->
        calculate_post_hop_move(move_coords, coords, board, killed)
      end)
    |>Enum.filter(fn(move) -> !is_nil(move) end)
  end

  @doc """
  returns the adjacent moves for the coords based on their square's rank
  {x, y} -> starting coords
  """
  def adjacents_by_rank({x, y}, square, killed \\ []) do
    case square.rank do
      :empty ->
        []
      :king ->
        [{{x - 1, y - 1}, killed}, {{x - 1, y + 1}, killed}, {{x + 1, y - 1}, killed}, {{x + 1, y + 1}, killed}]
      :pawn ->
        case square.affiliation do
          :friendly ->
            [{{x - 1, y + 1}, killed}, {{x + 1, y + 1}, killed}]
          :enemy ->
            [{{x - 1, y - 1}, killed}, {{x + 1, y - 1}, killed}]
        end
    end
  end

  @doc """
  returns the adjacent moves for the coords, ignoring the rank of coords' square
  {x, y} -> starting coords
  """
  def adjacents({x, y}, killed \\ []) do
    [{{x - 1, y - 1}, killed}, {{x - 1, y + 1}, killed}, {{x + 1, y - 1}, killed}, {{x + 1, y + 1}, killed}]
  end

  @doc """
  returns boolean for whether move is in bounds or not
  """
  def is_in_bounds({x, y}) do
    x < @board_rows and x >= 0 and y >= 0 and y < @board_cols
  end

  @doc """
  returns boolean for whether the square move points to is of different affiliation or not
  """
  def is_different_affiliation(moves_square, starting_square) do
    moves_square.affiliation != starting_square.affiliation
  end

  @doc """
  returns boolean for whether the square move points to is populated or not
  """
  def is_populated(moves_square) do
    moves_square.rank != :empty
  end

  @doc """
  returns boolean for whether the square move points to is empty or not
  """
  def is_empty(moves_square) do
    moves_square.rank == :empty
  end

  @doc """
  returns boolean for whether the hop of move would point to an empty square
  """
  def is_valid_hop({move_coords, killed}, coords, board) do
    post_hop_coords = calculate_post_hop_move(move_coords, coords, board, killed)
    
    unless(post_hop_coords == nil) do
      true
    else
      false
    end
  end 

  @doc """
  calculates the coords the square at {x, y} would land in if it hopped over the square at {h, k}
  """
  def calculate_post_hop_move({h, k}, {x, y}, board, killed) do
    post_hop_coords = {(h - x) + h, (k - y) + k}
    post_hop_square = Board.fetch_square(board, post_hop_coords)
    
    if(is_empty(post_hop_square) and is_in_bounds(post_hop_coords)) do
      {post_hop_coords, [{h, k} | killed]}
    else
      nil
    end
  end
end
