module ActsAsSeen
  module ViewerMethods
    module ClassMethods
      protected
      def read_options(opts)
        raise ArgumentError unless opts[:of]
        write_inheritable_attribute :observed_models_name, Array(opts[:of]).collect(&:to_s)
        write_inheritable_attribute :observed_models_klass, self.observed_models_name.collect { |e| e.classify.constantize }
        
        declare_relationships
        declare_named_scopes
      end

      def declare_relationships
        has_many :sights, :foreign_key => "viewer_id"
      end
      
      def declare_named_scopes
        self.observed_models_name.each do |model|
          named_scope "seen_#{model}", :include => :sights, :conditions => { 'sights.sightable_type' => model.classify }
        end
      end
    end

    module InstanceMethods
      def saw(object)
        raise ArgumentError.new("#{object.class} is not sightable by #{self.class.name}") unless object_is_sightable? object
        #sights.create(:sightable => object)
        update_or_create_sight(:sightable_id => object.id, :sightable_type => object.class.to_s)
      end
      
      def saw?(object)
        !!self.sights.find(:first, :conditions => {:sightable_id => object.id, :sightable_type => object.class.to_s})
      end

      def sightable?(object)
        object_is_sightable(object) || class_is_sightable(object)
      end

      def class_is_sightable?(klass)
        self.observed_models_klass.include? klass
      end

      def object_is_sightable?(object)
        self.observed_models_klass.include? object.class
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end