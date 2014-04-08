
RSpec::Matchers.define :have_elements_matching do |attr,*expected|

  match do |actual|
    elements = actual.send attr
    expected.all?{ |m| elements.any?{ |e| e.match(m) } }
  end

  description do
    "have #{attr} matching #{expected}"
  end
end
