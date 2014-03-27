require 'open-uri'
require 'thin'
module Rabbid
  extend self
  def with v
    yield v
  ensure
    v.close
  end
  class App < Sinatra::Base
    register Sinatra::Async
    get '/' do ||
      slim :message
    end
    post '/' do ||
      Rabbid.with Bunny.new do |conn|
        conn.start
        ch = conn.create_channel
        x = ch.fanout("hello")
        x.publish(params[:msg])
        redirect url '/'
      end
    end
    get '/recv/:msg' do |msg|
      @body = msg
      slim :index
    end
    apost '/recv' do
      begin
        conn = Bunny.new
        conn.start
        ch = conn.create_channel
        q = ch.queue("").bind(ch.fanout("hello"))
        q.subscribe() do |d, m, p|
          begin
            @body = p
            body do
              slim :index
            end
          ensure
            conn.close
          end
        end
      rescue
        conn.close
      end
    end
  end
end
