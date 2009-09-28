# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 6) do

  create_table "categories", :force => true do |t|
    t.column "name",      :string
    t.column "level",     :integer
    t.column "status",    :string,  :default => "unassigned"
    t.column "parent_id", :integer
  end

  create_table "personal_categories", :force => true do |t|
    t.column "name",        :string
    t.column "level",       :integer
    t.column "parent_id",   :integer
    t.column "user_id",     :integer
    t.column "category_id", :integer
    t.column "status",      :string,  :default => "unassigned"
  end

  create_table "users", :force => true do |t|
    t.column "email",            :string
    t.column "password",         :string
    t.column "status",           :string,   :default => "inprogress"
    t.column "created_at",       :datetime
    t.column "updated_at",       :datetime
    t.column "years_experience", :string
    t.column "education",        :string
    t.column "country",          :string
  end

end
