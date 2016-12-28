defmodule Board do

  @moduledoc """
    Outlines behaviors of 'Board's. All functions that move squares, etc. will take and return a 'Board' struct
  """

  @doc """
  creates a checkers board. tuples have faster access times than lists
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
  renders the checker board row by row
  """
  def render(board) do
    IO.write(IO.ANSI.clear())
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
