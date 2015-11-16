# See https://github.com/voltrb/volt#routes for more info on routes

client '/about', action: 'about'

client '/search', component: 'photos', controller: 'main', action: 'search'
client '/best_of/{{ week }}', component: 'photos', controller: 'main', action: 'best_of_week'
client '/best_of', component: 'photos', controller: 'main', action: 'best_of'
client '/upload/details/{{ id }}', component: 'photos', controller: 'uploads', action: 'details'
client '/upload', component: 'photos', controller: 'uploads', action: 'index'

client '/profile/{{ id }}', component: 'photos', controller: 'profiles', action: 'index'

client '/search/{{ query }}', component: 'photos', controller: 'main', action: 'search'

# popular
client '/popular/{{ photo_id }}', component: 'photos', controller: 'main', action: 'index'
client '/popular', component: 'photos', controller: 'main', action: 'index'

# The main route, this should be last. It will match any params not
# previously matched.
client '/', {}
