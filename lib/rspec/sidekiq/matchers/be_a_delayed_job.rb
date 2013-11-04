module RSpec
  module Sidekiq
    module Matchers
      def be_a_delayed_job delay_time = nil
        BeDelayed.new delay_time
      end

      class BeDelayed
        def initialize delay_time = nil
          @delay_time = delay_time
        end

        def description
          message = "have an delayed job #{@method}"
          if @delay_time
            message += " with delay time #{@delay_time}"
          end
          message
        end

        def failure_message
          message = "expected to have a delayed job #{@method}"
          if @delay_time
            message += " with delay time #{@delay_time}"
          end
          message += " but it was not found\n\n" +
          "found: #{@actual_job_names}"
        end

        def matches? method
          @method = method
          @actual_job_names = []

          all_jobs = ::Sidekiq::Extensions::DelayedClass.jobs + ::Sidekiq::Extensions::DelayedModel.jobs +
              ::Sidekiq::Extensions::DelayedMailer.jobs

          matched_job = all_jobs.find do |job|
            job_command = job['args'][0]
            start_i = job_command.index(':')
            end_i = job_command.index("\n", start_i)
            @actual_job_names << job_command[start_i + 1, end_i-start_i-1]
            @actual_job_names.last == method
          end

          unless matched_job
            return false
          end

          time_matched = true
          if matched_job && @delay_time
            planned_run_time = matched_job['at']
            enqueued_at = matched_job['enqueued_at']

            return false if planned_run_time.nil? || enqueued_at.nil?

            time_matched = Time.at(planned_run_time).to_i == (Time.at(enqueued_at) + @delay_time).to_i
          end

          return time_matched
        end

        def negative_failure_message
          message = "expected to not have a delayed job #{@method}"
          if @delay_time
            message += " with delay time #{@delay_time}"
          end
          message
        end
      end
    end
  end
end