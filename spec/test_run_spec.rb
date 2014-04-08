require 'helper'

describe RoxClient::TestRun do
  TestRun ||= RoxClient::TestRun
  TestResult ||= RoxClient::TestResult
  TestPayload ||= RoxClient::TestPayload
  PayloadError ||= RoxClient::PayloadError

  let(:project_options){ { name: 'A project', version: '1.2.3', api_id: 'abc', category: 'A category', tags: %w(a b), tickets: %w(t1 t2) } }
  let(:project_double){ double project_options.merge(:validate! => nil) }
  subject{ TestRun.new project_double }

  it "should use the supplied project" do
    expect(subject.project).to be(project_double)
  end

  it "should have no end time, duration or uid" do
    expect(subject_attrs(:duration, :uid)).to eq(duration: nil, uid: nil)
  end

  it "should have no results" do
    expect(subject.results).to be_empty
  end

  it "should let its duration and uid be configured" do
    subject.duration = 42
    subject.uid = 'abc'
    expect(subject.duration).to eq(42)
    expect(subject.uid).to eq('abc')
  end

  describe "#add_result" do
    let(:result_options){ { key: 'abc' } }
    let(:new_result_double){ double }
    before :each do
      TestResult.stub new: new_result_double
    end

    it "should add a new result" do
      expect(TestResult).to receive(:new).with(project_double, result_options)
      add_result
      expect(subject.results).to eq([ new_result_double ])
    end

    it "should update an existing result" do
      existing_result = double key: 'abc', grouped?: true, update: nil
      subject.results << existing_result
      expect(TestResult).not_to receive(:new)
      expect(existing_result).to receive(:update).with(result_options.merge(grouped: true))
      add_result grouped: true
      expect(subject.results).to eq([ existing_result ])
    end

    it "should not update an existing result that is not grouped" do
      existing_result = double key: 'abc', grouped?: false
      subject.results << existing_result
      expect(TestResult).to receive(:new).with(project_double, result_options)
      expect(existing_result).not_to receive(:update)
      add_result
      expect(subject.results).to eq([ existing_result, new_result_double ])
    end

    it "should not update an existing result if the key doesn't match" do
      existing_result = double key: 'abc', grouped?: true
      subject.results << existing_result
      expect(TestResult).to receive(:new).with(project_double, result_options.merge(key: 'bcd', grouped: true))
      expect(existing_result).not_to receive(:update)
      add_result key: 'bcd', grouped: true
      expect(subject.results).to eq([ existing_result, new_result_double ])
    end

    it "should return an array or results without key" do
      doubles = [ 'abc', nil, '  ', 'bcd', nil ].collect{ |key| double key: key }
      subject.results.concat doubles
      expect(subject.results_without_key).to eq([ doubles[1], doubles[2], doubles[4] ])
    end

    it "should return a map of results by key" do
      doubles = [ 'abc', nil, nil, '   ', 'abc', 'bcd', 'cde', 'cde' ].collect{ |key| double key: key }
      subject.results.concat doubles
      expect(subject.results_by_key).to eq({
        'abc' => [ doubles[0], doubles[4] ],
        'bcd' => [ doubles[5] ],
        'cde' => [ doubles[6], doubles[7] ]
      })
    end

    describe "#to_h" do
      let(:result_doubles){ [] }
      let(:run_attributes){ { duration: 42 } }
      subject{ super().tap{ |r| run_attributes.each_pair{ |k,v| r.send "#{k}=", v }; r.results.concat result_doubles } }

      describe "with a missing project" do
        let(:project_double){ nil }
        
        it "should raise an error indicating that the project is missing" do
          expect{ subject.to_h }.to raise_payload_error(/missing project/i)
        end
      end

      describe "when the project fails to validate" do
        let(:project_double){ super().tap{ |d| d.stub(:validate!).and_raise(PayloadError.new('bug')) } }

        it "should raise a payload error with the same message" do
          expect{ subject.to_h }.to raise_payload_error(/bug/i)
        end
      end

      describe "with results that are missing a key" do
        let(:result_doubles){ [ double(key: 'a', to_h: 1), double(key: nil, name: 'abcd', to_h: 2), double(key: '  ', name: 'bcde', to_h: 3) ] }

        it "should raise an error indicating the invalid results" do
          expect{ subject.to_h }.to raise_payload_error(/missing a key/i, 'abcd', 'bcde')
        end
      end

      describe "with results that have duplicate keys" do
        let :result_doubles do
          [
            double(key: '1', name: 'abcd'), double(key: '1', name: 'bcde'),
            double(key: '2'),
            double(key: '3', name: 'cdef'), double(key: '3', name: 'defg'), double(key: '3', name: 'efgh')
          ]
        end

        it "should raise an error indicating the invalid results" do
          expect{ subject.to_h }.to raise_payload_error(/multiple test results/i, '- 1', '- 3', 'abcd', 'bcde', 'cdef', 'defg', 'efgh')
        end
      end

      describe "with valid data" do
        let(:to_h_options){ {} }
        let(:result_doubles){ [ double(key: 'a', to_h: 1), double(key: 'b', to_h: 2), double(key: 'c', to_h: 3) ] }
        subject{ super().to_h to_h_options }

        let :expected_result do
          {
            'd' => 42,
            'r' => [
              {
                'j' => 'abc',
                'v' => '1.2.3',
                't' => [ 1, 2, 3 ]
              }
            ]
          }
        end

        it "should serialize the run data" do
          result_doubles.each{ |d| expect(d).to receive(:to_h).with(to_h_options) }
          expect(subject).to eq(expected_result)
        end

        describe "with an uid" do
          let(:run_attributes){ super().merge uid: '123' }

          it "should serialize the run data with the uid" do
            expect(subject).to eq(expected_result.merge 'u' => '123')
          end
        end
      end
    end

    def add_result options = {}
      subject.add_result result_options.merge(options)
    end
  end

  def raise_payload_error *args
    raise_error PayloadError do |err|
      args.each{ |m| expect(err.message).to match(m) }
    end
  end

  def subject_attrs *attrs
    attrs.inject({}){ |memo,a| memo[a.to_sym] = subject.send(a); memo }
  end
end
