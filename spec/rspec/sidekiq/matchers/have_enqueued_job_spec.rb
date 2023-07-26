require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::HaveEnqueuedJob do
  let(:tomorrow) { DateTime.now + 1 }
  let(:interval) { 3.minutes }
  let(:argument_subject) { RSpec::Sidekiq::Matchers::HaveEnqueuedJob.new worker_args }
  let(:matcher_subject) { RSpec::Sidekiq::Matchers::HaveEnqueuedJob.new [be_a(String), be_a(Integer), true, be_a(Hash)] }
  let(:worker) { create_worker }
  let(:worker_args) { ['string', 1, true, { "key" => 'value', "bar" => "foo", "nested" => [{"hash" => true}] }] }
  let(:active_job) { create_active_job :mailers }
  let(:resource) { TestResource.new }

  before(:each) do
    GlobalID.app = 'rspec-sidekiq'
    allow(GlobalID::Locator).to receive(:locate).and_return(resource)
  end

  describe 'expected usage' do
    context 'Sidekiq' do
      it 'matches' do
        worker.perform_async *worker_args
        expect(worker).to have_enqueued_sidekiq_job *worker_args
      end

      it 'matches on the global Worker queue' do
        worker.perform_async *worker_args
        expect(Sidekiq::Worker).to have_enqueued_sidekiq_job *worker_args
      end

      context 'perform_in' do
        let(:worker_args_in) { worker_args + ['in'] }

        it 'matches on an scheduled job with #perform_in' do
          worker.perform_in interval, *worker_args_in
          expect(worker).to have_enqueued_sidekiq_job(*worker_args_in).in(interval)
        end

        context "when crossing daylight saving time lines" do
          let(:interval) { 1.day }

          it "matches on a scheduled job with #perform_in" do
            travel_to Time.new(2023, 3, 12, 0, 0, 0, "-05:00") do # 2 hours before DST starts
              worker.perform_in interval, *worker_args_in
              expect(worker).to have_enqueued_sidekiq_job(*worker_args_in).in(interval)
            end
          end
        end
      end

      context 'perform_at' do
        let(:worker_args_at) { worker_args + ['at'] }

        it 'matches on an scheduled job with #perform_at' do
          worker.perform_at tomorrow, *worker_args_at
          expect(worker).to have_enqueued_sidekiq_job(*worker_args_at).at(tomorrow)
        end
      end
    end

    context 'ActiveJob' do
      it 'matches on an enqueued ActiveJob' do
        active_job.perform_later "someResource", *worker_args
        expect(Sidekiq::Worker).to have_enqueued_sidekiq_job 'someResource', *worker_args
      end

      it 'matches on an enqueued ActiveJob by global_id-capable object' do
        active_job.perform_later(resource)
        expect(Sidekiq::Worker).to have_enqueued_sidekiq_job(resource)
      end
    end

    context 'ActionMailer' do
      it 'matches on ActionMailer Job' do
        TestActionMailer.testmail(*worker_args).deliver_later
        expect(Sidekiq::Worker).to have_enqueued_sidekiq_job(
          'TestActionMailer',
          'testmail',
          'deliver_now',
          *worker_args
        )
      end

      it 'matches on ActionMailer with a resource Job' do
        TestActionMailer.testmail(resource).deliver_later
        expect(Sidekiq::Worker).to have_enqueued_sidekiq_job(
          'TestActionMailer',
          'testmail',
          'deliver_now',
          resource
        )
      end
    end
  end

  describe '#have_enqueued_sidekiq_job' do
    it 'returns instance' do
      worker.perform_async *worker_args
      expect(have_enqueued_sidekiq_job).to be_a RSpec::Sidekiq::Matchers::HaveEnqueuedJob
    end

    it 'matches the same way have_enqueued_sidekiq_job does' do
      worker.perform_async *worker_args
      expect(worker).to have_enqueued_sidekiq_job *worker_args
    end
  end

  describe '#description' do
    it 'returns description' do
      worker.perform_async *worker_args
      argument_subject.matches? worker
      expect(argument_subject.description).to eq %{have an enqueued #{worker} job with arguments [\"string\", 1, true, {\"key\"=>\"value\", \"bar\"=>\"foo\", \"nested\"=>[{\"hash\"=>true}]}]}
    end
  end

  describe '#failure_message' do
    it 'returns message' do
      worker.perform_async *worker_args
      argument_subject.matches? worker
      expect(argument_subject.failure_message).to eq <<~eos.strip
      expected to have an enqueued #{worker} job
        with arguments:
          -["string", 1, true, {"key"=>"value", "bar"=>"foo", "nested"=>[{"hash"=>true}]}]
      but have enqueued only jobs
        with arguments:
          -["string", 1, true, {"key"=>"value", "bar"=>"foo", "nested"=>[{"hash"=>true}]}]
      eos
    end

    context "when expected arguments is an array and multiple jobs enqueued" do
      let(:wrapped_args) { [worker_args] }
      let(:argument_subject) { RSpec::Sidekiq::Matchers::HaveEnqueuedJob.new wrapped_args }

      it "returns a message showing the wrapped array in expectations but each job on its own line" do
        2.times { worker.perform_async *worker_args }
        argument_subject.matches? worker
        expect(argument_subject.failure_message).to eq <<~eos.strip
        expected to have an enqueued #{worker} job
          with arguments:
            -[["string", 1, true, {"key"=>"value", "bar"=>"foo", "nested"=>[{"hash"=>true}]}]]
        but have enqueued only jobs
          with arguments:
            -["string", 1, true, {"key"=>"value", "bar"=>"foo", "nested"=>[{"hash"=>true}]}]
            -["string", 1, true, {"key"=>"value", "bar"=>"foo", "nested"=>[{"hash"=>true}]}]
        eos
      end
    end
  end

  describe '#failure_message_when_negated' do
    it 'returns message' do
      worker.perform_async *worker_args
      argument_subject.matches? worker
      expect(argument_subject.failure_message_when_negated).to eq <<-eos.gsub(/^ {6}/, '').strip
      expected not to have an enqueued #{worker} job
        arguments: [\"string\", 1, true, {\"key\"=>\"value\", \"bar\"=>\"foo\", \"nested\"=>[{\"hash\"=>true}]}]
      eos
    end
  end

  describe '#matches?' do
    context 'when condition matches' do
      context 'when expected are arguments' do
        it 'returns true' do
          worker.perform_async *worker_args
          expect(argument_subject.matches? worker).to be true
        end
      end

      context 'when expected are matchers' do
        it 'returns true' do
          worker.perform_async *worker_args
          expect(matcher_subject.matches? worker).to be true
        end
      end

      context 'when job is scheduled' do
        context 'with #perform_at' do
          context 'and timestamp matches' do
            it 'returns true' do
              worker.perform_at(tomorrow, *worker_args)
              expect(matcher_subject.at(tomorrow).matches? worker).to be true
            end
          end

          context 'and timestamp does not match' do
            it 'returns false' do
              worker.perform_at(tomorrow, *worker_args)
              expect(matcher_subject.at(tomorrow + 1).matches? worker).to be false
            end
          end
        end

        context 'with #perform_in' do
          context 'and interval matches' do
            it 'returns true' do
              worker.perform_in(interval, *worker_args)
              expect(matcher_subject.in(interval).matches? worker).to be true
            end
          end

          context 'and interval does not match' do
            it 'returns false' do
              worker.perform_in(interval, *worker_args)
              expect(matcher_subject.in(interval + 1.minute).matches? worker).to be false
            end
          end
        end
      end
    end

    context 'when condition does not match' do
      before(:each) { Sidekiq::Worker.clear_all }

      context 'when expected are arguments' do
        it 'returns false' do
          expect(argument_subject.matches? worker).to be false
        end
      end

      context 'when expected are matchers' do
        it 'returns false' do
          expect(matcher_subject.matches? worker).to be false
        end
      end

      context 'when job is scheduled' do
        context 'with #perform_at' do
          before(:each) do
            allow(matcher_subject).to receive(:options).and_return(at: tomorrow + 1)
          end

          it 'returns false' do
            expect(matcher_subject.at(tomorrow).matches? worker).to be false
          end
        end

        context 'with #perform_in' do
          before(:each) do
            allow(matcher_subject).to receive(:options).and_return(in: interval + 1)
          end

          it 'returns false' do
            expect(matcher_subject.in(interval).matches? worker).to be false
          end
        end
      end
    end
  end
end
