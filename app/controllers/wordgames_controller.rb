require 'json'
require 'open-uri'

class WordgamesController < ApplicationController
  def game
    @grid = generate_grid(15).join(" ")
    @start_time = Time.now
  end

  def score
    @user_guess = params[:query]
    @grid = params[:grid]
    @start_time = Time.parse(params[:time])
    @end_time = Time.now
    @result = run_game(@user_guess, @grid, @start_time, @end_time)

    if session[:score]
      session[:score] << @result[:score]
    else
      session[:score] = []
      session[:score] << @result[:score]
    end
  end

  def startover
    session[:score] = []
    redirect_to '/game'
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }
    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last
    return result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end

end
