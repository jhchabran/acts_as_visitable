module ActsAsVisitable
  module VisitedMethods
    module ClassMethods
      protected
      def read_options(opts)
        raise unless opts[:by]
        write_inheritable_attribute :visited_by_model_name, opts[:by].to_s
        write_inheritable_attribute :visited_by_model_klass, self.visited_by_model_name.classify.constantize

        declare_relationships
        declare_named_scopes
      end

      def declare_relationships
        has_many :visits, :as => :visitable
        has_many :visitors, :through => :visits, :class_name => self.visited_by_model_name.classify
      end

      def declare_named_scopes
        declare_visited_by_model
        declare_visited_by_model_with_arg
      end

      def declare_visited_by_model
        named_scope "visitors", 
          :include => :visits, :conditions => { 'visits.visitable_type' => self.name }
      end

      def declare_visited_by_model_with_arg
        named_scope "visited_by", lambda { |model|
          unless model.class == self.visited_by_model_klass
            raise ArgumentError.new("#{model.class.name} can't be used to find #{self.visited_by_model_name}" )
          end
          { :include => :visits, :conditions => { 'visits.visitor_id' => model.id }}
        }
      end
    end

    module InstanceMethods
      def visited_by(visitor)
        return nil if visitor == self
        raise ArgumentError.new("#{visitor.class.name} can't visit a #{self.class.name}") unless object_is_visitable_by? visitor
        update_or_create_visitor(:visitor_id => visitor.id)
      end
      
      def update_or_create_visitor(opts={})
        visits.find(:first, :conditions => opts).try(:tap) { |visit| visit.visit! } || visits.create(opts)
      end

      def visited_by?(visitor)
        !!self.visits.find(:first, :conditions => { :visitor_id => visitor.id})
      end

      def visitable_by?(object)
        object_is_visitable?(object) || class_is_visitable?(object)
      end

      def object_is_visitable_by?(object)
        object.class == self.visited_by_model_klass
      end

      def class_is_visitable_by?(klass)
        klass == self.visited_by_model_klass
      end
      
      def to_json_with_visited_by_attribute(opts={})
        unless opts.has_key? :visited_by
          self.to_json_without_visited_by_attribute
        else
          self.to_json_without_visited_by_attribute(opts).sub(/\}$/, ",\"visited\":#{self.visited_by?(opts[:visited_by])}}") 
        end
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
