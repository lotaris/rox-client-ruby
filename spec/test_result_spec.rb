require 'helper'

describe RoxClient::TestResult do
  let(:project_options){ { category: 'A category', tags: %w(a b), tickets: %w(t1 t2) } }
  let(:project_double){ double project_options }
  let(:result_options){ { key: '123', name: 'Something should work', passed: true, duration: 42 } }
  let(:result){ RoxClient::TestResult.new project_double, result_options }
  subject{ result }

  it "should use the example key" do
    expect(subject.key).to eq('123')
  end

  it "should build the name from the group's and example's descriptions" do
    expect(subject.name).to eq("Something should work")
  end

  it "should use the category, tags and tickets of the project" do
    expect(subject.category).to eq(project_options[:category])
    expect(subject.tags).to eq(project_options[:tags])
    expect(subject.tickets).to eq(project_options[:tickets])
  end

  it "should use the supplied result data" do
    expect(subject.passed?).to be_true
    expect(subject.duration).to eq(42)
    expect(subject.message).to be_nil
  end

  describe "when the key replaces the options" do
    let(:example_metadata){ '123' }

    it "should use the example key" do
      expect(subject.key).to eq('123')
    end
  end

  describe "when failing" do
    let(:result_options){ { passed: false, duration: 12, message: 'Oops' } }

    it "should use the supplied result data" do
      expect(subject.passed?).to be_false
      expect(subject.duration).to eq(12)
      expect(subject.message).to eq('Oops')
    end
  end

  describe "when grouped" do
    let(:result_options){ super().merge grouped: true }

    it "should mark the result as grouped" do
      expect(subject.grouped?).to be_true
    end

    it "should use the specified key" do
      expect(subject.key).to eq('123')
    end
  end

  describe "#update" do
    let(:updates){ [] }
    subject{ super().tap{ |s| updates.each{ |u| s.update u } } }

    it "should not concatenate missing messages" do
      subject.update passed: true, duration: 1
      subject.update passed: true, duration: 2
      subject.update passed: true, duration: 3
      expect(subject.message).to be_nil
    end

    describe "with failing result data" do
      let(:update_options){ { passed: false, duration: 24, message: 'Foo' } }
      let(:updates){ super() << update_options }

      it "should mark the result as failed" do
        expect(subject.passed?).to be_false
      end

      it "should increase the duration" do
        expect(subject.duration).to eq(66)
      end

      it "should set the message" do
        expect(subject.message).to eq('Foo')
      end

      describe "and passing result data" do
        let(:other_update_options){ { passed: true, duration: 600, message: 'Bar' } }
        let(:updates){ super() << other_update_options }

        it "should keep the result marked as failed" do
          expect(subject.passed?).to be_false
        end

        it "should increase the duration" do
          expect(subject.duration).to eq(666)
        end

        it "should concatenate the messages" do
          expect(subject.message).to eq("Foo\n\nBar")
        end
      end
    end
  end

  describe "#to_h" do
    let(:to_h_options){ {} }
    let(:result_options){ super().merge message: 'Yeehaw!' }
    subject{ super().to_h to_h_options }

    let :expected_result do
      {
        'k' => '123',
        'n' => 'Something should work',
        'p' => true,
        'd' => 42,
        'm' => 'Yeehaw!',
        'c' => 'A category',
        'g' => [ 'a', 'b' ],
        't' => [ 't1', 't2' ]
      }
    end

    it "should serialize the result" do
      expect(subject).to eq(expected_result)
    end

    describe "with no message, category, tags or tickets" do
      let(:project_options){ { category: nil, tags: nil, tickets: nil } }
      let(:result_options){ super().merge message: nil }

      it "should not include them" do
        expect(subject).to eq(expected_result.delete_if{ |k,v| %w(m c g t).include? k })
      end
    end

    describe "with a cache" do
      let(:cache_double){ double known?: false, stale?: false }
      let(:to_h_options){ super().merge cache: cache_double }

      it "should serialize the result" do
        expect(subject).to eq(expected_result)
      end

      describe "when cached" do
        let(:cache_double){ double known?: true, stale?: false }
        let(:to_h_options){ super().merge cache: cache_double }

        it "should serialize the result without known data" do
          expect(subject).to eq(expected_result.delete_if{ |k,v| %w(n c g t).include? k })
        end

        describe "and stale" do
          let(:cache_double){ double known?: true, stale?: true }

          it "should serialize the result" do
            expect(subject).to eq(expected_result)
          end
        end
      end
    end
  end
end
