defmodule Square do

  @moduledoc """
    Outlines behaviors of 'Square's
  """

  defstruct affiliation: :friendly, rank: :pawn
  #affiliation: :friendly, :enemy
  #rank: :pawn, :king, :empty

  @doc """
  removes the piece from the square (if there is one)
  """
  def kill(square) do
    Map.put(square, :rank, :empty)
  end

  @doc """
  makes the piece a king
  """
  def promote(square) do
    Map.put(square, :rank, :king)
  end

  @doc """
  renders the square based on if there is a piece and what rank/affiliation it has
  """
  def render(square) do
    IO.write(ansi_color(square) <> rank_character(square.rank))
  end
  
  @doc """
  returns the ansi color for a square based on its rank/affiliation
  """
  def ansi_color(square) do
    if(square.rank == :empty) do
      IO.ANSI.white
    else
      case square.affiliation do
        :friendly -> IO.ANSI.blue
        :enemy -> IO.ANSI.red
      end
    end
  end
  
  @doc """
  returns the correct character for a square based on its rank
  """
  def rank_character(rank) do
    case rank do
      :pawn -> "P"
      :king -> "K"
      :empty -> "0"
    end
  end
end
