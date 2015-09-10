# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require 'load_jars'
require "json"
require_relative "parse_floats.rb"
java_import "org.nats.Connection"
java_import "org.nats.MsgHandler"
java_import "java.util.Properties"

class LogStash::Inputs::Nats < LogStash::Inputs::Base
  config_name "nats"
  milestone 1 # https://github.com/elastic/logstash/blob/1.4/docs/plugin-milestones.md

  default :codec, "plain"

  # A array of NATS server uris, e.g ["nats://user:pwd@host:port",..]
  config :server_uris, :validate => :array, :required => true

  # The NATS subject to subscribe to.
  config :subject, :validate => :string, :required => true

  public
  def register

    uris = @server_uris.join ","

    opts = Properties.new;
    opts.setProperty("servers", uris);

    @interrupted = false
    @logger.info "Setting up NATS connection"
    @conn = Connection.connect(opts)
  end

  def run(queue)
    handler = NatsMessageHandler.new
    handler.arity = 3  #Force calling execute(msg, reply, subject)
    handler.logstash = self
    handler.queue = queue

    @logger.info "Subscribing to #{@subject}"
    @sid = @conn.subscribe(@subject, handler)
    while !@interrupted
      sleep 5
    end
  end

  def do_decorate(event)
    decorate(event)
  end

  def teardown
    @logger.info "Shutting down connection to NATS"
    @interrupted = true
    @conn.unsubscribe(@sid)
    # Currently close throws a java.nio.channels.ClosedByInterruptException. We assume this is a bug in the underlying java_nats library.
    @conn.close
  end
end

class NatsMessageHandler < org.nats.MsgHandler
  attr_accessor :logstash
  attr_accessor :queue

  def execute(msg, reply, subject)
    puts msg
    data = JSON.parse(msg)
    #data['job_and_index'] = data['job'] + "/" + data["index"].to_s

    data.convert_number_string_to_float
    #load = { 'avg01' => data['vitals']['load'][0], 'avg05' => data['vitals']['load'][1], 'avg15' => data['vitals']['load'][2] }
    #data['vitals']['load'] = load

    #puts "NATS MSG received: msg:'#{msg}', reply: '#{reply}', subject: '#{subject}'"
    event = LogStash::Event.new("subject" => subject, "reply" => reply, "@message" => data.to_json, "@type" => "NATS")
    @logstash.do_decorate(event)
    @queue << event
  end
end
