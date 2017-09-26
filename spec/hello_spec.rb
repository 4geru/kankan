require 'spec_helper'
require 'hello'

describe Hello do
  it "message return hello" do
    expect(Hello.new.message).to eq "hello"
  end

  it "message return hello" do
    expect(Hello.new.message('this')).to eq "this"
  end
end