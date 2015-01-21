require "live_assets/engine"
require "thread"
require "listen"

module LiveAssets
    mattr_reader :subscribers
    @@subscribers = []

    # Subscribe to all published events.
    def self.subscribe(subscriber)
        subscribers << subscriber
    end

    # Unsubscribe an existing subscriber.
    def self.unsubscribe(subscriber)
        subscribers.delete(subscriber)
    end

    # Start a listener for the following directories.
    # Every time a change happens, publish the given
    # event to all subscribers available
    def self.start_listener(event, directories)
        Thread.new do
            Listen.to(*directories, latency: 0.5) do |_modified, _added, _removed|
                subscribers.each { |s| s << event }
            end
        end
    end

end
