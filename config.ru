require_relative 'lib/codebreaker_rack'

require 'bundler'
Bundler.require

use Rack::Static, :urls => ['/css','/js'], root: 'assets'
use Rack::Session::Cookie,  key: 'rack.session',
                            path: '/',
                            expire_after: 2592000,
                            secret: 'password'

run Codebreaker_rack::App