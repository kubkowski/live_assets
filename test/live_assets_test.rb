require 'test_helper'
require 'fileutils'

class LiveAssetsTest < ActiveSupport::TestCase

    setup do
        FileUtils.mkdir_p "test/tmp"
    end

    teardown do
        FileUtils.rm_rf "test/tmp"
    end

    test "can subscribe to listener events" do
        # Create a listener
        l = LiveAssets.start_listener(:reload, ["test/tmp"])

        # Our subscriber is a simple array
        subscriber = []
        LiveAssets.subscribe(subscriber)

        begin
            while subscriber.empty?
                # Trigger changes in a file until we get an event
                File.write("test/tmp/sample", SecureRandom.hex(20))

                # Assert we got the event
                assert_includes subscriber, :reload
            end
        ensure
            # Clean up
            LiveAssets.unsubscribe(subscriber)
            l.kill
        end
    end
end
