ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class Count < ActiveRecord::Base

end

class Day < ActiveRecord::Base

end