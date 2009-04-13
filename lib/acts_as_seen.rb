module ActsAsSeen
  def self.included?(base)
    base.extend ActsAsSeenMethods
  end
  
  module ActsAsSeenMethods
    def acts_as_seen(opts={})
      extend ClassMethods
      include InstanceMethods
    end
  end
  
  module ClassMethods
    
  end
  
  module InstanceMethods
    
  end
end