defmodule Moves do

  @moduledoc """
  Contains functions that find lists of possible moves for a given piece
  """

  @doc """
  grabs a 'Square' from the 'coords' tuple passed in, calculates possible moves, and filters them by validity
  """
  def find(board, coords) do
    Square.fetch(board, coords)
    |> possible_moves(coords)
    |> filter_negatives()
    |> filter_out_of_bounds()
    |> adjust_for_kills(board, coords)
  end

  @doc """
  filters out the moves with any negative coordinates from a list of moves
  """
  def filter_negatives(possible_moves) do
    Enum.filter(possible_moves, fn({x, y}) ->
      x >= 0 and y >= 0 
    end)
  end

  @doc """
  filters out the moves with out of bounds values
  """
  def filter_out_of_bounds(possible_moves) do
    Enum.filter(possible_moves, fn({x, y}) ->
      x <= 7 and y <= 7
    end)
  end

  def possible_moves(square, {x, y}) do
    case square.rank do
      :pawn ->
        case square.affiliation do
          :friendly ->
            [{x - 1, y + 1}, {x + 1, y + 1}]
          :enemy ->
            [{x - 1, y - 1}, {x + 1, y - 1}]
        end
      :king ->
        [{x - 1, y + 1}, {x + 1, y + 1}, {x - 1, y - 1}, {x + 1, y - 1}]
      :empty ->
        []
    end
  end

  def adjust_for_kills(possible_moves, board, {x, y}) do
    Enum.map(possible_moves, fn({x2, y2}) ->
      unless(Square.is_empty(Square.fetch(board, {x, y}))) do
        board = Board.kill_square(board, {x2, y2})
        #moves the piece one more in whatever direction the possible_move was from the original square
        post_hop_coords = {x2 + (x2 - x), y2 + (y2 - y)}
        find(board, post_hop_coords)
      else
        {x2, y2}
      end
    end)
  end
end
