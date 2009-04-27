module ActsAsVisitable
  module SharedMethods
    module InstanceMethods 
      def update_or_create_sight(opts={})
        sights.find(:first, :conditions => opts).try(:tap) { |sight| sight.seen! } || sights.create(opts)
      end
    end
    
    module ClassMethods
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end