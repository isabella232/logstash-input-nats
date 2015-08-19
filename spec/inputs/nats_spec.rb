require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/nats"
require 'load_jars'
java_import "org.nats.Connection"
java_import "org.nats.MsgHandler"
java_import "java.util.Properties"

describe LogStash::Inputs::Nats do

  subject { LogStash::Inputs::Nats.new }

  after :each do
    subject.teardown
  end

  describe "#run" do

    it "should run and get the message" do
      queue = Queue.new

      subject.register
      Thread.new { subject.run(queue) }
      conn = Connection.connect(Properties.new())
      message = 'Hello World!'
      conn.publish('logstash', message, Class.new(MsgHandler){
        def execute()
          # event = queue.pop
          # expect(event["message"]).to eq(message)
        end
      }.new())
    end

  end

end
