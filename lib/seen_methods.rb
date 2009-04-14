module ActsAsSeen
  module SeenMethods
    module ClassMethods
      protected
      def read_options(opts)
        raise unless opts[:by]
        write_inheritable_attribute :seen_by_model_name, opts[:by].to_s
        write_inheritable_attribute :seen_by_model_klass, self.seen_by_model_name.classify.constantize
        
        declare_relationships
        declare_named_scopes
      end

      def declare_relationships
        has_many :sights, :as => :sightable
      end
      
      def declare_named_scopes
        named_scope "seen_by_#{self.seen_by_model_name}", :include => :sights, :conditions => { 'sights.sightable_type' => self.name }
      end
    end

    module InstanceMethods
      def seen_by(viewer)
        raise ArgumentError.new("#{viewer.class} can't view a #{self.class.name}") unless object_is_sightable_by? viewer
        update_or_create_sight(:viewer_id => viewer.id)
      end
      
      def sightable_by?(object)
        object_is_viewable?(object) || class_is_viewable?(object)
      end
      
      def object_is_sightable_by?(object)
        object.class == self.seen_by_model_klass
      end
      
      def class_is_sightable_by?(klass)
        klass == self.seen_by_model_klass
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end