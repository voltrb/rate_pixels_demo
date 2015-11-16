module UserTemplates
  class AccountController < Volt::ModelController
    before_action :require_login

    reactive_accessor :avatar_user

    def index
      self.model = Volt.current_user.buffer
      new_avatar
    end

    def new_avatar
      Volt.current_user.then do |user|
        user.buffer.then do |model|
          model.on('uploaded_profile_pic') do
            # Save the Photo once its uploaded
            save_avatar
          end

          self.avatar_user = model
        end
      end
    end

    def index_ready
      %x(
        $('.change-avatar').click(function (e) {
          e.preventDefault();

          $('#files').trigger('click');
        });
      )

      if params._section == 'password'
        # `$('ul.tabs').tabs('select_tab', '#password');`
      else
        # `$('ul.tabs').tabs();`
      end

    end

    def save_avatar
      self.avatar_user.save!.then do
        model.profile_pic_url = avatar_user.profile_pic_url
        flash._notices << "Avatar updated."
      end
    end

    def save
      model.save!.then do
        new_avatar
        flash._notices << 'Account settings saved'
        redirect_to "/profile/#{Volt.current_user_id}"
      end.fail do |err|
        puts "ERR: #{err.inspect}"
      end
    end

    def basic?
      params._section == 'basic' || !params._section
    end

    def password?
      params._section == 'password'
    end

    def set_basic
      # `$('ul.tabs').tabs('select_tab', '#basic');`
      params._section = 'basic'
    end

    def set_password
      # `$('ul.tabs').tabs('select_tab', '#password');`
      params._section = 'password'
    end
  end
end
