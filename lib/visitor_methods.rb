module ActsAsVisitable
  module VisitorMethods
    module ClassMethods
      protected
      def read_options(opts)
        raise ArgumentError unless opts[:of]
        write_inheritable_attribute :visitable_models_name, Array(opts[:of]).collect(&:to_s)
        write_inheritable_attribute :visitable_models_klass, self.visitable_models_name.collect { |e| e.classify.constantize }
        
        declare_relationships
        declare_named_scopes
      end

      def declare_relationships
        has_many :visited_objects, :foreign_key => "visitor_id", :class_name => "Visit"
      end
      
      def declare_named_scopes
        declare_visitable_model
        declare_which_saw
      end
      
      def declare_visitable_model
        self.visitable_models_name.each do |model|
          named_scope "visited_#{model}", :include => :visited_objects, :conditions => { 'visits.visitable_type' => model.classify }
        end
      end
      
      def declare_which_saw
        named_scope :which_visited, lambda { |object|
          unless self.visitable_models_klass.include? object.class 
            raise ArgumentError.new("#{object.class.name} is not a visitable class") 
          end
          { :include => :visited_objects, :conditions => { 'visits.visitable_type' => object.class.name, 'visits.visitable_id' => object.id} }
        }
      end
    end

    module InstanceMethods
      def update_or_create_visit(opts={})
        visited_objects.find(:first, :conditions => opts).try(:tap) { |visit| visit.visit! } || visited_objects.create(opts)
      end
      
      def visit(object)
        return nil if object == self
        raise ArgumentError.new("#{object.class} is not visitable by #{self.class.name}") unless object_is_visitable? object
        update_or_create_visit(:visitable_id => object.id, :visitable_type => object.class.to_s)
      end

      def visited?(object)
        !!self.visited_objects.find(:first, :conditions => {:visitable_id => object.id, :visitable_type => object.class.to_s})
      end
      
      def visited
        # this is slow. I'll find a workaround later.
        visited_objects.collect(&:visitable)
      end

      def visitable?(object)
        object_is_visitable(object) || class_is_visitable(object)
      end

      def class_is_visitable?(klass)
        self.visitable_models_klass.include? klass
      end

      def object_is_visitable?(object)
        self.visitable_models_klass.include? object.class
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end