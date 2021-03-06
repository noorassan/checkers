defmodule Testing do
  def testing do
    board = Board.create()
    board = List.replace_at(board, 5, List.replace_at(Enum.at(board, 5), 1, %Square{affiliation: :enemy, rank: :pawn}))
    board = List.replace_at(board, 3, List.replace_at(Enum.at(board, 3), 1, %Square{affiliation: :enemy, rank: :pawn}))
    board = List.replace_at(board, 3, List.replace_at(Enum.at(board, 3), 3, %Square{affiliation: :enemy, rank: :pawn}))
    board = List.replace_at(board, 0, List.replace_at(Enum.at(board, 0), 0, %Square{affiliation: :friendly, rank: :empty}))
    board
  end

  def testing_two do
    board = Board.create()
    board = List.replace_at(board, 5, List.replace_at(Enum.at(board, 5), 1, %Square{affiliation: :enemy, rank: :pawn}))
    board = List.replace_at(board, 3, List.replace_at(Enum.at(board, 3), 1, %Square{affiliation: :enemy, rank: :pawn}))
    board = List.replace_at(board, 3, List.replace_at(Enum.at(board, 3), 3, %Square{affiliation: :enemy, rank: :pawn}))
    board = List.replace_at(board, 0, List.replace_at(Enum.at(board, 0), 0, %Square{affiliation: :friendly, rank: :empty}))
    board = List.replace_at(board, 2, List.replace_at(Enum.at(board, 2), 2, %Square{affiliation: :friendly, rank: :pawn}))
    board
  end
end
