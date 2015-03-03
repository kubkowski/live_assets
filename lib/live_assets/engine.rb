module LiveAssets
    class Engine < ::Rails::Engine
        config.eager_load_namespaces << LiveAssets

        initializer "live_assets.start_listener" do |app|
            paths = app.paths["app/assets"].existent +
                    app.paths["lib/assets"].existent +
                    app.paths["vendor/assets"].existent

            paths = paths.select { |p| p=~ /stylesheets/ }

            if app.config.assets.compile
                LiveAssets.start_listener :reloadCSS, paths
            end
        end

        initializer "live_assets.start_timer" do |app|
            if app.config.assets.compile
                LiveAssets.start_timer :ping, 10
            end
        end
    end
end
