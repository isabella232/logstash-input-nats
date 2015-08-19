require 'jbundler'
import "org.nats"

conn = Connection.connect(Properties.new())
conn.publish('logstash', 'Hello World!')