module ActsAsVisitable
  module SharedMethods
    module InstanceMethods 
      #def update_or_create_visit(opts={})
      #  visits.find(:first, :conditions => opts).try(:tap) { |visit| visit.seen! } || visits.create(opts)
      #end
    end
    
    module ClassMethods
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end