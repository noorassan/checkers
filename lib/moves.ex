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

    Moves.filter_invalid_moves(adjacents, starting_square, board)
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

      if(Square.is_empty(move_square)) do
      # if there isn't a hop to be made
        {{h, k}, killed}
      else
        {post_hop_coords, post_hop_killed} = calculate_post_hop_move({h, k}, {x, y}, killed, board)

        adjacents_by_rank(post_hop_coords, starting_square, post_hop_killed)
        |>filter_out_non_hops(post_hop_coords, board)
        |>find_with_hops(post_hop_coords, starting_square, board)
      end
    end)
  end

  @doc """
  filters the moves found for the square at coords
  """
  def filter_invalid_moves(moves, square, board) do
    Enum.filter(moves, fn({move_coords, _killed}) ->
      if(is_in_bounds(move_coords)) do
        moves_square = Board.fetch_square(board, move_coords)

        (Square.is_different_affiliation(square, moves_square) or Square.is_empty(moves_square))
      else
        false
      end
    end)  
  end

  @doc """
  filters the moves found for the square at coords to only include hops
  """
  def filter_out_non_hops(moves, coords, board) do
    Enum.filter_map(moves, 
      fn({move_coords, killed}) ->
        if(is_in_bounds(move_coords)) do
          moves_square = Board.fetch_square(board, move_coords)

          Square.is_populated(moves_square) and
          is_valid_hop({move_coords, killed}, coords, board)
        else
          false
        end
      end,

      fn({move_coords, killed}) ->
        calculate_post_hop_move(move_coords, coords, killed, board)
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
  returns boolean for whether move is in bounds or not
  """
  def is_in_bounds({x, y}) do
    x <= @board_rows and x >= 0 and y >= 0 and y <= @board_cols
  end

  @doc """
  returns boolean for whether the hop of move would point to an empty square
  """
  def is_valid_hop({move_coords, killed}, coords, board) do
    post_hop_coords = calculate_post_hop_move(move_coords, coords, killed, board)
    
    unless(post_hop_coords == nil) do
      true
    else
      false
    end
  end 

  @doc """
  calculates the coords the square at {x, y} would land in if it hopped over the square at {h, k}
  """
  def calculate_post_hop_move({h, k}, {x, y}, killed, board) do
    post_hop_coords = {(h - x) + h, (k - y) + k}
    post_hop_square = Board.fetch_square(board, post_hop_coords)
    
    if(Square.is_empty(post_hop_square) and is_in_bounds(post_hop_coords)) do
      {post_hop_coords, [{h, k} | killed]}
    end
  end
end
