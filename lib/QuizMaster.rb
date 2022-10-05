# frozen_string_literal: true

require_relative "QuizMaster/version"
require 'numbers_in_words'

module QuizMaster
  attr_accessor :questions
  class Error < StandardError; end
  # Your code goes here...
  class QuizMaster
    puts "Welcome to QuizMaster"
    def initialize
      @questions = []
    end

    def commandMenu(cmd)
      cmd_split = cmd.split(' ')
      case cmd_split[0]
      when 'help'
        help
      when 'create_question'
        create_question(cmd_split)
      when 'update_question'
        update_question(cmd_split)
      when 'delete_question'
        delete_question(cmd_split)
      when 'question'
        question(cmd_split)
      when 'questions'
        questions
      when 'answer_question'
        answer_question(cmd_split)
      when 'exit'
        @questions= []
        puts 'Goodbye..'
      else
        puts 'Wrong command, try again'
      end
    end

    def help
      return "Command | Description" +
      "\ncreate_question <no> <question> <answer> | Creates a question" +
      "\nupdate_question <no> <question> <answer> | Updates a question" +
      "\ndelete_question <no> | Deletes a question" +
      "\nquestion <no> | Shows a question" +
      "\nquestions | Shows question list" +
      "\nanswer_question <no> <answer>"
    end

    def create_question(params)
      noQuestion = params[1]
      
      return "Wrong question format, try again" if params.length < 4
      
      paramsJoin = params.join(' ')
      question, answer = getValueQuote(paramsJoin)

      return "Wrong question format, must on double quote" if question.nil?
      return "Wrong answer format, cannot be empty" if answer.nil?
      questionDt = {
        noQuestion: noQuestion,
        question: question || '',
        answer: answer || '',
      }

      add_new_question(questionDt)
    end

    def update_question(params)
      noQuestion = params[1]

      paramsJoin = params.join(' ')
      
      question, answer = getValueQuote(paramsJoin)

      return "Wrong question format, must on double quote" if question.nil?
      return "Wrong answer format, cannot be empty" if answer.nil?
      
      message = ""

      questionDt = {
        noQuestion: noQuestion,
        question: question,
        answer: answer,
      }

      return add_new_question(questionDt) if @questions.empty?

      find = find_question(noQuestion)
      if find
        find[:question] = question
        find[:answer] = answer
        message = "Question number #{noQuestion} updated!"
      else
        puts "Question not found, question will be added as new question"
        return add_new_question(questionDt)
      end

      return message
    end

    
    def delete_question(params)
      noQuestion = params[1]
      isFind = false
      idx = nil
      find = find_question(noQuestion)
      if find
        @questions.reject! do |hash|
          hash[:noQuestion] == noQuestion
        end
        return "Question number #{noQuestion} is deleted!"
      else
        return "Question not found"
      end
    end
    
    def question(params)
      noQuestion = params[1]
      
      find = find_question(noQuestion)
      if find
        return "Q: #{find[:question]}"
      else
        return "Question not found"
      end
    end
    
    def questions
      return "Questions list is empty, create question first!" if @questions.empty?
      puts "No | Question | Answer"
      @questions.each do |q|
        puts "#{q[:noQuestion]} | #{q[:question]} | #{q[:answer]}"
      end
    end
    
    def answer_question(params)
      noQuestion = params[1]
      answer = params[2..params.length]
      answerJoin = answer.join(' ')
      
      find = find_question(noQuestion)
      if find && find[:noQuestion] == noQuestion
        if is_number?(find[:answer])
          ans = !is_number?(answerJoin) ? NumbersInWords.in_numbers(answerJoin) : answerJoin
          return ans.to_i == find[:answer].to_i ? "Correct!" : "Incorrect!"
        else
          ans = is_number?(answerJoin) ? NumbersInWords.in_words(answerJoin)  : answerJoin
          ans = ans.gsub('-', ' ')
          return ans.to_s.downcase == find[:answer].to_s.downcase ? "Correct" : "Incorrect"
        end
      else
        return "Question not found"
      end
    end
    
    def find_question(noQuestion)
      return @questions.find { |v| v[:noQuestion] == noQuestion }
    end
    
    def is_number?(obj)
      obj.to_s == obj.to_i.to_s || obj.to_s == obj.to_f.to_s
    end
    
    def add_new_question(params)
      @questions.find do |v|
        return "Question number already exist!" if v[:noQuestion] == params[:noQuestion]
      end

      @questions << params

      return "Question no #{params[:noQuestion]} created:" +
      "\n Q: #{params[:question]}" +
      "\n A: #{params[:answer]}"
    end

    def getValueQuote(paramsJoin)
      getValue = paramsJoin.scan(/"([^"]*)"/)
      if !getValue.empty?
        split = paramsJoin.split(' ')
        split2 = getValue[0][0].split(' ')
        ans = split[2+split2.length..split.length].join(' ')
        
        question = !getValue.empty? ? getValue[0][0] : split[-2]

        return [question, nil] if ans.empty?

        answer = (!getValue.empty? && getValue.length > 1) ? getValue[1][0] : ans
        
        return [question, answer] 
      end

      return [nil, nil]
    end

    def main
      while true do
        command = gets.chomp
        puts commandMenu(command)
        break if command == 'exit'  
      end
    end
  end

  qm = QuizMaster.new
  qm.main
end
