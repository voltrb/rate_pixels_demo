require 'volt/helpers/time'

# By default Volt generates this controller for your Main component
module Main
  class MainController < Volt::ModelController
    reactive_accessor :search

    def query
      search || params._query
    end

    def query=(val)
      self.search = val
    end

    def run_search
      redirect_to("/search/#{search}")
    end

    def index_ready
      unless local_store._modal_shown
        %x(
          $(document).on('mousemove', function () {
            $modal = $('#modal');

            if ($modal.length && !$modal.hasClass('ignore')) {
              $modal.openModal();
              $modal.addClass('ignore');
              #{local_store._modal_shown = true}
            }
          });

          $('.login-link').click(function () {
            $('#lean-overlay').remove();
          });
        )
      end
    end

    def random_login
      SeedLoginTask.random_login.then do |data|
        Volt.logout()
        Volt.login(data[:email], data[:password])
      end
    end

    def header_ready
      %x(
        $(".button-collapse").sideNav({
          closeOnClick: true
        });
      )
    end

    private

    # The main template contains a #template binding that shows another
    # template.  This is the path to that template.  It may change based
    # on the params._component, params._controller, and params._action values.
    def main_path
      "#{params._component || 'main'}/#{params._controller || 'main'}/#{params._action || 'index'}"
    end

    # Determine if the current nav component is the active one by looking
    # at the first part of the url against the href attribute.
    def active_tab?
      url.path.split('/')[1] == attrs.href.split('/')[1]
    end
  end
end
