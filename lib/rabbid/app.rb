module Rabbid
  extend self
  def uuid
    @uuid ||= SecureRandom.base64
  end
  def with v
    yield v
  ensure
    v.close
  end
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
        x.publish(JSON.dump({number: [Rabbid.uuid, Messages.i[1]+1], text: params[:msg], nick: params[:nick]}))
        redirect url '/'
      end
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
