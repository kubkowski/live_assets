require "thread"

module LiveAssets
    class SseSubscriber
        def initialize(queue = Queue.new)
            @queue = queue
            LiveAssets.subscribe(@queue)
        end

        def each
            while event = @queue.pop
                yield "event: #{event}\ndata: {}\n\n"
            end
        end

        def close
            LiveAssets.unsubscribe(@queue)
        end
    end
end