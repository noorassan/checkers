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
    |> check_for_pieces()
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

  def check_for_pieces(possible_moves, current_square_coords, board) do
    Enum.map_reduce(possible_moves, board, fn(possible_move, board) ->
      possible_move_square = Square.fetch(possible_move)
      cond do
        square.rank == :empty
  end
end
