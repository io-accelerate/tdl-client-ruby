require 'tdl/queue/queue_based_implementation_runner'

module TDL
    
    class QueueBasedImplementationRunnerBuilder
            
        def initialize
            @deploy_processing_rules = create_deploy_processing_rules()
        end

        def set_config(config)
            @config = config
            self
        end

        def with_solution_for(method_name, user_implementation)
            @deploy_processing_rules
                .on(method_name)
                .call(user_implementation)
                .build()
            self
        end

        def create
            QueueBasedImplementationRunner.new(@config, @deploy_processing_rules)
        end

        private def create_deploy_processing_rules
            deploy_processing_rules = ProcessingRules.new()
            deploy_processing_rules
                .on('display_description')
                .call(-> (*params) {'OK'})
                .build()
            deploy_processing_rules
        end

    end

end
