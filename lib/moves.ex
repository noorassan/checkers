defmodule Moves do

  @moduledoc """
  Contains functions that find lists of possible moves for a given piece
  """

  @doc """
  grabs a the Square from the board for the coords tuple passed in, calculates possible moves, and filters them by validity
  """
  def find(board, current_coords, post_move_coords) do
    Square.fetch(board, current_coords)
    |> possible_moves(current_coords)
    |> filter_negatives()
    |> filter_out_of_bounds()
    |> check_for_pieces(current_coords, post_move_coords, board)
  end

  @doc """
  gives the possible moves for a Square based on rank/affiliation
  """
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

  @doc """
  accounts for the moves that take you into a populated square
  """

  def check_for_pieces(possible_moves, {x, y}, post_move_coords, board) do
    Enum.map_reduce(possible_moves, board, fn(possible_move = {a, b}, board) ->
      possible_move_square = Square.fetch(board, possible_move)
      cond do
        possible_move_square.rank == :empty ->
          {possible_move, board}
        possible_move_square.affiliation == :friendly ->
          {nil, board}
        possible_move_square.affiliation == :enemy ->
          {moves, board} = account_for_hops({(a - y) + a, (b - x) + b}, possible_move, post_move_coords, board)
          {List.flatten(moves), board}
      end
    end)
  end

  def account_for_hops(post_hop_coords, victim_coords, post_move_coords, board) do 
    altered_board = Board.kill_square(board, victim_coords)
    {moves, board} = find(altered_board, post_hop_coords, post_move_coords)
    {[post_hop_coords, moves], board}
  end
end
