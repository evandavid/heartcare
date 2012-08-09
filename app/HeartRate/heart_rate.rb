# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class HeartRate
  include Rhom::FixedSchema
  set :schema_version, '1.0'

  property :member_id, :integer
  property :heart_rate, :integer
  property :beat, :integer
  property :battery, :integer
  property :stamp1, :integer
  property :stamp2, :integer
  property :stamp3, :integer
  property :stamp4, :integer
  property :stamp5, :integer
  property :stamp6, :integer
  property :stamp7, :integer
  property :stamp8, :integer
  property :stamp9, :integer
  property :stamp10, :integer
  property :stamp11, :integer
  property :stamp12, :integer
  property :stamp13, :integer
  property :stamp14, :integer
  property :stamp15, :integer
  property :distance, :integer
  property :speed, :integer
  property :last_check, :date
  property :sync, :integer

  belongs_to :member_id, 'Member'
end
