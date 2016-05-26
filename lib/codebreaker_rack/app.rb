module Codebreaker_rack
  class App

    def self.call(env)
      App.new(env).router
    end

    attr_reader :request, :response

    def initialize(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def router
      case request.path
        when '/' then index
        when '/game/new' then new_game
        when '/game' then to_game
        when '/game/hint' then hint
        when '/game/check' then check
        when '/game/save' then save_game
        when '/game/scores' then scores
        else error404
      end
      response
    end

    def index
      response.write( render('app/index',{game:game}))
    end

    def error404
      response.write(render('app/404'))
      response.status = 404
    end

    def bad_request
      response.write('400 Bad Request')
      response.status = 400
    end

    def new_game
      if name.nil?
        response.redirect('/')
      else
        request.session[:game] = Codebreaker::Game.new(name)
        game.start
        response.redirect('/game')
      end
    end

    def to_game
      if game.nil?
        response.redirect('/game/new')
      else
        return game_over unless game.in_play?
        response.write(render('app/game',{game:game}))
      end
    end

    def hint
      response.write(render('/app/game',{game:game, hint: game.hint},false))
    end

    def check
      return bad_request unless request.post?
      answer = try_code
      return game_over unless game.in_play?
      response.write(render('/app/game',{game:game,answer:answer}, false))
    end

    def game_over
      result = render('/app/game/over',{game:game})
      response.write(result)
    end

    def save_game
      game.save
    end

    def scores
      scores = game.score.split("\n").map! {|line| line.split("\t")}
      scores.shift
      scores.sort_by!(&:last).reverse!
      scores = scores[0...10]
      response.write(render('/app/game/score',{scores:scores,game:game}))
    end

    private

    def render(template, data = {}, with_layout = true)
      page = Codebreaker_rack::Page.new(template, data)
      with_layout ? page.render : page.render_body
    end

    def game
      request.session[:game]
    end

    def name
      request.session[:name] = request.POST['name'] if new_name?
      request.session[:name]
    end

    def new_name?
      request.POST['name']  && request.POST['name'] != request.session[:name]
    end

    def try_code
      game.check(request.POST['guess'])
    rescue => e
      e.message
    end

  end
end