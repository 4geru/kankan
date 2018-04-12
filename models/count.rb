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

class Trip < ActiveRecord::Base
  def startAt
    Time.parse(self.start_time)
  end

  def goalAt
    Time.parse(self.goal_time)
  end

end
