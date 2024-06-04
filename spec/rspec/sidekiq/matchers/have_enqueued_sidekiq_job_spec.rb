# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::HaveEnqueuedSidekiqJob do
  let(:tomorrow) { DateTime.now + 1 }
  let(:yesterday) { DateTime.now - 1 }
  let(:interval) { 3.minutes }
  let(:argument_subject) { described_class.new worker_args }
  let(:matcher_subject) { described_class.new [be_a(String), be_a(Integer), true, be_a(Hash)] }
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
      it 'matches a job with no arguments' do
        worker.perform_async
        expect(worker).to have_enqueued_sidekiq_job
        expect(worker).to have_enqueued_sidekiq_job(no_args)
        expect(worker).to have_enqueued_sidekiq_job.with(no_args)
      end

      it 'matches a job with no arguments once' do
        worker.perform_async
        expect(worker).to have_enqueued_sidekiq_job.once
      end

      it "fails if a job was expected once but occurred twice" do
        worker.perform_async
        worker.perform_async
        expect do
          expect(worker).to have_enqueued_sidekiq_job.once
        end.to raise_error(/expected to have enqueued 1 .* job.*but enqueued only jobs/m)
      end

      it 'matches a job with no arguments exactly once' do
        worker.perform_async
        expect(worker).to have_enqueued_sidekiq_job.exactly(1)
        expect(worker).to have_enqueued_sidekiq_job.exactly(1).time
        expect(worker).to have_enqueued_sidekiq_job.exactly(:once)
      end

      it 'matches a job with no arguments twice' do
        worker.perform_async
        worker.perform_async
        expect(worker).to have_enqueued_sidekiq_job.twice
      end

      it "fails if a job was expected twice but occurred once" do
        worker.perform_async
        expect do
          expect(worker).to have_enqueued_sidekiq_job.twice
        end.to raise_error(/expected to have enqueued 2 .* jobs.*but enqueued only jobs/m)
      end

      it 'matches a job with no arguments exactly twice' do
        worker.perform_async
        worker.perform_async
        expect(worker).to have_enqueued_sidekiq_job.exactly(2)
        expect(worker).to have_enqueued_sidekiq_job.exactly(2).times
        expect(worker).to have_enqueued_sidekiq_job.exactly(:twice)
      end

      it 'matches a job with no arguments thrice' do
        worker.perform_async
        worker.perform_async
        worker.perform_async
        expect(worker).to have_enqueued_sidekiq_job.thrice
      end

      it 'matches a job with no arguments exactly thrice' do
        worker.perform_async
        worker.perform_async
        worker.perform_async
        expect(worker).to have_enqueued_sidekiq_job.exactly(3)
        expect(worker).to have_enqueued_sidekiq_job.exactly(3).times
        expect(worker).to have_enqueued_sidekiq_job.exactly(:thrice)
      end

      it 'matches a job with no arguments at least once' do
        worker.perform_async
        expect(worker).to have_enqueued_sidekiq_job.at_least(1)
        expect(worker).to have_enqueued_sidekiq_job.at_least(1).time
        expect(worker).to have_enqueued_sidekiq_job.at_least(:once)

        worker.perform_async
        expect(worker).to have_enqueued_sidekiq_job.at_least(1)
        expect(worker).to have_enqueued_sidekiq_job.at_least(1).time
        expect(worker).to have_enqueued_sidekiq_job.at_least(:once)
      end

      it "fails if a job was expected at least once but never occurred" do
        expect do
          expect(worker).to have_enqueued_sidekiq_job.at_least(:once)
        end.to raise_error(/expected to have enqueued at least 1 .* job.*but enqueued 0 jobs/m)
      end

      it 'matches a job with no arguments at most twice' do
        worker.perform_async
        expect(worker).to have_enqueued_sidekiq_job.at_most(2)
        expect(worker).to have_enqueued_sidekiq_job.at_most(2).time
        expect(worker).to have_enqueued_sidekiq_job.at_most(:twice)

        worker.perform_async
        expect(worker).to have_enqueued_sidekiq_job.at_most(2)
        expect(worker).to have_enqueued_sidekiq_job.at_most(2).time
        expect(worker).to have_enqueued_sidekiq_job.at_most(:twice)
      end

      it "fails if a job was expected at most once but occurred twice" do
        worker.perform_async
        worker.perform_async
        expect do
          expect(worker).to have_enqueued_sidekiq_job.at_most(:once)
        end.to raise_error(/expected to have enqueued at most 1 .* job.*but enqueued only jobs/m)
      end

      it 'matches a job with arguments' do
        worker.perform_async(*worker_args)
        expect(worker).to have_enqueued_sidekiq_job
        expect(worker).to have_enqueued_sidekiq_job(*worker_args)
      end

      it 'matches on the global Worker queue' do
        worker.perform_async(*worker_args)
        expect(Sidekiq::Worker).to have_enqueued_sidekiq_job(*worker_args)
      end

      it "fails if a job was enqueued with arguments but matched with no_args" do
        worker.perform_async(*worker_args)
        expect do
          expect(worker).to have_enqueued_sidekiq_job(no_args)
        end.to raise_error(/expected to have enqueued a .* job/)
        expect do
          expect(worker).to have_enqueued_sidekiq_job.with(no_args)
        end.to raise_error(/expected to have enqueued a .* job/)
      end

      context "when negated" do
        it "passes if no jobs are enqueued" do
          expect(worker).not_to have_enqueued_sidekiq_job
        end

        it "fails if a job was enqueued" do
          worker.perform_async(*worker_args)
          expect do
            expect(worker).not_to have_enqueued_sidekiq_job
          end.to raise_error(/expected not to have enqueued a .* job/)
        end
      end

      context "when using builtin argument matchers" do
        it "matches" do
          worker.perform_async({"something" => "Awesome", "extra" => "stuff"})
          expect(worker).to have_enqueued_sidekiq_job(hash_including("something" => "Awesome"))
          expect(worker).to have_enqueued_sidekiq_job(any_args)
          expect(worker).to have_enqueued_sidekiq_job(hash_excluding("bad_stuff" => anything))

          worker.perform_async({"something" => 1})
          expect(worker).to have_enqueued_sidekiq_job({something: kind_of(Integer)})
        end
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

      context "#on queue" do
        it "matches the queue in the context" do
          worker.perform_async(*worker_args)
          expect(worker).to have_enqueued_sidekiq_job(*worker_args).on("default")
        end

        context "when setting queue at runtime" do
          it "matches the queue set" do
            worker.set(queue: "highest").perform_async(*worker_args)
            expect(worker).to have_enqueued_sidekiq_job(*worker_args).on("highest")
          end
        end
      end

      describe "composable" do
        it "can be composed with other matchers" do
          worker.perform_async(*worker_args)
          worker.perform_async(1)
          expect(worker).to have_enqueued_sidekiq_job(*worker_args).and have_enqueued_sidekiq_job(1)
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
      worker.perform_async(*worker_args)
      expect(have_enqueued_sidekiq_job).to be_a described_class
    end

    it 'matches the same way have_enqueued_sidekiq_job does' do
      worker.perform_async(*worker_args)
      expect(worker).to have_enqueued_sidekiq_job(*worker_args)
    end
  end

  describe '#description' do
    it 'returns description' do
      worker.perform_async(*worker_args)
      argument_subject.matches? worker
      expect(argument_subject.description).to eq %{have enqueued a #{worker} job with arguments [\"string\", 1, true, {\"key\"=>\"value\", \"bar\"=>\"foo\", \"nested\"=>[{\"hash\"=>true}]}]}
    end
  end

  describe '#failure_message' do
    it 'returns message' do
      jid = worker.perform_async(*worker_args)
      argument_subject.matches? worker
      expect(argument_subject.failure_message).to eq <<~eos.strip
      expected to have enqueued a #{worker} job
        with arguments:
          -["string", 1, true, {"bar"=>"foo", "key"=>"value", "nested"=>[{"hash"=>true}]}]
      but enqueued only jobs
        -JID:#{jid} with arguments:
          -["string", 1, true, {"bar"=>"foo", "key"=>"value", "nested"=>[{"hash"=>true}]}]
      eos
    end

    context "when expected arguments is an array and multiple jobs enqueued" do
      let(:wrapped_args) { [worker_args] }
      let(:argument_subject) { described_class.new wrapped_args }

      it "returns a message showing the wrapped array in expectations but each job on its own line" do
        jids = 2.times.map { worker.perform_async(*worker_args) }
        argument_subject.matches? worker
        expect(argument_subject.failure_message).to eq <<~eos.strip
        expected to have enqueued a #{worker} job
          with arguments:
            -[["string", 1, true, {"bar"=>"foo", "key"=>"value", "nested"=>[{"hash"=>true}]}]]
        but enqueued only jobs
          -JID:#{jids[0]} with arguments:
            -["string", 1, true, {"bar"=>"foo", "key"=>"value", "nested"=>[{"hash"=>true}]}]
          -JID:#{jids[1]} with arguments:
            -["string", 1, true, {"bar"=>"foo", "key"=>"value", "nested"=>[{"hash"=>true}]}]
        eos
      end
    end
  end

  describe '#failure_message_when_negated' do
    it 'returns message' do
      worker.perform_async(*worker_args)
      argument_subject.matches? worker
      expect(argument_subject.failure_message_when_negated).to eq <<-eos.gsub(/^ {6}/, '').strip
      expected not to have enqueued a #{worker} job but enqueued 1
        arguments: [\"string\", 1, true, {\"key\"=>\"value\", \"bar\"=>\"foo\", \"nested\"=>[{\"hash\"=>true}]}]
      eos
    end
  end

  describe '#matches?' do
    context 'when condition matches' do
      context 'when expected are arguments' do
        it 'returns true' do
          worker.perform_async(*worker_args)
          expect(argument_subject.matches? worker).to be true
        end
      end

      context "when expected arguments include symbols" do
        let(:worker_args) { [:foo, {bar: :baz}] }
        it "returns true" do
          worker.perform_async(*JSON.parse(worker_args.to_json))
          expect(worker).to have_enqueued_sidekiq_job(*worker_args)
        end
      end

      context 'when expected are matchers' do
        it 'returns true' do
          worker.perform_async(*worker_args)
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

          context 'and past timestamp matches' do
            it 'returns true' do
              worker.perform_at(yesterday, *worker_args)
              expect(matcher_subject.immediately.matches? worker).to be true
            end
          end

          context 'and past timestamp does not match' do
            it 'returns true' do
              worker.perform_at(tomorrow, *worker_args)
              expect(matcher_subject.immediately.matches? worker).to be false
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

          context 'and past interval matches' do
            it 'returns true' do
              worker.perform_in(-1, *worker_args)
              expect(matcher_subject.immediately.matches? worker).to be true
            end
          end

          context 'and interval does not match' do
            it 'returns false' do
              worker.perform_in(1, *worker_args)
              expect(matcher_subject.immediately.matches? worker).to be false
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

        context "and arguments are out of order" do
          it "returns false" do
            worker.perform_async(*worker_args.reverse)
            expect(argument_subject.matches? worker).to be false
          end
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
