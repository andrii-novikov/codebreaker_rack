module Codebreaker_rack
  class App

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
      Rack::Response.new(Page.new('app/index',{game:game}))
    end

    def action404
      Rack::Response.new([Page.new('app/404',{game:game})],404)
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
        response.write(Page.new('app/game',{game:game}).to_str)
      end
      response
    end

    def actionHint
      Rack::Response.new(Page.new('/app/game/hint',{game:game}).render_body)
    end

    def actionCheck
      response = Rack::Response.new
      if request.post?
        answer = try_code
        answer = 'Nothing matched:(' if answer.empty?
        return game_over(true) unless game.status == :play
        response.write(Page.new('/app/game',{game:game,answer:answer}).render_body)
      else
        response.status = 400
      end
      response.finish
    end

    def game_over(ajax = false)
      result = ajax ? Page.new('/app/game/over',{game:game}).render_body : Page.new('/app/game/hint',{game:game})
      Rack::Response.new([result])
    end

    def actionGameSave
      game.save
    end

    def actionGameScore
      scores = game.score.split("\n").map! {|line| line.split("\t")}
      scores.shift
      scores.sort_by!(&:last).reverse!
      Rack::Response.new(Page.new('/app/game/score',{scores:scores,game:game}))
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