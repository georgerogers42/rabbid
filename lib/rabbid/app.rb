module Rabbid
  extend self
  def with v
    yield v
  ensure
    v.close
  end
  class MessageReceiver
    attr_reader :i
    def messages
      @messages.clone
    end
    def to_a
      @messages.to_a
    end
    def initialize q
      @i = 0
      @queue = q
      @messages = {}
    end
    def start
      @queue.subscribe do |d, m, p|
        msg = JSON.parse p
        @i = msg["number"]
        @messages[@i] = msg
      end
      self
    end
    def [] e
      @messages[e]
    end
    def self.start
      conn = Bunny.new
      conn.start
      ch = conn.create_channel
      self.new(ch.queue("").bind(ch.fanout("rabbid"))).start
    end
  end
  Messages = MessageReceiver.start
  class App < Sinatra::Base
    register Sinatra::Async
    get '/' do ||
      slim :index
    end
    post '/' do ||
      Rabbid.with Bunny.new do |conn|
        conn.start
        ch = conn.create_channel
        x = ch.fanout("rabbid")
        x.publish(JSON.dump({number: Messages.i+1, text: params[:msg], nick: params[:nick]}))
        redirect url '/'
      end
    end
    get '/recv/all.json' do
      msgs = Messages.to_a.sort_by do |a|
        a[0]
      end.map do |a|
        a[1]
      end
      content_type "application/json"
      JSON.dump msgs
    end
    get '/recv/:a-:b.json' do |a, b|
      @a, @b = a.to_i, b.to_i
      msgs = (@a..@b).map do |i|
        Messages[i]
      end
      content_type "application/json"
      json.dump msgs
    end
    apost '/recv.json' do
      begin
        conn = Bunny.new
        conn.start
        ch = conn.create_channel
        q = ch.queue("").bind(ch.fanout("rabbid"))
        q.subscribe do |d, m, p|
          begin
            msg = JSON.parse p
            body do
              content_type "application/json"
              JSON.dump [msg]
            end
          ensure
            conn.close
          end
        end
      rescue
        conn.close
        raise $!
      end
    end
  end
end
