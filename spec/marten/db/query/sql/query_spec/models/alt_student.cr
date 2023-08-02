require "./student"

module Marten::DB::Query::SQL::QuerySpec
  class AltStudent < Student
    field :alt_grade, :string, max_size: 15
    field :alt_address, :many_to_one, to: Marten::DB::Query::SQL::QuerySpec::AltAddress, null: true, blank: true
  end
end
