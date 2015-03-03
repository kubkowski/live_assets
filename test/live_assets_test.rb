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

    test "can subscribe to existing reloadCSS events" do
        subscriber = []
        LiveAssets.subscribe(subscriber)

        begin
            while subscriber.empty?
                FileUtils.touch("test/dummy/app/assets/stylesheets/application.css")
            end

            assert_includes subscriber, :reloadCSS
        ensure
            LiveAssets.unsubscribe(subscriber)
        end
    end

    test "receive timer notifications" do
        # Create a timer
        l = LiveAssets.start_timer(:ping, 0.5)

        # Our subscriber is a simple array
        subscriber = []
        LiveAssets.subscribe(subscriber)

        begin
            # Wait until we get an event
            true while subscriber.empty?
            assert_includes subscriber, :ping
        ensure
            # Clean up
            LiveAssets.unsubscribe(subscriber)
        end
    end
end
