module RSpec
  module Sidekiq
    module Matchers
      def be_delayed delay_time = nil
        BeDelayed.new delay_time
      end

      class BeDelayed
        def initialize delay_time = nil
          @delay_time = delay_time
        end

        def description
          message = "have an delayed job #{@method}"
          message += " with delay time #{@delay_time}" if @delay_time
        end

        def failure_message
          message = "expected to have a delayed job #{@method}"
          message += " with delay time #{@delay_time}" if @delay_time
          message += " but it was not found\n\nfound: #{@actual_job_names}"
        end

        def matches? expected
          @expected = expected

          job = (::Sidekiq::Extensions::DelayedClass.jobs + ::Sidekiq::Extensions::DelayedModel.jobs + ::Sidekiq::Extensions::DelayedMailer.jobs).find do |job|
            yaml = YAML.load(job["args"].first)

            clazz = yaml[0]
            method = yaml[1]
            arguments = yaml[2]

            expected.receiver == clazz && expected.name == method
          end

          if job
            return true
          else
            return false
          end

#          time_matched = true
#          if matched_job && @delay_time
#            planned_run_time = matched_job['at']
#            enqueued_at = matched_job['enqueued_at']

#            return false if planned_run_time.nil? || enqueued_at.nil?

#            time_matched = Time.at(planned_run_time).to_i == (Time.at(enqueued_at) + @delay_time).to_i
#          end

#          return time_matched
        end

        def negative_failure_message
          message = "expected to not have a delayed job #{@method}"
          message += " with delay time #{@delay_time}" if @delay_time
        end
      end
    end
  end
end