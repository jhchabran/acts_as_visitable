require 'visited_methods'
require 'visitor_methods'
require 'shared_methods'
require 'visit_methods'

module ActsAsVisitable
  def self.included(base)
    base.extend ActsAsVisitableMethods
  end

  module ActsAsVisitableMethods
    def acts_as_visitable(opts={})
      include SharedMethods
      include VisitedMethods
      
      class_inheritable_reader :seen_by_model_name
      class_inheritable_reader :seen_by_model_klass
      
      read_options(opts)
      alias_method_chain :to_json, :seen_by_attribute
    end
    
    def acts_as_viewer(opts={})
      include SharedMethods
      include VisitorMethods
      
      class_inheritable_reader :observed_models_name
      class_inheritable_reader :observed_models_klass
      
      read_options(opts)
    end
  end
end