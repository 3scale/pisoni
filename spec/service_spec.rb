require_relative './spec_helper'

describe ThreeScale::Core::Service do

  it 'works!' do
    storage.class.name.must_equal 'Redis'
  end
end
