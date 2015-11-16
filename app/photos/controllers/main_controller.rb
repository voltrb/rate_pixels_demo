require 'photos/lib/result_loader'

module Photos
  class MainController < Volt::ModelController
    include ResultLoader

    reactive_accessor :page_count

    def popular
      load_results(PhotoLoadTask.popular(current_page))
    end

    def search
      load_results(PhotoLoadTask.search(params._query, current_page))
    end

    def best_of
      store.weeks.order(number: :desc).all
    end

    def best_of_week_photos
      load_results(PhotoLoadTask.best_of_week(params._week, current_page))
    end

    def current_page
      (params._page || 1).to_i - 1
    end

    def total
      (page_count || 0) * per_page
    end

    def per_page
      @per_page ||= Volt.config.public.per_page
    end
  end
end