defmodule Checkers do

  @moduledoc """
  Handles all user interaction for a checkers game
  """

  @doc """
  Starts interaction with the user, creates a board, and passes it to round/1
  """
  def init do
    IO.write(IO.ANSI.clear)
    IO.puts("Time to play some checkers!")

    Board.create 
    |> Checkers.round()
  end

  def round(board) do
    
  end
end
