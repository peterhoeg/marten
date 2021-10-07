require "./spec_helper"

describe Marten::Views::RecordRetrieving do
  describe "::lookup_field(field_name)" do
    it "allows to configure the name of the field used to perform the record lookup" do
      Marten::Views::RecordRetrievingSpec::TestView.lookup_field.should eq "id"
    end
  end

  describe "::lookup_field" do
    it "returns the configured name of the field used to perform the record lookup" do
      Marten::Views::RecordRetrievingSpec::TestView.lookup_field.should eq "id"
    end

    it "returns pk by default" do
      Marten::Views::RecordRetrievingSpec::TestViewWithoutConfiguration.lookup_field.should eq "pk"
    end
  end

  describe "::lookup_param(param_name)" do
    it "allows to configure the name of the URL param used to retrieve the value associated with the lookup field" do
      Marten::Views::RecordRetrievingSpec::TestView.lookup_param.should eq "identifier"
    end
  end

  describe "::lookup_param" do
    it "returns the configured name of the param used to retrieve the lookup value" do
      Marten::Views::RecordRetrievingSpec::TestView.lookup_param.should eq "identifier"
    end

    it "returns the lookup field by default" do
      Marten::Views::RecordRetrievingSpec::TestViewWithoutConfiguration.lookup_param.should eq "pk"
    end
  end

  describe "::model" do
    it "returns the configured model" do
      Marten::Views::RecordRetrievingSpec::TestView.model.should eq TestUser
    end

    it "returns nil by default" do
      Marten::Views::RecordRetrievingSpec::TestViewWithoutConfiguration.model.should be_nil
    end
  end

  describe "::model(model)" do
    it "allows to configure the model used to retrieve the record" do
      Marten::Views::RecordRetrievingSpec::TestView.model.should eq TestUser
    end
  end

  describe "#queryset" do
    it "returns all the records for the configured model by default" do
      user_1 = TestUser.create!(username: "jd1", email: "jd1@example.com", first_name: "John", last_name: "Doe")
      user_2 = TestUser.create!(username: "jd2", email: "jd2@example.com", first_name: "John", last_name: "Doe")

      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "GET",
          resource: "",
          headers: HTTP::Headers{"Host" => "example.com"}
        )
      )
      view = Marten::Views::RecordRetrievingSpec::TestView.new(request)

      view.queryset.to_a.should eq [user_1, user_2]
    end
  end

  describe "#record" do
    it "returns the record by using the lookup param" do
      user_1 = TestUser.create!(username: "jd1", email: "jd1@example.com", first_name: "John", last_name: "Doe")
      TestUser.create!(username: "jd2", email: "jd2@example.com", first_name: "John", last_name: "Doe")

      params = Hash(String, Marten::Routing::Parameter::Types){"identifier" => user_1.id!}
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "GET",
          resource: "",
          headers: HTTP::Headers{"Host" => "example.com"}
        )
      )
      view = Marten::Views::RecordRetrievingSpec::TestView.new(request, params)

      view.record.should eq user_1
    end

    it "raises the expected exceptions when the record does not exist" do
      TestUser.create!(username: "jd1", email: "jd1@example.com", first_name: "John", last_name: "Doe")
      TestUser.create!(username: "jd2", email: "jd2@example.com", first_name: "John", last_name: "Doe")

      params = Hash(String, Marten::Routing::Parameter::Types){"identifier" => -1}
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "GET",
          resource: "",
          headers: HTTP::Headers{"Host" => "example.com"}
        )
      )
      view = Marten::Views::RecordRetrievingSpec::TestView.new(request, params)

      expect_raises(
        Marten::HTTP::Errors::NotFound,
        "No TestUser record can be found for the given query"
      ) do
        view.record
      end
    end
  end
end

module Marten::Views::RecordRetrievingSpec
  class TestView < Marten::View
    include Marten::Views::RecordRetrieving

    lookup_field "id"
    lookup_param "identifier"
    model TestUser
  end

  class TestViewWithoutConfiguration < Marten::View
    include Marten::Views::RecordRetrieving
  end
end
