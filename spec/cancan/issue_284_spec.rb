require 'spec_helper'

if defined? CanCan::ModelAdapters::ActiveRecordAdapter
  describe 'Model' do
    before :each do
      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
      ActiveRecord::Migration.verbose = false

      ActiveRecord::Schema.define do
        create_table(:courses) do |t|
          t.timestamps null: false
        end

        create_table(:users) do |t|
          t.string :role
          t.timestamps null: false
        end

        create_table(:course_users) do |t|
          t.integer :user_id
          t.integer :course_id
        end

        create_table(:experience_points_records) do |t|
          t.integer :course_user_id
          t.timestamps null: false
        end
      end

      class Course < ActiveRecord::Base
        has_many :course_users
      end

      class User < ActiveRecord::Base
        has_many :course_users
      end

      class CourseUser < ActiveRecord::Base
        belongs_to :user
        belongs_to :course
      end

      class ExperiencePointsRecord < ActiveRecord::Base
        belongs_to :course_user
      end
    end

    describe '#accessible_by' do
      it 'does not raise any error' do
        user = User.create!(role: 'admin')
        read_hash = { course_user: { course: { course_users: { user_id: user.id, role: 'admin' } } } }
        ability = Ability.new(nil)
        ability.can :read, ExperiencePointsRecord, read_hash

        expect do
          relation = ExperiencePointsRecord.accessible_by(ability)
          relation.to_a
        end.not_to raise_error
      end
    end
  end
end
