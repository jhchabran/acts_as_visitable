require 'seen_methods'
require 'viewer_methods'
require 'shared_methods'
require 'sight_methods'

module ActsAsSeen
  def self.included(base)
    base.extend ActsAsSeenMethods
  end

  module ActsAsSeenMethods
    def acts_as_seen(opts={})
      include SharedMethods
      include SeenMethods
      
      class_inheritable_reader :seen_by_model_name
      class_inheritable_reader :seen_by_model_klass
      
      read_acts_as_seen_options(opts)
      declare_acts_as_seen_relationships
    end
    
    def acts_as_viewer(opts={})
      include SharedMethods
      include ViewerMethods
      
      class_inheritable_reader :observed_model_name
      class_inheritable_reader :observed_model_klass
      
      read_acts_as_viewer_options(opts)
      declare_acts_as_viewer_relationships
    end
  end
end