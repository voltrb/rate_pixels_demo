module UserTemplates
  class MenuController < Volt::ModelController
    def dropdown_ready
      %x(
        $('.dropdown-button').dropdown(
          {
            inDuration: 300,
            outDuration: 225,
            constrain_width: false,
            hover: false,
            gutter: 0,
            belowOrigin: true,
            alignment: 'right',
            closeOnClick: true
          }
        );
      )
    end

    def hide_dropdown
      `$('.dropdown-content').hide();`
    end

    def show_name
      Volt.current_user.then do |user|
        # Make sure there is a user
        if user
          user._name || user._email || user._username
        else
          ''
        end
      end
    end
    
    def avatar
      Volt.current_user.then do |user|
        if user
          user._profile_pic
        else
          ''
        end
      end
    end

    def is_active?
      url.path.split('/')[1] == 'login'
    end
  end
end