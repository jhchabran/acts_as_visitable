module ActsAsVisitable
  module VisitMethods
    module ClassMethods

    end

    module InstanceMethods
      def visit
        self.visited_at = Time.now
      end
      
      def visit!
        visit
        save!
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end