# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require 'load_jars'
java_import "org.nats.Connection"
java_import "org.nats.MsgHandler"
java_import "java.util.Properties"

class LogStash::Inputs::Nats < LogStash::Inputs::Base
  config_name "nats"

  default :codec, "plain"

  public
  def register
    uri = "nats://nats:dcac1bafa7ec273b939c@10.0.16.10:4222"

    opts = Properties.new;
    opts.setProperty("servers", uri);

    @conn = Connection.connect(opts)
  end

  def run(queue)
    puts "*** SETTING UP NATS ***"

    handler = NatsMessageHandler.new
    handler.arity = 3  #Force calling execute(msg, reply, subject)
    handler.logstash = self
    handler.queue = queue

    @sid = @conn.subscribe('hm.agent.heartbeat.*', handler)

  end
  def teardown
    @conn.unsubscribe(@sid)
    @conn.close
  end
end

class NatsMessageHandler < org.nats.MsgHandler
  attr_accessor :logstash
  attr_accessor :queue

  def execute(msg, reply, subject)
    puts "NATS MSG received: msg:'#{msg}', reply: '#{reply}', subject: '#{subject}'"
    event = LogStash::Event.new("subject" => subject, "reply" => reply, "msg" => msg)
    @logstash.decorate(event)
    @queue << event
  end
end
