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
      
      read_options(opts)
    end
    
    def acts_as_viewer(opts={})
      include SharedMethods
      include ViewerMethods
      
      class_inheritable_reader :observed_models_name
      class_inheritable_reader :observed_models_klass
      
      read_options(opts)
    end
  end
end