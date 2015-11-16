class SeedLoginTask < Volt::Task
  def random_login
    db = Volt.current_app.database.raw_db
    user = db.from(:seed_accounts).order(Sequel.lit('RANDOM()')).first

    {email: user[:email], password: user[:password]}
  end
end
