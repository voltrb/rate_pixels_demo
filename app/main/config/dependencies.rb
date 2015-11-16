# Specify which components you wish to include when
# the "home" component loads.

# bootstrap css framework
component 'materialize'
# component 'toast'

component 'fields'

# provides templates for login, signup, and logout
component 'user_templates'

# browser_irb is optional, gives you an irb like terminal on the client
# (hit ESC) to activate.
if Volt.env.development?
  component 'browser_irb'
end

component 'photos'
component 's3_uploader'
component 'image_resizer'
component 'pagination'