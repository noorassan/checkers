defmodule Square do
  defstruct populated: :yes, affiliation: :friendly, rank: :pawn
  #populated: :yes, :no
  #affiliation: :friendly, :enemy
  #rank: :pawn, :king

  def kill(square) do
    Map.put(square, :rank, :empty)
  end

  def promote(square) do
    Map.put(square, :rank, :king)
  end

  def render(square) do
    if(square.populated == :no) do
      "0"
    end
    ansi_color(square.affiliation) <> rank_character(square.rank)
  end
  
  def ansi_color(affiliation) do
    case affiliation do
      :friendly -> IO.ANSI.blue
      :enemy -> IO.ANSI.red
    end
  end
  
  def rank_character(rank) do
    case rank do
      :pawn -> "P"
      :king -> "K"
    end
  end
end
