defmodule Testing do
  def testing do
    board = Board.create()
    board = List.replace_at(board, 5, List.replace_at(Enum.at(board, 5), 1, %Square{affiliation: :enemy, rank: :pawn}))
    List.replace_at(board, 3, List.replace_at(Enum.at(board, 3), 1, %Square{affiliation: :enemy, rank: :pawn}))
  end
end
