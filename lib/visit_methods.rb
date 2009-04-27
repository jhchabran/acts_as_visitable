module ActsAsVisitable
  module VisitMethods
    module ClassMethods

    end

    module InstanceMethods
      def seen
        self.seen_at = Time.now
      end
      
      def seen!
        seen
        save!
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end