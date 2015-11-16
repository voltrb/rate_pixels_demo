class RankPage < Volt::Model
  field :id_list, String
  field :week, Fixnum
  field :page, Fixnum
  field :page_count, Fixnum # store the total number of pages here for easier access

  index [:week, :page], unique: true
end
