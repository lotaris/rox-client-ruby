require 'helper'

describe RoxClient::Project do
  Project ||= RoxClient::Project
  PayloadError ||= RoxClient::PayloadError

  let(:project_options){ { name: 'A project', version: '1.2.3', api_id: 'abc', category: 'A category', tags: %w(a b c), tickets: %w(t1 t2) } }
  subject{ Project.new project_options }

  it "should set its attributes from the options" do
    expect(subject_attrs(:name, :version, :api_id, :category, :tags, :tickets)).to eq(project_options)
  end

  describe "#update" do
    let(:updates){ { name: 'Another project', version: '2.3.4', api_id: 'def', category: 'Another category', tags: %w(d e), tickets: [] } }
    
    it "should update the attributes" do
      subject.update updates
      expect(subject_attrs(:name, :version, :api_id, :category, :tags, :tickets)).to eq(updates)
    end
  end

  describe "#validate!" do
    subject{ Project }

    it "should raise an error if the name is missing" do
      expect{ subject.new(project_options.merge(name: nil)).validate! }.to raise_payload_error(/missing/i, /name/i)
    end

    it "should raise an error if the version is missing" do
      expect{ subject.new(project_options.merge(version: nil)).validate! }.to raise_payload_error(/missing/i, /version/i)
    end

    it "should raise an error if the api identifier is missing" do
      expect{ subject.new(project_options.merge(api_id: nil)).validate! }.to raise_payload_error(/missing/i, /api identifier/i)
    end
  end

  def subject_attrs *attrs
    attrs.inject({}){ |memo,a| memo[a.to_sym] = subject.send(a); memo }
  end

  def raise_payload_error *messages
    raise_error PayloadError do |e|
      messages.each{ |m| expect(e.message).to match(m) }
    end
  end
end
