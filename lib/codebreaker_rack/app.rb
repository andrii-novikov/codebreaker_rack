module Codebreaker_rack
  class App

    def self.call(env)
      App.new(env).router
    end

    attr_reader :request, :response, :game

    def initialize(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @game = Codebreaker::Game.new
      load
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
      save
      response['Content-Type'] = 'text/html'
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
        game.name = name
        game.start
        response.redirect('/game')
      end
    end

    def to_game
      if game.nil?
        response.redirect('/game/new')
      elsif game.in_play?
        response.write(render('app/game',{game:game}))
      elsif request.post?
        game_over
      else
        response.redirect('/game/scores')
      end
    end

    def hint
      response.write(render('/app/game',{game:game, hint: game.hint}))
    end

    def check
      return bad_request unless request.post?
      answer = try_code
      return game_over unless game.in_play?
      response.write(render('/app/game',{game:game,answer:answer}))
    end

    def game_over
      result = render('/app/game/over',{game:game})
      response.write(result)
    end

    def scores
      scores = game.score.split("\n").map! {|line| line.split("\t")}
      scores.shift
      scores.sort_by!(&:last).reverse!
      scores = scores[0...10]
      response.write(render('/app/game/score',{scores:scores,game:game}))
    end

    private

    def render(template, data = {})
      with_layout = !request.post?
      page = Codebreaker_rack::Page.new(template, data)
      with_layout ? page.render : page.render_body
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

    def load
      game.instance_variables.each do |var|
        if request.session[:game]
          game.instance_variable_set(var,request.session[:game][var]) unless request.session[:game][var].nil?
        end
      end
    end

    def save
      request.session[:game] ||= {}
      game.instance_variables.each do |var|
        request.session[:game][var] = game.instance_variable_get(var)
      end
    end
    
    def save_game
      game.save
    end

  end
end