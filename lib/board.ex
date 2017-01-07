defmodule Board do

  @moduledoc """
    Outlines behaviors of 'Board's. All functions that move squares, etc. will take and return a 'Board' struct
  """

  @doc """
  creates a checkers board
  """
  def create do
    _outer_row([], 0..1, %Square{affiliation: :enemy})
    |> _outer_row(2..5, %Square{rank: :empty})
    |> _outer_row(6..7, %Square{})
  end

  defp _outer_row(acc, range, square) do
    Enum.reduce(range, acc, fn(_x, acc) -> acc ++ [_inner_row(square)] end)
  end

  defp _inner_row(square) do
    Enum.reduce(0..7, [], fn(_x, acc) -> acc ++ [square] end)
  end

  @doc """
  fetches the 'Square' at '{x, y}' from 'board'
  """
  def fetch(board, {x, y}) do
    #grabs the square in the yth row and xth column(uses 7 - y since the board has the 7th row on top)
    {:ok, row} = Enum.fetch(board, 7 - y)
    {:ok, square} = Enum.fetch(row, x)
    square
  end
  
  @doc """
  returns 'board', but the 'Square' at '{x, y}' has the :empty rank
  """
  def kill_square(board, {x, y}) do
    updated_square = fetch(board, {x, y})
      |> Square.kill()

    {:ok, row} = Enum.fetch(board, 7 - y)
    updated_row = List.replace_at(row, x, updated_square)

    List.replace_at(board, 7 - y, updated_row)
  end


  @doc """
  renders the checker board row by row
  """
  def render(board) do
    for row <- board do
      render_row(row)
      IO.write("\n")
    end
  end

  @doc """
  renders the row square by square
  """
  def render_row(row) do
    for square <- row do
      Square.render(square)
      IO.write(" ")
    end
  end
end
