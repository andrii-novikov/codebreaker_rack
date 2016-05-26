module Codebreaker_rack
  class App

    include Render

    def self.call(env)
      request = Rack::Request.new(env)
      App.new(request).response
    end

    attr_reader :request

    def initialize(req)
      @request = req
    end

    def response
      case request.path
        when '/'
          actionIndex
        when '/game/new'
          actionNewGame
        when '/game'
          actionGame
        when '/game/hint'
          actionHint
        when '/game/check'
          actionCheck
        when '/game/save'
          actionGameSave
        when '/game/scores'
          actionGameScore
        else
          action404
      end
    end

    def actionIndex
      Rack::Response.new([render('index')])
    end

    def action404
      Rack::Response.new([render('404')],404)
    end

    def actionNewGame
      response = Rack::Response.new
      request.session[:name] = request.POST['name'] if request.POST['name']
      if request.session[:name].nil?
        response.redirect('/')
      else
        request.session[:game] = Codebreaker::Game.new(request.session[:name])
        game.start
        response.redirect('/game')
      end
      response
    end

    def actionGame
      response = Rack::Response.new
      if game.nil?
        response.redirect('/')
      else
        return game_over unless game.in_play?
        response.write(render('game',binding))
      end
      response
    end

    def actionHint
      message = render_body('/app/game/hint',binding)
      Rack::Response.new([message])
    end

    def actionCheck
      response = Rack::Response.new
      if request.post?
        answer = try_code
        answer = 'Nothing matched:(' if answer.empty?
        return game_over(true) unless game.status == :play
        response.write(render_body('app/game',binding))
      else
        response.status = 400
      end
      response.finish
    end

    def game_over(ajax = false)
      result = ajax ? render_body('app/game/over',binding) : render('app/game/over',binding)
      Rack::Response.new([result])
    end

    def actionGameSave
      game.save
    end

    def actionGameScore
      scores = game.score.split("\n").map! {|line| line.split("\t")}
      scores.shift
      scores.sort_by!(&:last).reverse!
      Rack::Response.new(render('app/game/score', binding))
    end

    private

    def game
      request.session[:game]
    end

    def try_code
      game.check(request.POST['guess'])
    rescue => e
      e.message
    end

  end
end