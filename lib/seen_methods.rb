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
        has_many :viewers, :through => :sights, :class_name => self.seen_by_model_name.classify
      end

      def declare_named_scopes
        declare_seen_by_model
        declare_seen_by_model_with_arg
      end

      def declare_seen_by_model
        named_scope "seen", 
          :include => :sights, :conditions => { 'sights.sightable_type' => self.name }
      end

      def declare_seen_by_model_with_arg
        named_scope "seen_by", lambda { |model|
          unless model.class == self.seen_by_model_klass
            raise ArgumentError.new("#{model.class.name} can't be used to find #{self.seen_by_model_name}" )
          end
          { :include => :sights, :conditions => { 'sights.viewer_id' => model.id }}
        }
      end
    end

    module InstanceMethods
      def seen_by(viewer)
        return nil if viewer == self
        raise ArgumentError.new("#{viewer.class.name} can't view a #{self.class.name}") unless object_is_sightable_by? viewer
        update_or_create_sight(:viewer_id => viewer.id)
      end
      
      def update_or_create_sight(opts={})
        sights.find(:first, :conditions => opts).try(:tap) { |sight| sight.seen! } || sights.create(opts)
      end

      def seen_by?(viewer)
        !!self.sights.find(:first, :conditions => { :viewer_id => viewer.id})
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
