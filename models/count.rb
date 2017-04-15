ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class Count < ActiveRecord::Base

end

class Room < ActiveRecord::Base
  validates :channel_id, uniqueness: true
end

class Day < ActiveRecord::Base

end


class Exam < ActiveRecord::Base

end