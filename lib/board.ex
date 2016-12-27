defmodule Board do

  #creates a checkers board. tuples have faster access times than lists
  def create do
    _outer_row([], 0..1, %Square{affiliation: :enemy})
    |> _outer_row(2..5, %Square{populated: :no})
    |> _outer_row(6..7, %Square{})
  end

  defp _outer_row(acc, range, square) do
    Enum.reduce(range, acc, fn(_x, acc) -> acc ++ [_inner_row(square)] end)
  end

  #only used by create/0 for board creation
  defp _inner_row(square) do
    Enum.reduce(0..7, [], fn(_x, acc) -> acc ++ [square] end)
  end


  def render(board) do
    for row <- board do
      render_row(row)
      IO.write("\n")
    end
  end

  def render_row(row) do
    for square <- row do
      Square.render(square)
    end
  end
end
