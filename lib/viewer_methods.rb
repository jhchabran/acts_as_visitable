module ActsAsSeen
  module ViewerMethods
    module ClassMethods
      protected
      def read_acts_as_viewer_options(opts)
        raise ArgumentError unless opts[:of]
        write_inheritable_attribute :observed_model_name, opts[:of].to_s
        write_inheritable_attribute :observed_model_klass, self.observed_model_name.classify.constantize
      end

      def declare_acts_as_viewer_relationships
        has_many :sights, :class_name => @sightable_name, :foreign_key => "viewer_id"
      end
    end

    module InstanceMethods
      def saw(object)
        raise ArgumentError.new("#{object.class} is not sightable by #{self.class.name}") unless object_is_sightable? object
        #sights.create(:sightable => object)
        update_or_create_sight(:sightable_id => object.id, :sightable_type => object.class.to_s)
      end

      def sightable?(object)
        object_is_sightable(object) || class_is_sightable(object)
      end

      def object_is_sightable?(object)
        object.class == self.observed_model_klass
      end

      def class_is_sightable?(klass)
        klass == self.observed_model_klass
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end