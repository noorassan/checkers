defmodule Moves do

  @moduledoc """
  Contains functions that find lists of possible moves for a given piece
  """

  @doc """
  grabs the '%Square{}' from the 'coords' and sends the info to a function based on the 'Square's rank
  """
  def find_moves(board, coords) do
    square = Square.fetch(board, coords)

    case square.rank do
      :pawn ->
        find_pawn_moves(board, square, coords)
      :king ->
        find_king_moves(board, coords)
    end
  end

  @doc """
  filters the possible moves for a pawn by their affiliation and whether the pieces being moved to are populated
  """
  def find_pawn_moves(board, square, {x, y}) do
    if(square.affiliation == :friendly) do
      [{x - 1, y + 1}, {x + 1, y + 1}]
    else
      [{x - 1, y - 1}, {x + 1, y - 1}]
    end
    |> filter_out_negatives()
    |> filter_moves_by_population(board)
  end

  @doc """
  filters the possible moves for a king by whether or not the pieces being moved to are populated
  """
  def find_king_moves(board, {x, y}) do
    [{x - 1, y + 1}, {x + 1, y + 1}, {x - 1, y - 1}, {x + 1, y - 1}]
    |> filter_out_negatives()
    |> filter_moves_by_population(board)
  end

  @doc """
  filters a list of moves based on whether or not they refer to populated squares
  """
  def filter_moves_by_population(possible_moves, board) do
    Enum.filter(possible_moves, fn(possible_move) ->
      Square.fetch(board, possible_move)
      |> Square.is_empty()
    end)
  end

  @doc """
  filters out the moves with any negative coordinates from a list of moves
  """
  def filter_out_negatives(possible_moves) do
    Enum.filter(possible_moves, fn({x, y}) ->
      if(x >= 0 and y >= 0) do
        true
      else
        false
      end
    end)
  end
end
