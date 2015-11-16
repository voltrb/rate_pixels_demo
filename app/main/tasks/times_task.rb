require 'chronic'
class TimeTasks < Volt::Task
  def end_of_contest
    VoltTime.at(Chronic.parse('sunday at 1pm', :context => :future).to_i)
  end
end
