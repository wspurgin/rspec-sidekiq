# frozen_string_literal: true

require "spec_helper"

RSpec.describe RSpec::Sidekiq::Matchers::EnqueueSidekiqJob do
  let(:worker) { create_worker }

  describe "enqueue_sidekiq_job" do
    it "raises an error if no block given" do
      expect {
        expect(worker.perform_async).to enqueue_sidekiq_job
      }.to raise_error(ArgumentError, /Only block syntax supported for enqueue_sidekiq_job/)
    end

    it "passes if the block enqueues a sidekiq job" do
      expect { worker.perform_async }.to enqueue_sidekiq_job
    end

    context "when negated" do
      it "passes if no jobs are enqueued" do
        expect {
          "does nothing"
        }.not_to enqueue_sidekiq_job
      end

      it "fails if a job is enqueued" do
        expect do
          expect {
            worker.perform_async
          }.not_to enqueue_sidekiq_job
        end.to raise_error(/expected not to enqueue a .* job but enqueued 1/)
      end
    end

    context "when jobs are enqueues outside of the block" do
      it "fails if no new jobs were enqueued in the block" do
        worker.perform_async
        expect {
          expect {
            "does nothing"
          }.to enqueue_sidekiq_job
        }.to raise_error(/expected to enqueue a .* job.*but enqueued 0/m)
      end

      it "passes when negated and no new jobs were enqueued" do
        worker.perform_async
        expect {
          "does nothing"
        }.not_to enqueue_sidekiq_job
      end
    end

    context "with expected arguments" do
      it "passes if a job with the argument is found" do
        expect {
          worker.perform_async "some_arg"
        }.to enqueue_sidekiq_job.with("some_arg")
      end

      context "when expected arguments include symbols" do
        it "returns true" do
          expect {
            worker.perform_async("foo", {"some_arg" => "etc"})
          }.to enqueue_sidekiq_job.with(:foo, {some_arg: :etc})
        end
      end

      it "fails if no job with args are found" do
        expect do
          expect {
            worker.perform_async
          }.to enqueue_sidekiq_job.with("some_arg")
        end.to raise_error { |error|
          lines = error.message.split("\n")
          expect(lines).to include(
            match(/expected to enqueue a .* job/),
            match(/with arguments:/),
            match(/-\["some_arg"\]/)
          )
        }
      end
    end

    context "on a specific queue" do
      it "passes if the queue is set at runtime" do
        expect {
          worker.set(queue: "high").perform_async
        }.to enqueue_sidekiq_job.on("high")
      end

      it "passes if the queue is set via options" do
        other_worker = create_worker(queue: "low")
        expect {
          other_worker.perform_async
        }.to enqueue_sidekiq_job.on("low")
      end

      it "fails if job is enqueued on a different queue" do
        expect do
          expect {
            worker.perform_async
          }.to enqueue_sidekiq_job.on("very_high")
        end.to raise_error { |error|
          lines = error.message.split("\n")
          expect(lines).to include(
            match(/expected to enqueue a .* job/),
            match(/-{"queue"=>"very_high"}/)
          )
        }
      end
    end

    context "at a specific time" do
      it "passes if the job is enqueued for the specific time" do
        specific_time = 1.hour.from_now
        expect { worker.perform_at(specific_time) }.to enqueue_sidekiq_job.at(specific_time)
      end

      it "fails if the job is enqueued at no particular time" do
        specific_time = 1.hour.from_now
        expect do
          expect { worker.perform_async }.to enqueue_sidekiq_job.at(specific_time)
        end.to raise_error { |error|
          lines = error.message.split("\n")
          expect(lines).to include(
            match(/expected to enqueue a .* job/),
            match(/-{"at"=>#{specific_time.to_i}}/)
          )
        }
      end

      it "fails if the job is enqueued at a different time" do
        specific_time = 1.hour.from_now
        expect do
          expect { worker.perform_at(specific_time + 1.hour) }.to enqueue_sidekiq_job.at(specific_time)
        end.to raise_error { |error|
          lines = error.message.split("\n")
          expect(lines).to include(
            match(/expected to enqueue a .* job/),
            match(/-{"at"=>#{specific_time.to_i}}/)
          )
        }
      end
    end

    context "in a specific interval" do
      around do |example|
        freeze_time do
          example.run
        end
      end

      it "passes if the job is enqueued for the time in that interval" do
        expect { worker.perform_in(1.hour) }.to enqueue_sidekiq_job.in(1.hour)
      end

      it "fails if the job is enqueued at no particular time" do
        expect do
          expect { worker.perform_async }.to enqueue_sidekiq_job.in(1.hour)
        end.to raise_error { |error|
          lines = error.message.split("\n")
          expect(lines).to include(
            match(/expected to enqueue a .* job/),
            match(/-{"at"=>#{1.hour.from_now.to_i}}/)
          )
        }
      end

      it "fails if the job is enqueued at a different time" do
        expect do
          expect { worker.perform_in(2.hours) }.to enqueue_sidekiq_job.in(1.hour)
        end.to raise_error { |error|
          lines = error.message.split("\n")
          expect(lines).to include(
            match(/expected to enqueue a .* job/),
            match(/-{"at"=>#{1.hour.from_now.to_i}}/)
          )
        }
      end
    end

    context "immediately" do
      it "passes if the job is enqueued immediately" do
        expect { worker.perform_async }.to enqueue_sidekiq_job.immediately
        expect { worker.perform_at(1.hour.ago) }.to enqueue_sidekiq_job.immediately
      end

      it "fails if the job is scheduled" do
        specific_time = 1.hour.from_now
        expect do
          expect { worker.perform_at(specific_time) }.to enqueue_sidekiq_job.immediately
        end.to raise_error { |error|
          lines = error.message.split("\n")
          expect(lines).to include(
            match(/expected to enqueue a .* job/),
            match(/-{"at"=>nil}/)
          )
        }
      end
    end

    describe "composable" do
      let(:other_worker) { create_worker }
      it "can be composed with other matchers" do
        expect do
          worker.perform_async
          other_worker.perform_async
        end.to enqueue_sidekiq_job(worker).and enqueue_sidekiq_job(other_worker)
      end
    end

    describe "chainable" do
      it "can chain expectations on the job" do
        specific_time = 1.hour.from_now
        expect { worker.perform_at specific_time, "some_arg" }.to(
          enqueue_sidekiq_job(worker)
          .with("some_arg")
          .on("default")
          .at(specific_time)
        )
      end
    end

    context "with expected count" do
      it 'matches a job with no arguments once' do
        expect { worker.perform_async }.to enqueue_sidekiq_job.once
      end

      it "fails if a job was expected once but occurred twice" do
        expect do
          expect { worker.perform_async; worker.perform_async }.to enqueue_sidekiq_job.once
        end.to raise_error(/expected to enqueue 1 .* job.*but enqueued only jobs/m)
      end

      it 'matches a job with no arguments exactly once' do
        expect { worker.perform_async }.to enqueue_sidekiq_job.exactly(1)
        expect { worker.perform_async }.to enqueue_sidekiq_job.exactly(1).time
        expect { worker.perform_async }.to enqueue_sidekiq_job.exactly(:once)
      end

      it 'matches a job with no arguments twice' do
        expect {
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.twice
      end

      it "fails if a job was expected twice but occurred once" do
        expect do
          expect { worker.perform_async }.to enqueue_sidekiq_job.twice
        end.to raise_error(/expected to enqueue 2 .* jobs.*but enqueued only jobs/m)
      end

      it 'matches a job with no arguments exactly twice' do
        expect {
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.exactly(2)

        expect {
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.exactly(2).times

        expect {
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.exactly(:twice)
      end

      it 'matches a job with no arguments thrice' do
        expect {
          worker.perform_async
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.thrice
      end

      it 'matches a job with no arguments exactly thrice' do
        expect {
          worker.perform_async
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.exactly(3)

        expect {
          worker.perform_async
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.exactly(3).times

        expect {
          worker.perform_async
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.exactly(:thrice)
      end

      it 'matches a job with no arguments at least once' do
        expect { worker.perform_async }.to enqueue_sidekiq_job.at_least(1)
        expect { worker.perform_async }.to enqueue_sidekiq_job.at_least(1).time
        expect { worker.perform_async }.to enqueue_sidekiq_job.at_least(:once)

        expect {
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.at_least(1)

        expect {
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.at_least(1).time

        expect {
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.at_least(:once)
      end

      it "fails if a job was expected at least once but never occurred" do
        expect do
          expect {}.to enqueue_sidekiq_job.at_least(:once)
        end.to raise_error(/expected to enqueue at least 1 .* job.*but enqueued 0 jobs/m)
      end

      it 'matches a job with no arguments at most twice' do
        expect { worker.perform_async }.to enqueue_sidekiq_job.at_most(2)
        expect { worker.perform_async }.to enqueue_sidekiq_job.at_most(2).time
        expect { worker.perform_async }.to enqueue_sidekiq_job.at_most(:twice)

        expect {
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.at_most(2)

        expect {
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.at_most(2).time

        expect {
          worker.perform_async
          worker.perform_async
        }.to enqueue_sidekiq_job.at_most(:twice)
      end

      it "fails if a job was expected at most once but occurred twice" do
        expect do
          expect { worker.perform_async; worker.perform_async }.to enqueue_sidekiq_job.at_most(:once)
        end.to raise_error(/expected to enqueue at most .* job.*but enqueued only jobs/m)
      end
    end
  end
end
