defmodule Hangman.GameTest do
  use ExUnit.Case

  alias Hangman.Game

  test "new_game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
    assert Enum.all?(game.letters, fn l -> l =~ ~r/[a-z]/ end) == true
  end

  test "make_move doesn't change state for :won or :lost game" do
    for state <- [ :won, :lost ] do
      game = Game.new_game()
      game = Map.put(game, :game_state, state)

      assert ^game = Game.make_move(game, "x")
    end
  end

  test "first occurence of letter is not already used" do
    game = Game.new_game()

    game = Game.make_move(game, "x")
    assert game.game_state != :already_used
  end

  test "second occurence of letter is already used" do
    game = Game.new_game()
    game = Game.make_move(game, "x")
    assert game.game_state != :already_used

    game = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "a good guess is recognised" do
    game = Game.new_game("wibble")
    game = Game.make_move(game, "w")

    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a guessed word is a won game" do
    game = Game.new_game("wibble")

    moves = [
      {"w", :good_guess},
      {"i", :good_guess},
      {"b", :good_guess},
      {"l", :good_guess},
      {"e", :won},
    ]

    Enum.reduce(moves, game, fn ({guess, state}, acc_game) ->
      acc_game = Game.make_move(acc_game, guess)

      assert acc_game.game_state == state
      assert acc_game.turns_left == 7

      acc_game
    end)
  end

  test "a bad guess is recognised" do
    game = Game.new_game("wibble")
    game = Game.make_move(game, "x")

    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "final bad guess is a lost game" do
    game = Game.new_game("w")

    moves = [
      {"a", :bad_guess},
      {"b", :bad_guess},
      {"c", :bad_guess},
      {"d", :bad_guess},
      {"e", :bad_guess},
      {"f", :bad_guess},
      {"g", :lost},
    ]

    Enum.reduce(moves, game, fn ({guess, state}, old_game) ->
      acc_game = Game.make_move(old_game, guess)

      assert acc_game.game_state == state
      assert acc_game.turns_left == old_game.turns_left - 1

      acc_game
    end)
  end
end
