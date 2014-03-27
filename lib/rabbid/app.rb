module Rabbid
  extend self
  def with v
    yield v
  ensure
    v.close
  end
  class Messages
    def initialize q
      @queue = q
      @messages = {}
    end
    def start
      @queue.subscribe do |d, m, p|
        msg = JSON.parse p
        @messages[msg["number"]] = msg
      end
    end
    def [] e
      @messages[e]
    end
    def self.start
      conn = Bunny.new
      ch = conn.create_channel
      self.new(ch.queue("").bind(ch.fanout("rabbid")))
    end
  end
  Messages.start
  class App < Sinatra::Base
    register Sinatra::Async
    get '/' do ||
      slim :message
    end
    post '/' do ||
      Rabbid.with Bunny.new do |conn|
        conn.start
        ch = conn.create_channel
        x = ch.fanout("rabbid")
        x.publish(params[:msg])
        redirect url '/'
      end
    end
    get '/recv/:msg' do |msg|
      @body = msg
      slim :index
    end
    aget '/recv' do
      begin
        conn = Bunny.new
        conn.start
        ch = conn.create_channel
        q = ch.queue("").bind(ch.fanout("rabbid"))
        q.subscribe do |d, m, p|
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
